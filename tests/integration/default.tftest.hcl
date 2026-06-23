# Integration tests — uses real providers, requires OIDC credentials.
#
# Prerequisites:
#   ARM_USE_OIDC=true
#   POWER_PLATFORM_TENANT_ID=<tenant-id>
#   POWER_PLATFORM_CLIENT_ID=<client-id>
#   ARM_TENANT_ID=<azure-tenant-id>
#   ARM_CLIENT_ID=<azure-client-id>
#   TF_VAR_subscription_id=<azure-subscription-id>
#
# These tests create real Azure and Power Platform resources.
# Resources are automatically destroyed after test completion.
#
# IMPORTANT: Environments must be Managed Environments before running.
# ptn-environmentgroup v0.1.x sets managed_environment_enabled=false due to a
# provider bug. Enable Managed Environments manually before these tests.

variables {
  subscription_id = "00000000-0000-0000-0000-000000000000" # Override via TF_VAR_subscription_id
}

run "creates_non_production_vnet_integration" {
  command = apply

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "tftest-vnet-integration"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001" # Replace with real environment ID
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
      nsg_additional_rules = [
        {
          name                       = "AllowPowerPlatformInfrastructureOutbound"
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          destination_address_prefix = "PowerPlatformInfrastructure"
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
