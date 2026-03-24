variable "packer_http_ip" {
  description = "IP of the Packer build host reachable from vSphere"
  type        = string
}

variable "kernel_args" {
  type    = string
  default = ""
}

variable "partitions" {
  type = list(object({
    name       = string
    mountpoint = string
    fstype     = string
    size       = number
  }))
  description = <<-EOT
    partitions = [
      partition = {
        name : "LV name used by lvm (e.g. root, var_log_audit)"
        mountpoint : "Filesystem mount point (e.g. /, /var/log/audit)"
        fstype : "Filesystem type (e.g. xfs, swap)"
        size : "Minimum size of the logical volume in MiB"
      }
    ]
  EOT
}

variable "post_scripts" {
  type = list(object({
    name        = string
    description = string
    content     = string
  }))
  description = <<-EOT
    post_scripts = [
      script = {
        name : "Identifier for the Post Script"
        description : "What the Post Script is used for"
        content : "Shell script contents (exluding shebang)"
      }
    ]
  EOT
  default     = []
}

variable "packages" {
  type    = string
  default = "open-vm-tools"
}

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "vsphere_server" {
  type = string
}

variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_folder" {
  type = string
}

variable "vsphere_vm_datastore" {
  type        = string
  description = "vSphere datastore where VM disks are provisioned."
}
variable "vsphere_iso_datastore" {
  type        = string
  description = "vSphere datastore where ISO files are stored."
}

variable "iso_path" {
  description = "ISO filename within the datastore including folder, e.g. 'rhel-9.7-x86_64-dvd.iso'."
  type        = string
}

variable "guest_os_type" {
  description = "vSphere guest OS identifier, e.g. 'rhel9_64Guest' or 'rhel8_64Guest'."
  type        = string
}

variable "image_name" {
  description = "Name for the resulting vSphere template, e.g. RHEL-9-CIS-L2-SERVER."
  type        = string
}

variable "scap_profile" {
  description = "SSG profile ID passed to the scap Ansible role."
  type        = string
}

variable "bootloader_user" {
  type    = string
  default = ""
}

variable "bootloader_password" {
  type    = string
  default = ""
}
