# Red Hat Image Builder

[![GitHub License](https://img.shields.io/github/license/snapp/image_builder)](https://github.com/snapp/image_builder/blob/main/LICENSE)
[![CI](https://github.com/snapp/image_builder/actions/workflows/main.yml/badge.svg)](https://github.com/snapp/image_builder/actions/workflows/main.yml)

This repository provides opinionated [Red Hat Enterprise Linux (RHEL)](https://access.redhat.com/products/discover-red-hat-enterprise-linux) golden images via two complementary build methods:

| Method | Description | Folder |
|---|---|---|
| **Composer** | Image Builder blueprints (TOML) for RHEL golden and hardened images | [composer/](composer/) |
| **Packer** | HashiCorp Packer templates that build RHEL images directly on infrastructure | [packer/](packer/) |

> [!WARNING]
>
> This code is NOT supported by Red Hat and may not work as expected.
>
> Red Hat does not guarantee its correctness, reliability, or performance.
>
> Use at your own risk!

## Licensing

GNU General Public License v3.0 or later

See [LICENSE](https://www.gnu.org/licenses/gpl-3.0.txt) to see the full text.
