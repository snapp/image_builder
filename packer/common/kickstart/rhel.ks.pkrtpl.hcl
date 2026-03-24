# RHEL Kickstart - DVD ISO install
# Fully offline - all packages sourced from mounted ISO.
# No credentials, no org-specific URLs.

# Install from a mounted DVD ISO
cdrom

# Lock root account
rootpw --lock

# Use text mode install
text

# Do not configure the X Window System
skipx

# Disable the setup agent on first boot
firstboot --disabled

# Agree to EULA
eula --agreed

# System language
lang en_US.UTF-8

# System keyboard
keyboard us

# System timezone
timezone ${timezone} --utc

# Network configuration
network --bootproto=dhcp --device=link --activate --onboot=on

# Post installation reboot
reboot --eject

# System authorization information
authselect --enableshadow --passalgo=sha512 --kickstart

# Selinux configuration
selinux --enforcing

# Firewall configuration
firewall --enabled --service=ssh

# System bootloader configuration
bootloader --timeout=0 --append="console=tty0 ${kernel_args}"

# Partition clearing instructions
zerombr
clearpart --all --initlabel

# Setup partitions
part /boot/efi   --fstype=efi  --size=200   --asprimary
part /boot       --fstype=xfs  --size=1024  --label=boot --asprimary
part pv.01       --size=1      --grow

volgroup rhel pv.01

%{ for partition in partitions ~}
logvol ${partition.mountpoint} --vgname=rhel --name=${partition.name} --fstype=${partition.fstype} --size=${partition.size}

%{ endfor ~}

# RHEL DVD ISO (BaseOS + AppStream) Packages
%packages --ignoremissing
@^minimal-environment

${packages}

# First-boot OS configuration
cloud-init

# Compliance tooling for Security Content Automation Protocol (SCAP) remediation
openscap-scanner
scap-security-guide

# Identity Management (IdM) tooling
ipa-client
oddjob
oddjob-mkhomedir

# Enable support for checking if reboot is required
dnf-utils

# Remove packages that increase attack surface
-aic94xx-firmware
-alsa-firmware
-alsa-sof-firmware
-alsa-tools-firmware
-atmel-firmware
-bfa-firmware
-dracut-config-rescue
-fedora-release-notes
-fprintd-pam
-intltool
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl*firmware
-libertas-usb8388-firmware
-mcelog
-microcode_ctl
-netronome-firmware
-plymouth
-plymouth-core-libs
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-radeon-firmware
-rt61pci-firmware
-rt73usb-firmware
-smartmontools
-usbutils
-xorg-x11-drv-ati-firmware
-zd1211-firmware
%end

%{ for script in post_scripts ~}
# Post: ${script.description}
%post
#!/usr/bin/env bash
set -euo pipefail

# Log script output
exec >> /root/ks-post.log 2>&1

echo "==> ${script.name}"

${script.content}

echo "==> ${script.name} done"
%end

%{ endfor ~}

%{ if bootloader_password != "" ~}
# Post: Set Boot Loader User and Password
%post
#!/usr/bin/env bash
set -euo pipefail

exec >> /root/ks-post.log 2>&1

echo "==> Boot loader account"

%{ if bootloader_user != "" ~}
if [[ -f /etc/grub.d/01_users ]]; then
  sed -i '/superusers/{s/root/${bootloader_user}/}' /etc/grub.d/01_users
  sed -i '/password_pbkdf2/{s/root/${bootloader_user}/}' /etc/grub.d/01_users
fi
%{ endif ~}

# Generate grub2 password
printf '%s\n%s\n' '${bootloader_password}' '${bootloader_password}' | grub2-mkpasswd-pbkdf2 | sed -n '/grub/{s/.*grub.pbkdf2/GRUB2_PASSWORD=grub.pbkdf2/;p;}' | tee /boot/efi/EFI/redhat/user.cfg > /boot/grub2/user.cfg
chmod 0600 /boot/grub2/user.cfg /boot/efi/EFI/redhat/user.cfg

# Regenerate grub config
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "==> Boot loader account done"
%end
%{ endif ~}

# Post: Provisioner account
%post
#!/usr/bin/env bash
set -euo pipefail

echo "==> Provisioner account"
useradd --uid 57100 --create-home --comment "Packer Provisioner Account" "${ssh_user}"
echo "${ssh_user}:${ssh_password}" | chpasswd
# CCE-86576-6 requires TYPE=sysadm_t ROLE=sysadm_r which is only permitted for staff_u (and sysadm_u) SELinux users.
echo "${ssh_user} ALL=(ALL) TYPE=sysadm_t ROLE=sysadm_r ALL" > "/etc/sudoers.d/${ssh_user}"
semanage login -a -s staff_u "${ssh_user}"
chmod 0440 "/etc/sudoers.d/${ssh_user}"

# Allow password auth for provisioner account
mkdir -p /etc/ssh/sshd_config.d
grep -qE '^Include /etc/ssh/sshd_config\.d/' /etc/ssh/sshd_config || echo 'Include /etc/ssh/sshd_config.d/*.conf' >> /etc/ssh/sshd_config
cat > /etc/ssh/sshd_config.d/99-packer-provisioner.conf << 'EOF'
Match User ${ssh_user}
    PasswordAuthentication yes
EOF
chmod 0600 /etc/ssh/sshd_config.d/99-packer-provisioner.conf

echo "==> Provisioner account done"
%end
