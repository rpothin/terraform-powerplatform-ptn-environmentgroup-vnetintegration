locals {
  non_production_enterprise_policy_name = coalesce(
    try(var.non_production_tier.enterprise_policy_name, null),
    "${var.environment_group_name}-non-production"
  )

  non_production_environments = {
    for k, v in var.environments : k => v
    if v.type != "Production"
  }

  non_production_resource_group_name = coalesce(
    try(var.non_production_tier.resource_group_name, null),
    "rg-${var.environment_group_name}-non-production-vnet"
  )

  production_enterprise_policy_name = coalesce(
    try(var.production_tier.enterprise_policy_name, null),
    "${var.environment_group_name}-production"
  )

  production_environments = {
    for k, v in var.environments : k => v
    if v.type == "Production"
  }

  production_resource_group_name = coalesce(
    try(var.production_tier.resource_group_name, null),
    "rg-${var.environment_group_name}-production-vnet"
  )
}
