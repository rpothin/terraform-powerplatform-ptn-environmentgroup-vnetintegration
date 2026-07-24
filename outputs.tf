output "enterprise_policy_links" {
  description = "Flat map of all enterprise policy links keyed by environment key. Merges production and non-production tier links. Each entry contains environment_id and policy_type."
  value = merge(
    try(module.production[0].enterprise_policy_links, {}),
    try(module.non_production[0].enterprise_policy_links, {})
  )
}

output "non_production_enterprise_policy_id" {
  description = "The Azure ARM resource ID of the non-production enterprise policy. Null when no non-production environments exist."
  value       = try(module.non_production[0].enterprise_policy_id, null)
}

output "non_production_enterprise_policy_links" {
  description = "Map of environment key to enterprise policy link details for the non-production tier. Empty map when the tier is inactive."
  value       = try(module.non_production[0].enterprise_policy_links, {})
}

output "non_production_enterprise_policy_system_id" {
  description = "The Power Platform system ID of the non-production enterprise policy, used for cross-module references. Null when the tier is inactive."
  value       = try(module.non_production[0].enterprise_policy_system_id, null)
}

output "non_production_failover_subnet_id" {
  description = "The Azure resource ID of the non-production failover PP-delegated subnet. Null when the tier is inactive or no failover VNet was created."
  value       = try(module.non_production[0].failover_subnet_id, null)
}

output "non_production_failover_vnet_id" {
  description = "The Azure resource ID of the non-production failover virtual network. Null when the tier is inactive or no failover VNet was created."
  value       = try(module.non_production[0].failover_vnet_id, null)
}

output "non_production_primary_subnet_id" {
  description = "The Azure resource ID of the non-production primary PP-delegated subnet. Null when the tier is inactive."
  value       = try(module.non_production[0].primary_subnet_id, null)
}

output "non_production_primary_vnet_id" {
  description = "The Azure resource ID of the non-production primary virtual network. Null when the tier is inactive."
  value       = try(module.non_production[0].primary_vnet_id, null)
}

output "non_production_resource_group_name" {
  description = "The name of the non-production Azure resource group. Null when the tier is inactive."
  value       = try(module.non_production[0].resource_group_name, null)
}

output "production_enterprise_policy_id" {
  description = "The Azure ARM resource ID of the production enterprise policy. Null when no production environments exist."
  value       = try(module.production[0].enterprise_policy_id, null)
}

output "production_enterprise_policy_links" {
  description = "Map of environment key to enterprise policy link details for the production tier. Empty map when the tier is inactive."
  value       = try(module.production[0].enterprise_policy_links, {})
}

output "production_enterprise_policy_system_id" {
  description = "The Power Platform system ID of the production enterprise policy, used for cross-module references. Null when the tier is inactive."
  value       = try(module.production[0].enterprise_policy_system_id, null)
}

output "production_failover_subnet_id" {
  description = "The Azure resource ID of the production failover PP-delegated subnet. Null when the tier is inactive or no failover VNet was created."
  value       = try(module.production[0].failover_subnet_id, null)
}

output "production_failover_vnet_id" {
  description = "The Azure resource ID of the production failover virtual network. Null when the tier is inactive or no failover VNet was created."
  value       = try(module.production[0].failover_vnet_id, null)
}

output "production_primary_subnet_id" {
  description = "The Azure resource ID of the production primary PP-delegated subnet. Null when the tier is inactive."
  value       = try(module.production[0].primary_subnet_id, null)
}

output "production_primary_vnet_id" {
  description = "The Azure resource ID of the production primary virtual network. Null when the tier is inactive."
  value       = try(module.production[0].primary_vnet_id, null)
}

output "production_resource_group_name" {
  description = "The name of the production Azure resource group. Null when the tier is inactive."
  value       = try(module.production[0].resource_group_name, null)
}
