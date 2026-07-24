# Complete Example — Dual-Subscription VNet Integration with Full Features

This example demonstrates a full enterprise configuration with both production and non-production
tier VNet integration across separate Azure subscriptions.

It shows:

- **Dual-subscription isolation** — production and non-production environments deployed to separate Azure subscriptions via provider aliases
- **Primary + failover VNet** pair per tier for high availability
- **Full NSG rule set** for Power Platform VNet injection connectivity
- **Private DNS zones** for private endpoint connectivity
- **Custom resource naming** with explicit resource group name overrides
- **Comprehensive tagging** strategy

## Prerequisites

1. Deploy [`ptn-environmentgroup`](https://registry.terraform.io/modules/rpothin/ptn-environmentgroup/powerplatform/latest) with at least one Production and one Sandbox environment
2. Ensure all environments are **Managed Environments**
3. Configure separate Azure subscriptions for production and non-production workloads
4. Configure OIDC credentials for Azure and Power Platform providers

## CIDR Planning

Production and non-production tiers use non-overlapping address spaces:

- **Non-production primary**: `10.0.0.0/16` (failover: `10.1.0.0/16`)
- **Production primary**: `10.10.0.0/16` (failover: `10.11.0.0/16`)
