# Red Hat Enterprise Linux (RHEL) 9
# National Institute of Standards and Technology (NIST)
# Protecting Controlled Unclassified Information (CUI) in Nonfederal Systems and Organizations (NIST 800-171)
# Control Baselines for Information Systems and Organizations (NIST 800-53)
# https://doi.org/10.6028/NIST.SP.800-171r3
# https://doi.org/10.6028/NIST.SP.800-53B
# https://doi.org/10.6028/NIST.FIPS.200

image_name    = "RHEL-9-NIST-CUI"

guest_os_type = "rhel9_64Guest"

iso_path  = "_RHEL/rhel-9.7-x86_64-dvd.iso"

scap_profile  = "xccdf_org.ssgproject.content_profile_cui"

kernel_args = "audit=1 audit_backlog_limit=8192 fips=1"

# CCE-83849-0 Set Boot Loader Password in grub2
bootloader_password = "grub"

partitions = [
  { name = "root",          mountpoint = "/",              fstype = "xfs", size = 14336 },
  { name = "var_log_audit", mountpoint = "/var/log/audit", fstype = "xfs", size = 1024 }
]

packages = <<-EOT
# VMware Guest Tools for hypervisor integration
open-vm-tools

# Compliance remediations
dnf-automatic    # CCE-83454-9 CLI for automatic regular execution
fapolicyd        # CCE-84224-5 File Access Policy Daemon
gnutls-utils     # CCE-83494-5 SSL, TLS, and DTLS protocols
usbguard         # CCE-84203-9 Rogue USB device protection
EOT

post_scripts = [
  {
    name = "Enable FIPS Mode"
    description = "Federal Information Processing Standards (FIPS)"
    content = <<-EOT
    fips-mode-setup --enable
    EOT
  },
  {
    name = "Apply NIST CUI SCAP remediation"
    description = "National Institute of Standards and Technology (NIST) Controlled Unclassified Information (CUI)"
    content = <<-EOT
    scap_results_dir="/var/log/scap"
    scap_report_prefix="scap-remediation"
    scap_timestamp="$(date +%Y%m%dT%H%M%S)"

    mkdir -p "$scap_results_dir"

    oscap xccdf eval \
    --remediate \
    --profile xccdf_org.ssgproject.content_profile_cui \
    --results "$scap_results_dir/$scap_report_prefix-results-$scap_timestamp.xml" \
    --report "$scap_results_dir/$scap_report_prefix-report-$scap_timestamp.html" \
    /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
    EOT
  }
]
