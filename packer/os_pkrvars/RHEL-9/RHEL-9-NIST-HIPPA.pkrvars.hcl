# Red Hat Enterprise Linux (RHEL) 9
# National Institute of Standards and Technology (NIST)
# Implementing the Health Insurance Portability and Accountability Act (HIPAA) Security Rule (NIST 800-66)
# https://doi.org/10.6028/NIST.SP.800-66r2

image_name    = "RHEL-9-NIST-HIPAA"

guest_os_type = "rhel9_64Guest"

iso_path  = "_RHEL/rhel-9.7-x86_64-dvd.iso"

scap_profile  = "xccdf_org.ssgproject.content_profile_hipaa"

kernel_args = "audit=1 audit_backlog_limit=8192"

# CCE-83849-0 Set Boot Loader Password in grub2
bootloader_password = "grub"

partitions = [
  { name = "root",          mountpoint = "/",              fstype = "xfs", size = 15360 }
]

post_scripts = [
  {
    name = "National Institute of Standards and Technology (NIST) Health Insurance Portability and Accountability Act (HIPAA)"
    description = "Apply NIST HIPAA SCAP remediation"
    content = <<-EOT
    scap_results_dir="/var/log/scap"
    scap_report_prefix="scap-remediation"
    scap_timestamp="$(date +%Y%m%dT%H%M%S)"

    mkdir -p "$scap_results_dir"

    oscap xccdf eval \
    --remediate \
    --profile xccdf_org.ssgproject.content_profile_hipaa \
    --results "$scap_results_dir/$scap_report_prefix-results-$scap_timestamp.xml" \
    --report "$scap_results_dir/$scap_report_prefix-report-$scap_timestamp.html" \
    /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
    EOT
  }
]
