variable "enterprise_policy_location" {
  description = "The Power Platform region for the enterprise policy (must match the environment group location)."
  type        = string
  default     = "unitedstates"
}

variable "environment_group_name" {
  description = "The name of the environment group (must match the ptn-environmentgroup deployment)."
  type        = string
  default     = "example-basic"
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

variable "primary_vnet_location" {
  description = "Azure region for the primary virtual network (e.g. 'eastus', 'westeurope')."
  type        = string
  default     = "eastus"
}

variable "resource_group_location" {
  description = "Azure region for the non-production resource group."
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure subscription ID. Used for both non-production and production provider aliases in this single-subscription example."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all Azure resources."
  type        = map(string)
  default = {
    environment = "non-production"
    managed_by  = "terraform"
  }
}
