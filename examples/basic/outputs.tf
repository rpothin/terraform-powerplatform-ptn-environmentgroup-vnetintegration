output "enterprise_policy_links" {
  description = "Map of all enterprise policy links keyed by environment key."
  value       = module.this.enterprise_policy_links
}

output "non_production_enterprise_policy_id" {
  description = "The Azure ARM resource ID of the non-production enterprise policy."
  value       = module.this.non_production_enterprise_policy_id
}

output "non_production_primary_subnet_id" {
  description = "The Azure resource ID of the non-production primary PP-delegated subnet."
  value       = module.this.non_production_primary_subnet_id
}

output "non_production_primary_vnet_id" {
  description = "The Azure resource ID of the non-production primary virtual network."
  value       = module.this.non_production_primary_vnet_id
}

output "non_production_resource_group_name" {
  description = "The name of the non-production Azure resource group."
  value       = module.this.non_production_resource_group_name
}
