# Integration tests — uses real providers, requires OIDC credentials.
#
# Prerequisites (environment variables):
#   ARM_USE_OIDC=true
#   ARM_TENANT_ID=<azure-tenant-id>
#   ARM_CLIENT_ID=<azure-client-id>
#   ARM_SUBSCRIPTION_ID=<azure-subscription-id>
#   POWER_PLATFORM_USE_OIDC=true
#   POWER_PLATFORM_TENANT_ID=<tenant-id>
#   POWER_PLATFORM_CLIENT_ID=<client-id>
#
# The `provider` blocks below intentionally omit explicit credentials — the
# azurerm/azapi/powerplatform providers auto-detect GitHub Actions OIDC from
# the ARM_*/POWER_PLATFORM_* environment variables above. This single Azure
# subscription is used for both the "production" and "non_production" aliases
# because this test only exercises the non-production tier (production module
# call has count = 0), but all four aliases must still be declared to satisfy
# the module's configuration_aliases contract.
#
# These tests create real Azure and Power Platform resources.
# Resources are automatically destroyed after test completion.
#
# IMPORTANT: Environments must be Managed Environments before running.
# ptn-environmentgroup v0.1.x sets managed_environment_enabled=false due to a
# provider bug. Enable Managed Environments manually before these tests.
#
# This module operates on pre-existing Power Platform environments (typically
# the output of ptn-environmentgroup) rather than creating them, so the
# environment id below must reference a real, existing Managed Environment.

provider "azapi" {
  alias = "non_production"
}

provider "azapi" {
  alias = "production"
}

provider "azurerm" {
  alias = "non_production"

  features {}
}

provider "azurerm" {
  alias = "production"

  features {}
}

provider "powerplatform" {}

run "creates_non_production_vnet_integration" {
  command = apply

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "tftest-vnet-integration"
    environments = {
      dev = {
        id           = "36f603f9-0af2-e33d-98a5-64b02c1bac19"
        display_name = "tftest-dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location      = "eastus"
        address_space = "10.0.0.0/16"
      }
      # NOTE: the failover region must be a location supported for VNet
      # injection under the "unitedstates" enterprise policy location
      # (valid options: westus, eastus, eastus2, centralus) — westus2 is
      # not supported and will fail enterprise policy creation.
      failover_vnet_config = {
        location      = "westus"
        address_space = "10.1.0.0/16"
      }
      nsg_additional_rules = [
        {
          name                       = "AllowPowerPlatformInfraOutbound"
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          destination_address_prefix = "PowerPlatformInfra"
          description                = "Required: Power Platform infrastructure outbound"
        }
      ]
    }
  }

  assert {
    condition     = output.non_production_primary_vnet_id != null
    error_message = "Non-production primary VNet should be created."
  }

  assert {
    condition     = output.non_production_resource_group_name == "rg-tftest-vnet-integration-non-production-vnet"
    error_message = "Non-production resource group name should follow the computed naming convention."
  }

  assert {
    condition     = output.production_enterprise_policy_id == null
    error_message = "Production enterprise policy should not be created when no production environments exist."
  }
}
