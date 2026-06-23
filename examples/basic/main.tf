module "this" {
  source = "rpothin/ptn-environmentgroup-vnetintegration/powerplatform"

  enterprise_policy_location = var.enterprise_policy_location
  environment_group_name     = var.environment_group_name
  environments               = var.environments

  non_production_tier = {
    resource_group_location = var.resource_group_location

    primary_vnet_config = {
      location       = var.primary_vnet_location
      address_space  = "10.0.0.0/16"
      pp_subnet_cidr = "10.0.0.0/24"
      pe_subnet_cidr = "10.0.1.0/24"
    }

    # Minimum outbound rules required for Power Platform VNet injection.
    # See https://learn.microsoft.com/en-us/power-platform/admin/vnet-support-overview
    nsg_additional_rules = [
      {
        name                       = "AllowPowerPlatformInfrastructureOutbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        destination_port_range     = "443"
        destination_address_prefix = "PowerPlatformInfrastructure"
        description                = "Required: Allow Power Platform infrastructure outbound (VNet injection prerequisite)"
      },
      {
        name                       = "AllowAzureActiveDirectoryOutbound"
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        destination_port_range     = "443"
        destination_address_prefix = "AzureActiveDirectory"
        description                = "Required: Allow Azure AD outbound for Power Platform authentication"
      },
      {
        name                       = "AllowAzureMonitorOutbound"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        destination_port_range     = "443"
        destination_address_prefix = "AzureMonitor"
        description                = "Required: Allow Azure Monitor outbound for diagnostics"
      }
    ]
  }

  tags = var.tags

  providers = {
    azapi.non_production   = azapi.non_production
    azapi.production       = azapi.production
    azurerm.non_production = azurerm.non_production
    azurerm.production     = azurerm.production
    powerplatform          = powerplatform
  }
}