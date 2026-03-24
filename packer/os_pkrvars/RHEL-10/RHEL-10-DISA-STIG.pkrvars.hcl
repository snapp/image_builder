# Red Hat Enterprise Linux (RHEL) 10
# Defense Information Systems Agency (DISA) Security Technical Implementation Guide (STIG)
# https://public.cyber.mil/stigs

# NOTE|2026-04-02| RHEL 10 DISA STIG benchmark may not yet be published; verify profile
# availability in ssg-rhel10-ds.xml before building

image_name    = "RHEL-10-DISA-STIG"

# REDO `rhel10_64Guest` requires virtual hardware version 22 introduced in VCF 9.0
guest_os_type = "rhel9_64Guest"

iso_path  = "_RHEL/rhel-10.1-x86_64-dvd.iso"

scap_profile  = "xccdf_org.ssgproject.content_profile_stig"

# audit                Enable kernel audit subsystem before any userspace processes start
# audit_backlog_limit  Increase kernel audit event backlog queue size
# fips                 Enforce FIPS 140 approved cryptographic algorithms only
# slub_debug           Poison freed pages at SLUB allocator level
# page_poison          Poison freed pages at Page allocator level
# vsyscall             Disable legacy vsyscall interface
# pti                  Enable Kernel Page Table Isolation
kernel_args = "audit=1 audit_backlog_limit=8192 fips=1 slub_debug=P page_poison=1 vsyscall=none pti=on"

# CCE-87370-3 Set the Boot Loader Admin Username to a Non-Default Value
bootloader_user = "grub"

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
aide             # CCE-90843-4 Filesystem Integrity
audispd-plugins  # CCE-83648-6 Plugins for the real-time interface to the audit subsystem
fapolicyd        # CCE-84224-5 File Access Policy Daemon
gnutls-utils     # CCE-83494-5 SSL, TLS, and DTLS protocols
libreswan        # CCE-84068-6 Secure tunnels via IPsec and IKE
opensc           # CCE-83595-9 Multifactor Authentication
pkcs11-provider  # CCE-86642-6 Smart Card Support
rsyslog-gnutls   # CCE-83987-8 rsyslog daemon TLS support
s-nail           # CCE-86608-7 Mail server for sending email
sssd             # CCE-88372-8 System Security Services (SSS)
usbguard         # CCE-84203-9 Rogue USB device protection
EOT

post_scripts = [
  {
    name = "Set Default firewalld Zone"
    description = "CCE-87823-1 Set Default firewalld Zone for Incoming Packets"
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
    name = "Enable FIPS Mode"
    description = "Federal Information Processing Standards (FIPS)"
    content = <<-EOT
    fips-mode-setup --enable
    EOT
  },
  {
    name = "Apply DISA STIG SCAP remediation"
    description = "Defense Information Systems Agency (DISA) Security Technical Implementation Guide (STIG)"
    content = <<-EOT
    scap_results_dir="/var/log/scap"
    scap_report_prefix="scap-remediation"
    scap_timestamp="$(date +%Y%m%dT%H%M%S)"

    mkdir -p "$scap_results_dir"

    oscap xccdf eval \
    --remediate \
    --profile xccdf_org.ssgproject.content_profile_stig \
    --results "$scap_results_dir/$scap_report_prefix-results-$scap_timestamp.xml" \
    --report "$scap_results_dir/$scap_report_prefix-report-$scap_timestamp.html" \
    /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
    EOT
  }
]
