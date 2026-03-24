locals {
  build_date   = formatdate("YYYY-MM-DD HH:mm", timestamp())
  vm_name      = "${var.image_name}-${formatdate("YYYYMMDD_HHmm", timestamp())}"
  iso_path     = "[${var.vsphere_iso_datastore}] ${var.iso_path}"
  ssh_user     = "packer"
  ssh_password = "PackerB00tStrap!"
}
