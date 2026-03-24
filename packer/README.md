# Packer — RHEL Image Templates

This directory contains [HashiCorp Packer](https://www.packer.io/) templates that build hardened RHEL images directly on target infrastructure, driven by Kickstart and post-build Ansible SCAP remediation.

## Directory Layout

```
packer/
├── vsphere.pkrvars.hcl.example # Copy, fill in, and pass as -var-file (gitignored when filled in)
├── common/
│   ├── ansible/                # Post-build Ansible playbooks (prepare, SCAP remediation, clean)
│   └── kickstart/              # Shared Kickstart template (pkrtpl.hcl)
├── os_pkrvars/                 # Per-profile variable files, organized by RHEL version
│   ├── RHEL-8/
│   ├── RHEL-9/
│   └── RHEL-10/
└── templates/
    └── RHEL/
        └── vsphere/            # vSphere-specific Packer template
```

## Available Templates

| Template | Platforms | Details |
|---|---|---|
| RHEL / vSphere | VMware vSphere | [templates/RHEL/vsphere/](templates/RHEL/vsphere/README.md) |

## Available Profiles

| Profile | RHEL 8 | RHEL 9 | RHEL 10 |
|---|:---:|:---:|:---:|
| CIS Level 1 Server | ✓ | ✓ | ✓ |
| CIS Level 1 Workstation | ✓ | ✓ | ✓ |
| CIS Level 2 Server | ✓ | ✓ | ✓ |
| CIS Level 2 Workstation | ✓ | ✓ | ✓ |
| DISA STIG | ✓ | ✓ | ✓ |
| DISA STIG (GUI) | ✓ | ✓ | ✓ |
| NIST HIPAA | ✓ | ✓ | ✓ |
| NIST PCI-DSS | ✓ | ✓ | ✓ |
| NIST CUI | ✓ | ✓ | |

## Quick Start (vSphere)

Each build requires two variable files:

| File | What it sets |
|---|---|
| `os_pkrvars/<RHEL-version>/<profile>.pkrvars.hcl` | OS version, ISO path, partitioning, SCAP profile |
| `vsphere.pkrvars.hcl` (your copy) | vSphere connection details and `packer_http_ip` (if necessary) |

**1. Create your environment vars file**

```bash
# Edit vsphere.pkrvars.hcl and fill in your values — it is gitignored
cp packer/vsphere.pkrvars.hcl.example packer/vsphere.pkrvars.hcl
```

**2. Initialize Packer plugins** (once per checkout)

```bash
cd packer
packer init templates/RHEL/vsphere/
```

**3. Run a build**

```bash
cd packer
packer build \
  -var-file vsphere.pkrvars.hcl \
  -var-file os_pkrvars/RHEL-10/RHEL-10-CIS-L2-SERVER.pkrvars.hcl \
  templates/RHEL/vsphere
```

Swap the `os_pkrvars/` file to build a different RHEL version or security profile.

## Variable Reference

See [templates/RHEL/vsphere/](templates/RHEL/vsphere/README.md) for a full description of all variables, including `packer_http_ip` and when you may need to override it.

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) ≥ 1.10
- RHEL DVD ISO uploaded to the vSphere ISO datastore (filename must match `iso_path` in the pkrvars file)
- Network reachability from the vSphere cluster back to the machine running Packer (required for the HTTP Kickstart server — see `packer_http_ip` in the variable reference)
