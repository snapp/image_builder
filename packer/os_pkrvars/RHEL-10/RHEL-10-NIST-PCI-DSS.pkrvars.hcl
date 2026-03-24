# Red Hat Enterprise Linux (RHEL) 10
# National Institute of Standards and Technology (NIST)
# Payment Card Industry (PCI) - Data Security Standard (DSS) (NIST 1800-16)
# http://doi.org/10.6028/NIST.SP.1800-16

image_name    = "RHEL-10-NIST-PCI-DSS"

# REDO `rhel10_64Guest` requires virtual hardware version 22 introduced in VCF 9.0
guest_os_type = "rhel9_64Guest"

iso_path  = "_RHEL/rhel-10.1-x86_64-dvd.iso"

scap_profile  = "xccdf_org.ssgproject.content_profile_pci-dss"

kernel_args = "audit=1 audit_backlog_limit=8192"

partitions = [
  { name = "root",          mountpoint = "/",              fstype = "xfs", size = 15360 }
]

packages = <<-EOT
# VMware Guest Tools for hypervisor integration
open-vm-tools

# Compliance remediations
aide             # CCE-90843-4 Filesystem Integrity
audispd-plugins  # CCE-83648-6 Plugins for the real-time interface to the audit subsystem
cryptsetup       # CCE-86612-9 Enable LUKS for dm-crypt Support
EOT

post_scripts = [
  {
    name = "Set Default firewalld Zone"
    description = "CCE-84023-1 Set Default firewalld Zone for Incoming Packets"
    content = <<-EOT
    # Set Default Zone to drop
    sed -i 's/^DefaultZone=.*/DefaultZone=drop/' /etc/firewalld/firewalld.conf

    # Allow Secure Shell (SSH) and Identity Management (IdM) in drop zone
    cat > /etc/firewalld/zones/drop.xml <<'EOF'
    <?xml version="1.0" encoding="utf-8"?>
    <zone target="DROP">
      <short>Drop</short>
      <description>Unsolicited incoming network packets are dropped. Incoming packets that are related to outgoing network connections are accepted. Outgoing network connections are allowed.</description>
      <service name="ssh"/>
      <service name="freeipa-4"/>
      <forward/>
    </zone>
    EOF
    EOT
  },
  {
    name = "National Institute of Standards and Technology (NIST) Payment Card Industry (PCI) - Data Security Standard (DSS)"
    description = "Apply NIST PCI DSS SCAP remediation"
    content = <<-EOT
    scap_results_dir="/var/log/scap"
    scap_report_prefix="scap-remediation"
    scap_timestamp="$(date +%Y%m%dT%H%M%S)"

    mkdir -p "$scap_results_dir"

    oscap xccdf eval \
    --remediate \
    --profile xccdf_org.ssgproject.content_profile_pci-dss \
    --results "$scap_results_dir/$scap_report_prefix-results-$scap_timestamp.xml" \
    --report "$scap_results_dir/$scap_report_prefix-report-$scap_timestamp.html" \
    /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
    EOT
  }
]
