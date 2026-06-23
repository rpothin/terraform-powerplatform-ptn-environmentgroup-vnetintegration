locals {
  # Full NSG rule set for Power Platform VNet injection.
  # See https://learn.microsoft.com/en-us/power-platform/admin/vnet-support-overview
  pp_nsg_rules = [
    {
      name                       = "AllowPowerPlatformInfrastructureOutbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_address_prefix = "PowerPlatformInfrastructure"
      description                = "Required: Power Platform infrastructure outbound"
    },
    {
      name                       = "AllowAzureActiveDirectoryOutbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_address_prefix = "AzureActiveDirectory"
      description                = "Required: Azure AD authentication"
    },
    {
      name                       = "AllowAzureMonitorOutbound"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_address_prefix = "AzureMonitor"
      description                = "Required: Azure Monitor diagnostics"
    },
    {
      name                       = "AllowAzureKeyVaultOutbound"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_address_prefix = "AzureKeyVault"
      description                = "Required: Azure Key Vault access for encryption"
    },
    {
      name                       = "AllowStorageOutbound"
      priority                   = 140
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      destination_address_prefix = "Storage"
      description                = "Required: Azure Storage outbound"
    }
  ]
}

module "this" {
  source = "rpothin/ptn-environmentgroup-vnetintegration/powerplatform"

  enterprise_policy_location = var.enterprise_policy_location
  environment_group_name     = var.environment_group_name
  environments               = var.environments

  non_production_tier = {
    resource_group_location = var.non_production_resource_group_location
    resource_group_name     = "rg-${var.environment_group_name}-nprod-vnet"

    primary_vnet_config = {
      location       = var.non_production_primary_vnet_location
      address_space  = "10.0.0.0/16"
      pp_subnet_cidr = "10.0.0.0/24"
      pe_subnet_cidr = "10.0.1.0/24"
    }

    failover_vnet_config = {
      location       = var.non_production_failover_vnet_location
      address_space  = "10.1.0.0/16"
      pp_subnet_cidr = "10.1.0.0/24"
      pe_subnet_cidr = "10.1.1.0/24"
    }

    nsg_additional_rules = local.pp_nsg_rules

    create_private_dns_zones = true
    private_dns_zone_names   = var.private_dns_zone_names
  }

  production_tier = {
    resource_group_location = var.production_resource_group_location
    resource_group_name     = "rg-${var.environment_group_name}-prod-vnet"

    primary_vnet_config = {
      location       = var.production_primary_vnet_location
      address_space  = "10.10.0.0/16"
      pp_subnet_cidr = "10.10.0.0/24"
      pe_subnet_cidr = "10.10.1.0/24"
    }

    failover_vnet_config = {
      location       = var.production_failover_vnet_location
      address_space  = "10.11.0.0/16"
      pp_subnet_cidr = "10.11.0.0/24"
      pe_subnet_cidr = "10.11.1.0/24"
    }

    nsg_additional_rules = local.pp_nsg_rules

    create_private_dns_zones = true
    private_dns_zone_names   = var.private_dns_zone_names
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
