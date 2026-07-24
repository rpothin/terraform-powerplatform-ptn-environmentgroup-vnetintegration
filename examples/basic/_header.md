# Basic Example — Non-Production VNet Integration

This example demonstrates the minimum configuration to enable Power Platform VNet injection for
non-production (Sandbox) environments. A single enterprise policy is created in one Azure
subscription, with a primary virtual network.

## Prerequisites

Before applying this example:

1. Deploy [`ptn-environmentgroup`](https://registry.terraform.io/modules/rpothin/ptn-environmentgroup/powerplatform/latest) and note its `environments` output
2. Ensure all environments are **Managed Environments** (prerequisite for enterprise policy linking)
3. Configure OIDC credentials for both Azure and Power Platform providers

## NSG Rules

The `nsg_additional_rules` shown are the **minimum** required for Power Platform VNet injection.
Without outbound allow rules, the built-in `DenyAllOutBound` NSG rule will block PP connectivity.
Adjust priorities and add further rules as needed for your environment.
