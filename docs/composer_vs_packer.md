---
marp: true
theme: gaia
paginate: true
style: |
  :root {
    --color-background: #FFFFFF;
    --color-foreground: #151515;
    --color-highlight: #EE0000;
  }

  header {
    color: #EE0000;
    font-size: 18px;
  }

  section {
    font-size: 28px;
  }

  section::after {
    font-size: 18px;
  }

  h1 {
    color: #EE0000;
  }

  h2 {
    color: #A60000;
  }

  table {
    font-size: 22px;
    width: 100%;
  }

  table thead tr th {
    background-color: #F56E6E;
    color: #FFFFFF;
  }

  table tbody tr:nth-child(even) {
    background-color: #F5F5F5;
  }

  pre {
    background-color: #E0E0E0;
    font-size: 18px;
  }

  code {
    background-color: #E0E0E0;
    color: #151515;
    font-family: monospace;
  }

  ul li {
    margin-bottom: 6px;
  }

  .columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
  }

---
<!--
_class: lead
_paginate: false
-->

# RHEL Golden Image Creation
## Image Builder vs Packer

Comparing two approaches to building hardened Red Hat Enterprise Linux (RHEL)

---
<!--
header: "RHEL Golden Image: Image Builder vs Packer"
-->

## Agenda

1. What is a golden image?
2. Red Hat Image Builder (`osbuild` / `composer-cli`)
3. Red Hat Lightspeed Image Builder (hosted)
4. HashiCorp Packer (`vsphere-iso`)
5. How each approach works
6. Pros and cons
7. Side-by-side comparison
8. Recommendation

---

## What Is a Golden Image?

A **pre-built, pre-configured OS image** used as the baseline for all new virtual machines.

**Goals:**
- Consistent, reproducible OS state at first boot
- Security hardening baked in — CIS L1/L2, DISA STIG, NIST
- Reduced configuration drift from day one
- Faster provisioning — no manual installs or first-boot remediation

**Key principle:** the further left you push hardening, the smaller the attack window.

---

## Red Hat Image Builder

### `osbuild` / `composer-cli`

Red Hat's **native, supported** tool for composing customized RHEL images.

- Ships with RHEL — no external tooling required
- Declarative **TOML blueprints** define packages, partitions, users, and security profiles
- Builds run **server-side** on the Image Builder host — no VM is booted
- Integrates natively with **Red Hat Satellite** content views
- Output: OVA, VMDK, QCOW2, AMI, ISO, and more from a single blueprint

---

## How Image Builder Works

```
Blueprint (TOML)  ──►  composer-cli blueprints push
                                    │
                                    ▼
                        composer-cli compose start
                                    │
                                    ▼
                              osbuild (server-side)
                                    │
                          ┌─────────┼──────────────┐
                          ▼         ▼               ▼
                    RPM install  OpenSCAP      Partition
                    from Sat CV  remediation   layout (LVM)
                                    │
                                    ▼
                          OVA / VMDK / QCOW2
```

No VM is booted. The image is assembled directly from RPM content.

---

## Image Builder — Pros

- ✅ **Fully Red Hat supported** — covered by your RHEL subscription
- ✅ **No running VM required** — builds artifacts directly; faster, no cluster resources consumed
- ✅ **Native OpenSCAP** — CIS / STIG remediation applied at compose time, before first boot
- ✅ **Satellite integration** — pulls packages directly from content views and lifecycle environments
- ✅ **Multi-format output** — one blueprint produces OVA, QCOW2, AMI, and more
- ✅ **Declarative and versionable** — TOML blueprints live in Git
- ✅ **LVM partition layout** — CIS-required separate mount points defined in blueprint

---

## Image Builder — Cons

- ❌ **RHEL-only** — cannot build Windows, Ubuntu, or other non-RHEL targets
- ❌ **Requires a dedicated build host** — additional infrastructure to deploy and maintain *(see Lightspeed — next slide)*
- ❌ **Opaque build process** — `osbuild` internals are less visible than explicit task lists
- ❌ **Limited blueprint expressiveness** — no conditionals or loops; complex logic deferred to cloud-init or Ansible at first boot
- ❌ **vSphere integration is indirect** — outputs a VMDK/OVA that must be imported separately; no native vSphere template creation

---

## Red Hat Lightspeed Image Builder

### Hosted image builds — no local build server required

The same blueprint workflow, but the build infrastructure is **Red Hat's hosted service**
accessed through the **Hybrid Cloud Console** (`console.redhat.com`).

- **No build host to deploy or maintain** — Red Hat runs `osbuild` on your behalf
- Uses the **same TOML blueprints** you already version-control in Git
- Web UI wizard **and** a natural-language **MCP interface** (conversational blueprint creation)
- Outputs: QCOW2, AMI, Azure VHD, ISO, and more — delivered directly to cloud provider storage
- Built-in compliance policies: **CIS Level 1/2**, custom OpenSCAP profiles applied at compose time
- Integrates with Red Hat Lightspeed's compliance service for policy-driven image definitions

---

## How Lightspeed Image Builder Works

```
Blueprint (TOML or natural language via MCP)
                    │
                    ▼
        console.redhat.com / Hybrid Cloud Console
                    │
                    ▼
          Red Hat hosted osbuild pipeline
                    │
          ┌─────────┼──────────────┐
          ▼         ▼               ▼
    RPM install  OpenSCAP      Partition
    (CDN content) remediation   layout (LVM)
                    │
                    ▼
        Image delivered to cloud storage
        (S3, Azure Blob) or downloaded
```

No local build host. No VM boot. Your RHEL subscription covers the service.

---

## Lightspeed Image Builder — Pros

- ✅ **No build infrastructure** — eliminates the dedicated build host entirely
- ✅ **Red Hat hosted and supported** — covered under your RHEL subscription
- ✅ **Same blueprint format** — existing TOML blueprints work without changes
- ✅ **Native cloud delivery** — images pushed directly to AWS S3 or Azure Blob storage
- ✅ **OpenSCAP at compose time** — CIS / STIG applied before first boot, same as local Image Builder
- ✅ **MCP / natural language interface** — describe your image requirements in plain English
- ✅ **Compliance service integration** — policy requirements (packages, partitions, kernel args) applied automatically

---

## Lightspeed Image Builder — Cons

- ❌ **Requires internet access** — builds run on Red Hat's hosted platform; air-gapped environments cannot use it
- ❌ **No direct Satellite integration** — cannot pull from on-premises Satellite content views; uses Red Hat CDN content
- ❌ **Cloud output targets only** — does not produce native vSphere templates; VMDK/OVA must still be imported
- ❌ **Less control over build environment** — you cannot pin the `osbuild` version or inspect the build host directly
- ❌ **RHEL-only** — same constraint as local Image Builder; no Windows or community Linux targets

---

## HashiCorp Packer

An **open-source** tool that boots a real VM on target infrastructure,
configures it, then converts it to a reusable template.

- Boots RHEL from a **DVD ISO** stored in your vSphere datastore
- Drives OS installation via a **Kickstart file** served over HTTP
- Runs **Ansible** for post-install hardening and cleanup
- Converts the finished VM directly into a specific artifact (e.g. vSphere template)
- Runs from any CI runner or workstation with network access to vCenter

---

## How Packer Works

```
pkrvars.hcl  ──►  packer build
                       │
                       ▼
               Boot VM on vSphere (vsphere-iso)
                       │
               ┌───────┼────────────────┐
               ▼       ▼                ▼
          Kickstart   HTTP server    DVD ISO
          (OS install, LVM,          (all packages,
           packer user)               no network needed)
                       │
                       ▼
               Ansible provisioner
                       │
               ┌───────┼───────────┐
               ▼       ▼           ▼
          OpenSCAP   Satellite   Cleanup /
          remediation  register   seal image
                       │
                       ▼
               Convert VM → vSphere Template
```

---

## Packer — Pros

- ✅ **Infrastructure-native** — template is built directly on vSphere; no import step
- ✅ **Full transparency** — every build step is an explicit Kickstart directive or Ansible task
- ✅ **Flexible** — any Ansible role can run at build time; not limited to blueprint primitives
- ✅ **Multi-platform pattern** — same workflow applies to AWS, Azure, GCP, KVM with plugin swap
- ✅ **Existing toolchain** — fits naturally alongside Terraform, Ansible, and your CI pipeline
- ✅ **No dedicated build server** — runs from a CI runner or devcontainer

---

## Packer — Cons

- ❌ **Not Red Hat supported** — HashiCorp / community tooling; you own the pipeline
- ❌ **Boots a real VM** — slower builds; consumes cluster resources during build
- ❌ **Network dependency** — vSphere VM must reach back to Packer host for Kickstart HTTP
- ❌ **OpenSCAP is post-install** — remediation applied by Ansible after OS install, not at compose time
- ❌ **Kickstart maintenance** — `ks.cfg` must be kept in sync across RHEL major versions (8/9/10)
- ❌ **Platform-specific output** — a vSphere template cannot be directly reused for KVM or cloud

---

## Side-by-Side Comparison

| | Image Builder (local) | Lightspeed Image Builder | Packer |
|---|---|---|---|
| **Build model** | Server-side, on-prem | Hosted by Red Hat | Boot VM → configure → snapshot |
| **Build infrastructure** | Dedicated build host | None (Red Hat hosted) | CI runner or workstation |
| **Target platforms** | RHEL only | RHEL only | Any (vSphere, AWS, Azure, KVM…) |
| **Config language** | TOML blueprint | TOML blueprint / MCP (natural language) | HCL + Kickstart + Ansible |
| **OpenSCAP hardening** | At compose time | At compose time | Post-install via Ansible |
| **Red Hat support** | ✅ Yes | ✅ Yes | ❌ Community |
| **Build speed** | Faster — no VM boot | Faster — no VM boot | Slower — full OS install |
| **vSphere output** | VMDK/OVA (import required) | VMDK/OVA (import required) | Native vSphere template |
| **Satellite integration** | Native | ❌ CDN content only | Via Ansible registration |
| **Air-gap / on-prem** | ✅ Yes | ❌ Requires internet | ✅ Yes |
| **Transparency** | Low (osbuild internals) | Low (hosted build) | High (explicit task list) |
| **Multi-OS support** | No | No | Yes |

---

## Recommendation

- Use **Lightspeed Image Builder (hosted)**  when:
  - You want a **Red Hat supported, zero-infrastructure** pipeline
  - Your environment has **internet access** to `console.redhat.com`
- Use **Image Builder (local)** when:
  - You operate in an **air-gapped or on-prem-only** environment
  - **Satellite content view** pinning is required — builds must pull from internal repos
- Use **Packer** when:
  - Your pipeline already uses **Terraform + Ansible + CI** and consistency matters
  - Building **non-RHEL targets** alongside RHEL in the same pipeline

---

## Resources

**Red Hat Image Builder**
- [Image Builder documentation — Red Hat Customer Portal](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/index)

**Lightspeed Image Builder**
- [Hybrid Cloud Console — Images](https://console.redhat.com/insights/image-builder)
- [How-to save, edit, and share blueprints in Lightspeed Image Builder](https://www.redhat.com/en/blog/blueprints-with-Lightspeed-image-builder)

**HashiCorp Packer**
- [Packer Plugin: vsphere-iso ](https://github.com/vmware/packer-plugin-vsphere/tree/main/docs)
- [Packer HCL2 configuration language](https://developer.hashicorp.com/packer/docs/templates/hcl_templates)

---
<!--
_class: lead
_paginate: false
-->

# Questions?
