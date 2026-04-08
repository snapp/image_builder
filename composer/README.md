# Composer — Image Builder Blueprints

This directory contains [Red Hat Image Builder](https://console.redhat.com/insights/image-builder) blueprints for building opinionated RHEL golden images.

Some blueprints target [Gold Image](https://access.redhat.com/documentation/en-us/subscription_central/1-latest/html-single/red_hat_cloud_access_reference_guide/index#understanding-gold-images_cloud-access) replicas. Others are pre-hardened to a specific security profile and require [Image Builder installed in your environment](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/composing_a_customized_rhel_system_image/index#installing-composer_composing-a-customized-rhel-system-image).

## Directory Layout

```
composer/
└── blueprints/
    ├── RHEL-8/     # RHEL 8 blueprints
    ├── RHEL-9/     # RHEL 9 blueprints
    └── RHEL-10/    # RHEL 10 blueprints
```

## Available Profiles

| Profile | RHEL 8 | RHEL 9 | RHEL 10 |
|---|:---:|:---:|:---:|
| Base (Gold Image replica) | ✓ | ✓ | ✓ |
| CIS Level 1 Server | ✓ | ✓ | ✓ |
| CIS Level 1 Workstation | ✓ | ✓ | ✓ |
| CIS Level 2 Server | ✓ | ✓ | ✓ |
| CIS Level 2 Workstation | ✓ | ✓ | ✓ |
| DISA STIG | ✓ | ✓ | ✓ |
| DISA STIG (GUI) | ✓ | ✓ | ✓ |
| NIST HIPAA | ✓ | ✓ | ✓ |
| NIST PCI-DSS | ✓ | ✓ | ✓ |
| NIST CUI | ✓ | ✓ | |

## Using Blueprints

Push a blueprint to your Image Builder host with `composer-cli`:

```bash
composer-cli blueprints push blueprints/RHEL-10/RHEL-10-CIS-L2-SERVER.toml
```

Start a compose (adjust output type as needed):

```bash
composer-cli compose start RHEL-10-CIS-L2-SERVER qcow2
```

## Reference Documentation

- [Learn about Red Hat Enterprise Linux and Insights image builders](https://access.redhat.com/articles/7076676)
- [Composing a customized RHEL system image](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/composing_a_customized_rhel_system_image/index)
- [Composing, installing, and managing RHEL for Edge images (RPM-OSTree)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/composing_installing_and_managing_rhel_for_edge_images/index)
- [Creating pre-hardened images with RHEL image builder OpenSCAP integration](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/composing_a_customized_rhel_system_image/index#assembly_creating-pre-hardened-images-with-image-builder-openscap-integration_composing-a-customized-rhel-system-image)
- [Image Builder User Guide](https://osbuild.org/docs/user-guide/introduction)
- [Image Builder Blueprint Reference](https://osbuild.org/docs/user-guide/blueprint-reference)
