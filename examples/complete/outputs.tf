output "enterprise_policy_links" {
  description = "Flat map of all enterprise policy links across both tiers."
  value       = module.this.enterprise_policy_links
}

output "non_production_enterprise_policy_id" {
  description = "ARM resource ID of the non-production enterprise policy."
  value       = module.this.non_production_enterprise_policy_id
}

output "non_production_failover_vnet_id" {
  description = "ARM resource ID of the non-production failover virtual network."
  value       = module.this.non_production_failover_vnet_id
}

output "non_production_primary_vnet_id" {
  description = "ARM resource ID of the non-production primary virtual network."
  value       = module.this.non_production_primary_vnet_id
}

output "non_production_resource_group_name" {
  description = "Name of the non-production Azure resource group."
  value       = module.this.non_production_resource_group_name
}

output "production_enterprise_policy_id" {
  description = "ARM resource ID of the production enterprise policy."
  value       = module.this.production_enterprise_policy_id
}

output "production_failover_vnet_id" {
  description = "ARM resource ID of the production failover virtual network."
  value       = module.this.production_failover_vnet_id
}

output "production_primary_vnet_id" {
  description = "ARM resource ID of the production primary virtual network."
  value       = module.this.production_primary_vnet_id
}

output "production_resource_group_name" {
  description = "Name of the production Azure resource group."
  value       = module.this.production_resource_group_name
}
