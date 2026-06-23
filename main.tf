# ==============================================================================
# CROSS-VARIABLE PRECONDITIONS
# ==============================================================================

resource "terraform_data" "preconditions" {
  lifecycle {
    precondition {
      condition = alltrue([
        for k, v in var.environments :
        contains(["Sandbox", "Production"], v.type)
      ])
      error_message = "All environments must be of type 'Sandbox' or 'Production'. 'Trial' environments are not supported for VNet injection."
    }

    precondition {
      condition = alltrue([
        for k, v in var.environments :
        v.location == var.enterprise_policy_location
      ])
      error_message = "All environments must have the same location as enterprise_policy_location. Enterprise policies are scoped to a single Power Platform region."
    }

    precondition {
      condition     = length(local.production_environments) == 0 || var.production_tier != null
      error_message = "production_tier must be provided when environments contains Production-type environments."
    }

    precondition {
      condition     = length(local.non_production_environments) == 0 || var.non_production_tier != null
      error_message = "non_production_tier must be provided when environments contains non-Production environments (Sandbox, etc.)."
    }

    precondition {
      condition = (
        var.production_tier == null ||
        !try(var.production_tier.create_network_infrastructure, true) ||
        try(var.production_tier.primary_vnet_config, null) != null
      )
      error_message = "production_tier.primary_vnet_config must be provided when production_tier.create_network_infrastructure is true."
    }

    precondition {
      condition = (
        var.production_tier == null ||
        !try(var.production_tier.create_network_infrastructure, true) ||
        try(var.production_tier.failover_vnet_config, null) != null
      )
      error_message = "production_tier.failover_vnet_config must be provided when production_tier.create_network_infrastructure is true."
    }

    precondition {
      condition = (
        var.non_production_tier == null ||
        !try(var.non_production_tier.create_network_infrastructure, true) ||
        try(var.non_production_tier.primary_vnet_config, null) != null
      )
      error_message = "non_production_tier.primary_vnet_config must be provided when non_production_tier.create_network_infrastructure is true."
    }

    precondition {
      condition = (
        var.non_production_tier == null ||
        !try(var.non_production_tier.create_network_infrastructure, true) ||
        try(var.non_production_tier.failover_vnet_config, null) != null
      )
      error_message = "non_production_tier.failover_vnet_config must be provided when non_production_tier.create_network_infrastructure is true."
    }
  }
}

# ==============================================================================
# PRODUCTION TIER
# ==============================================================================

module "production" {
  source  = "rpothin/ptn-enterprisepolicy-networkinjection/powerplatform"
  version = "= 0.1.0"
  count   = length(local.production_environments) > 0 ? 1 : 0

  create_network_infrastructure = try(var.production_tier.create_network_infrastructure, true)
  create_private_dns_zones      = try(var.production_tier.create_private_dns_zones, false)
  enterprise_policy_location    = var.enterprise_policy_location
  enterprise_policy_name        = local.production_enterprise_policy_name
  environments                  = { for k, v in local.production_environments : k => { id = v.id } }
  failover_vnet_config          = try(var.production_tier.failover_vnet_config, null)
  network_config                = try(var.production_tier.network_config, null)
  nsg_additional_rules          = try(var.production_tier.nsg_additional_rules, [])
  nsg_pe_additional_rules       = try(var.production_tier.nsg_pe_additional_rules, [])
  primary_vnet_config           = try(var.production_tier.primary_vnet_config, null)
  private_dns_zone_names        = try(var.production_tier.private_dns_zone_names, [])
  resource_group_location       = try(var.production_tier.resource_group_location, "")
  resource_group_name           = local.production_resource_group_name
  tags                          = var.tags

  depends_on = [terraform_data.preconditions]

  providers = {
    azapi         = azapi.production
    azurerm       = azurerm.production
    powerplatform = powerplatform
  }
}

# ==============================================================================
# NON-PRODUCTION TIER
# ==============================================================================

module "non_production" {
  source  = "rpothin/ptn-enterprisepolicy-networkinjection/powerplatform"
  version = "= 0.1.0"
  count   = length(local.non_production_environments) > 0 ? 1 : 0

  create_network_infrastructure = try(var.non_production_tier.create_network_infrastructure, true)
  create_private_dns_zones      = try(var.non_production_tier.create_private_dns_zones, false)
  enterprise_policy_location    = var.enterprise_policy_location
  enterprise_policy_name        = local.non_production_enterprise_policy_name
  environments                  = { for k, v in local.non_production_environments : k => { id = v.id } }
  failover_vnet_config          = try(var.non_production_tier.failover_vnet_config, null)
  network_config                = try(var.non_production_tier.network_config, null)
  nsg_additional_rules          = try(var.non_production_tier.nsg_additional_rules, [])
  nsg_pe_additional_rules       = try(var.non_production_tier.nsg_pe_additional_rules, [])
  primary_vnet_config           = try(var.non_production_tier.primary_vnet_config, null)
  private_dns_zone_names        = try(var.non_production_tier.private_dns_zone_names, [])
  resource_group_location       = try(var.non_production_tier.resource_group_location, "")
  resource_group_name           = local.non_production_resource_group_name
  tags                          = var.tags

  depends_on = [terraform_data.preconditions]

  providers = {
    azapi         = azapi.non_production
    azurerm       = azurerm.non_production
    powerplatform = powerplatform
  }
}