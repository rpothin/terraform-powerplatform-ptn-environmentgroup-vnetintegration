# ptn-environmentgroup-vnetintegration

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-blue.svg)](https://registry.terraform.io/modules/rpothin/ptn-environmentgroup-vnetintegration/powerplatform/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This Terraform module extends [`ptn-environmentgroup`](https://registry.terraform.io/modules/rpothin/ptn-environmentgroup/powerplatform/latest) with Azure Virtual Network infrastructure for Power Platform network injection. It orchestrates [`ptn-enterprisepolicy-networkinjection`](https://registry.terraform.io/modules/rpothin/ptn-enterprisepolicy-networkinjection/powerplatform/latest) once per subscription tier (production and non-production), routing each tier to its own Azure subscription via provider aliases.

For each active tier, this module provisions:

- An Azure Resource Group
- Primary (and optional failover) Virtual Networks with PP-delegated and private-endpoint subnets
- Network Security Groups with configurable rules
- A `Microsoft.PowerPlatform/enterprisePolicies` ARM resource (NetworkInjection kind)
- Enterprise policy links to each Power Platform environment in the tier

## ⚠️ Prerequisites

> [!WARNING]
> Power Platform environments must be **Managed Environments** before this module can link enterprise policies. [`ptn-environmentgroup`](https://registry.terraform.io/modules/rpothin/ptn-environmentgroup/powerplatform/latest) v0.1.x sets `managed_environment_enabled = false` due to a confirmed provider bug (v4.1.0). You must enable Managed Environments separately or wait for the upstream fix before deploying this module.

> [!IMPORTANT]
> Only `Production` and `Sandbox` environment types are supported. `Trial` environments are not compatible with VNet injection and are rejected at plan time.

## NSG Outbound Rules Requirement

The built-in NSG posture includes `DenyAllOutBound`. Power Platform VNet injection **will not function** without explicit outbound allow rules for Microsoft service endpoints. You must provide `nsg_additional_rules` in each tier configuration. See the [complete example](./examples/complete) for a starting-point rule set and the [Power Platform VNet support documentation](https://learn.microsoft.com/en-us/power-platform/admin/vnet-support-overview) for the required endpoints.

## Provider Configuration

This module requires four provider aliases for multi-subscription isolation:

- `azurerm.production` — Azure provider scoped to the production subscription
- `azurerm.non_production` — Azure provider scoped to the non-production subscription
- `azapi.production` — AzAPI provider scoped to the production subscription
- `azapi.non_production` — AzAPI provider scoped to the non-production subscription

In single-subscription setups, point all aliases to the same subscription. Unused tier aliases (e.g. `azurerm.production` when no Production-type environments exist) must still be declared — the corresponding module call will be skipped (`count = 0`) and no API calls will be made.
