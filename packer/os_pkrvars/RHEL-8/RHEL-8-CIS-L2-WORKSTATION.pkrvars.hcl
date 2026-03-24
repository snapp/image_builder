# Red Hat Enterprise Linux (RHEL) 8
# Center for Internet Security® (CIS) Level 2 Workstation
# https://www.cisecurity.org/cis-benchmarks
# https://resources.cisecurity.org/benchmarks

image_name    = "RHEL-8-CIS-L2-WORKSTATION"

guest_os_type = "rhel8_64Guest"

iso_path  = "_RHEL/rhel-8.10-x86_64-dvd.iso"

scap_profile  = "xccdf_org.ssgproject.content_profile_cis_workstation_l2"

kernel_args = "audit=1 audit_backlog_limit=8192"

# CCE-83849-0 Set Boot Loader Password in grub2
bootloader_password = "grub"

partitions = [
  { name = "home",          mountpoint = "/home",          fstype = "xfs", size = 1024 },
  { name = "root",          mountpoint = "/",              fstype = "xfs", size = 8192 },
  { name = "tmp",           mountpoint = "/tmp",           fstype = "xfs", size = 1024 },
  { name = "var_log_audit", mountpoint = "/var/log/audit", fstype = "xfs", size = 1024 },
  { name = "var_log",       mountpoint = "/var/log",       fstype = "xfs", size = 2048 },
  { name = "var_tmp",       mountpoint = "/var/tmp",       fstype = "xfs", size = 1024 },
  { name = "var",           mountpoint = "/var",           fstype = "xfs", size = 3072 }
]

packages = <<-EOT
# VMware Guest Tools for hypervisor integration
open-vm-tools

# Compliance remediations
aide                    # CCE-90843-4 Filesystem Integrity
EOT

post_scripts = [
  {
    name = "Center for Internet Security® (CIS) Level 2 Workstation"
    description = "Apply CIS L2 Workstation SCAP remediation"
    content = <<-EOT
    scap_results_dir="/var/log/scap"
    scap_report_prefix="scap-remediation"
    scap_timestamp="$(date +%Y%m%dT%H%M%S)"

    mkdir -p "$scap_results_dir"

    oscap xccdf eval \
    --remediate \
    --profile xccdf_org.ssgproject.content_profile_cis_workstation_l2 \
    --results "$scap_results_dir/$scap_report_prefix-results-$scap_timestamp.xml" \
    --report "$scap_results_dir/$scap_report_prefix-report-$scap_timestamp.html" \
    /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
    EOT
  }
]
