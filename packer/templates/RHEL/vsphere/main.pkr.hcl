packer {
  required_version = ">= 1.9.0"

  required_plugins {
    # https://github.com/vmware/packer-plugin-vsphere/tree/main/docs
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 2"
    }

    # https://github.com/hashicorp/packer-plugin-ansible/tree/main/docs
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.4"
    }
  }
}

# https://developer.hashicorp.com/packer/integrations/vmware/vsphere/latest/components/builder/vsphere-iso
source "vsphere-iso" "virtual_machine" {
  # vCenter connection
  insecure_connection = true
  username            = var.vsphere_user
  password            = var.vsphere_password
  vcenter_server      = var.vsphere_server
  datacenter          = var.vsphere_datacenter
  cluster             = var.vsphere_cluster
  datastore           = var.vsphere_vm_datastore
  folder              = var.vsphere_folder

  # VM settings
  vm_name              = local.vm_name
  guest_os_type        = var.guest_os_type
  firmware             = "efi"
  RAM                  = 4096
  RAM_reserve_all      = false
  CPUs                 = 2
  cpu_cores            = 1
  disk_controller_type = ["pvscsi"]

  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
    disk_controller_index = 0
  }

  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }

  # Reference a pre-uploaded ISO on the datastore
  iso_paths = [local.iso_path]

  # Packer HTTP server — serves rendered ks.cfg during boot
  http_ip       = var.packer_http_ip
  http_port_min = 57100
  http_port_max = 57199
  http_content = {
    "/ks.cfg" = templatefile("${path.cwd}/common/kickstart/rhel.ks.pkrtpl.hcl", {
      ssh_user            = local.ssh_user
      ssh_password        = local.ssh_password
      bootloader_user     = var.bootloader_user
      bootloader_password = var.bootloader_password
      kernel_args         = var.kernel_args
      timezone            = var.timezone
      partitions          = var.partitions
      packages            = var.packages
      post_scripts        = var.post_scripts
    })
  }

  # Interrupt GRUB and pass kickstart URL
  boot_wait = "5s"
  boot_command = [
    "<up>",
    "e",
    "<down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg inst.cmdline ${var.kernel_args}",
    "<leftCtrlOn>x<leftCtrlOff>",
  ]

  # Configure Packer provisioner access
  communicator              = "ssh"
  ssh_username              = local.ssh_user
  ssh_password              = local.ssh_password
  ssh_timeout               = "30m"
  ssh_handshake_attempts    = "100"
  ssh_clear_authorized_keys = true

  shutdown_command = ""

  convert_to_template  = true
  tools_upgrade_policy = true
  remove_cdrom         = true

  notes = <<EOF
  Name: ${var.image_name}
  Base ISO: ${local.iso_path}
  SCAP Profile: ${var.scap_profile}
  Build Date: ${formatdate("YYYY-MM-DD HH:mm:ss", timestamp())}
  EOF
}

# https://developer.hashicorp.com/packer/docs/builders
build {
  sources = ["source.vsphere-iso.virtual_machine"]

  name = var.image_name

  # https://developer.hashicorp.com/packer/docs/provisioners/breakpoint
  provisioner "breakpoint" {
    note    = "Pause prior to Security Content Automation Protocol (SCAP) remediation"
    disable = true
  }

  # https://github.com/hashicorp/packer-plugin-ansible/blob/main/docs/provisioners/ansible.mdx
  provisioner "ansible" {
    playbook_file = "${path.cwd}/common/ansible/scap_remediation.yml"
    extra_arguments = [
      "-e ansible_become_password=${local.ssh_password}",
      "-e scap_profile=${var.scap_profile}",
      "-e scap_report_dir=${path.cwd}/builds/${local.vm_name}/"
    ]
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/common/ansible/ansible.cfg"
    ]
    user      = local.ssh_user
    use_proxy = true
    timeout   = "10m"
  }

  # https://developer.hashicorp.com/packer/docs/provisioners/breakpoint
  provisioner "breakpoint" {
    note    = "Pause prior to configuring virtual machine"
    disable = true
  }

  # Prepare virtual machine for first boot
  # https://github.com/hashicorp/packer-plugin-ansible/blob/main/docs/provisioners/ansible.mdx
  # provisioner "ansible" {
  #   playbook_file = "${path.cwd}/common/ansible/prepare.yml"
  #   extra_arguments = [
  #     "-e ansible_become_password='${local.ssh_password}'"
  #   ]
  #   ansible_env_vars = [
  #     "ANSIBLE_CONFIG=${path.cwd}/common/ansible/ansible.cfg",
  #   ]
  #   user          = local.ssh_user
  #   use_proxy     = true
  #   timeout       = "3m"
  # }

  # https://developer.hashicorp.com/packer/docs/provisioners/breakpoint
  provisioner "breakpoint" {
    note    = "Pause prior to preparing virtual machine for image capture"
    disable = true
  }

  # Prepare virtual machine for image capture
  # https://github.com/hashicorp/packer-plugin-ansible/blob/main/docs/provisioners/ansible.mdx
  provisioner "ansible" {
    playbook_file = "${path.cwd}/common/ansible/clean.yml"
    extra_arguments = [
      "-e ansible_become_password='${local.ssh_password}'"
    ]
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/common/ansible/ansible.cfg",
    ]
    user      = local.ssh_user
    use_proxy = true
    timeout   = "3m"
  }

  post-processor "manifest" {
    output     = "${path.cwd}/builds/${local.vm_name}/manifest.json"
    strip_path = true
  }
}
