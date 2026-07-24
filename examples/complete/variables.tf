variable "enterprise_policy_location" {
  description = "The Power Platform region for the enterprise policy (must match the environment group location)."
  type        = string
  default     = "unitedstates"
}

variable "environment_group_name" {
  description = "The name of the environment group (must match the ptn-environmentgroup deployment)."
  type        = string
  default     = "example-complete"
}

variable "environments" {
  description = "Map of Power Platform environments. Typically the direct output of ptn-environmentgroup.environments."
  type = map(object({
    id            = string
    display_name  = string
    type          = string
    dataverse_url = optional(string)
    location      = string
  }))
}

variable "non_production_failover_vnet_location" {
  description = "Azure region for the non-production failover VNet."
  type        = string
  default     = "westus"
}

variable "non_production_primary_vnet_location" {
  description = "Azure region for the non-production primary VNet."
  type        = string
  default     = "eastus"
}

variable "non_production_resource_group_location" {
  description = "Azure region for the non-production resource group."
  type        = string
  default     = "eastus"
}

variable "non_production_subscription_id" {
  description = "Azure subscription ID for non-production resources."
  type        = string
  sensitive   = true
}

variable "private_dns_zone_names" {
  description = "List of private DNS zone names to create in each tier."
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net"
  ]
}

variable "production_failover_vnet_location" {
  description = "Azure region for the production failover VNet."
  type        = string
  default     = "centralus"
}

variable "production_primary_vnet_location" {
  description = "Azure region for the production primary VNet."
  type        = string
  default     = "eastus2"
}

variable "production_resource_group_location" {
  description = "Azure region for the production resource group."
  type        = string
  default     = "eastus2"
}

variable "production_subscription_id" {
  description = "Azure subscription ID for production resources."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all Azure resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
    module     = "ptn-environmentgroup-vnetintegration"
  }
}
