# Packer Template: vSphere — Red Hat Enterprise Linux (RHEL)

This Packer template builds a RHEL golden image on VMware vSphere from a pre-uploaded DVD ISO.

All packages are sourced from the ISO — no network repo or Satellite needed.

RHEL-version-specific values (guest OS type, ISO path, image name, partitioning, SCAP profile) are set via the `os_pkrvars/` files in the `packer/` root. vSphere connection details and `packer_http_ip` are set in your local `vsphere.pkrvars.hcl`.

## Using this template

**From the `packer/` root directory:**

```bash
packer init templates/RHEL/vsphere/

packer build \
  -var-file vsphere.pkrvars.hcl \
  -var-file os_pkrvars/RHEL-10/RHEL-10-CIS-L2-SERVER.pkrvars.hcl \
  templates/RHEL/vsphere
```

See the [packer/ README](../../README.md) for setup steps including how to create `vsphere.pkrvars.hcl` from the provided example file.

## Variable Reference

### vSphere connection

| Variable | Description |
|---|---|
| `vsphere_server` | vCenter hostname or IP (without `https://`) |
| `vsphere_user` | vSphere username |
| `vsphere_password` | vSphere password |
| `vsphere_datacenter` | Datacenter name |
| `vsphere_cluster` | Cluster name |
| `vsphere_network` | Port group name for the build VM |
| `vsphere_folder` | vSphere folder where the finished template is stored |
| `vsphere_vm_datastore` | Datastore for build VM disks |
| `vsphere_iso_datastore` | Datastore where the RHEL DVD ISO is stored |

### Build host network

| Variable | Description |
|---|---|
| `packer_http_ip` | IP of the machine running `packer build`, reachable from the vSphere cluster |

During the build, Packer serves the Kickstart file over HTTP (default port range 8000–9000). The VM being built must be able to reach this address.

Set `packer_http_ip` to the IP of the NIC on the same L2/L3 segment as your vSphere cluster. On a multi-homed host, pick the NIC that vSphere can route to — not necessarily the default interface.

### OS / profile (set via `os_pkrvars/`)

| Variable | Description |
|---|---|
| `iso_path` | ISO filename within the ISO datastore (e.g. `_RHEL/rhel-10.1-x86_64-dvd.iso`) |
| `guest_os_type` | vSphere guest OS identifier (e.g. `rhel9_64Guest`) |
| `image_name` | Name for the resulting vSphere template |
| `scap_profile` | SSG profile ID for SCAP remediation |
| `kernel_args` | Extra kernel arguments appended to the Kickstart bootloader line |
| `partitions` | List of LVM logical volumes to create (name, mountpoint, fstype, size MiB) |
| `packages` | Newline-delimited list of extra packages to install via Kickstart |
| `post_scripts` | List of shell scripts to run inside the VM after provisioning |
| `bootloader_user` | Bootloader username (optional, for grub2 password protection) |
| `bootloader_password` | Bootloader password (optional) |
