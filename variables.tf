# ==============================================================================
# Required variables (alphabetical)
# ==============================================================================

variable "enterprise_policy_location" {
  description = "The Power Platform geographic region for the enterprise policy (e.g. 'europe', 'unitedstates'). Must match the location of all environments in the environments map."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["unitedstates", "europe", "asia", "australia", "japan", "india", "canada", "southamerica", "unitedkingdom", "france", "germany", "switzerland", "norway", "korea", "southafrica", "uae", "singapore", "sweden", "italy", "poland"], var.enterprise_policy_location)
    error_message = "enterprise_policy_location must be a valid Power Platform region (e.g. 'europe', 'unitedstates')."
  }
}

variable "environment_group_name" {
  description = "The name of the Power Platform environment group. Used to generate resource names. Must match the name used in the paired ptn-environmentgroup deployment (max 50 characters to ensure computed Azure resource names stay within provider limits)."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.environment_group_name) >= 1 && length(var.environment_group_name) <= 50
    error_message = "environment_group_name must be between 1 and 50 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]*$", var.environment_group_name))
    error_message = "environment_group_name must start with an alphanumeric character and contain only alphanumeric characters, hyphens, or underscores."
  }
}

variable "environments" {
  description = <<DESCRIPTION
Map of Power Platform environments to configure VNet integration for. Typically the direct
output of `ptn-environmentgroup.environments`.

- Key: logical environment identifier (e.g. "dev", "uat", "prod")
- `id`: Power Platform environment GUID
- `display_name`: Environment display name
- `type`: Environment type — must be "Production" or "Sandbox". "Trial" environments are not supported and are rejected at plan time.
- `dataverse_url`: Dataverse organisation URL (may be null)
- `location`: Power Platform region — must match enterprise_policy_location for all entries

All environments must be **Managed Environments** before this module can link enterprise policies.
DESCRIPTION
  type = map(object({
    id            = string
    display_name  = string
    type          = string
    dataverse_url = optional(string)
    location      = string
  }))
  nullable = false

  validation {
    condition     = length(var.environments) > 0
    error_message = "At least one environment must be specified in environments."
  }

  validation {
    condition = alltrue([
      for k, v in var.environments :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", v.id))
    ])
    error_message = "Each environment id must be a valid UUID (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)."
  }

  validation {
    condition     = length(var.environments) == length(distinct([for _, v in var.environments : lower(v.id)]))
    error_message = "Each environment must have a unique id. Duplicate environment GUIDs are not allowed."
  }
}

# ==============================================================================
# Optional variables (alphabetical)
# ==============================================================================

variable "non_production_tier" {
  description = <<DESCRIPTION
Configuration for the non-production tier VNet integration. Required when any environment
in `environments` has type != "Production". Set to null to disable the non-production tier.

- `resource_group_location`: (Required) Azure region for the resource group and networking resources (e.g. "westeurope").
- `create_network_infrastructure`: When true, creates VNets, subnets, NSGs, and optional VNet peering. Default: true.
- `create_private_dns_zones`: When true, creates private DNS zones listed in private_dns_zone_names and links them to the VNets. Default: false.
- `enterprise_policy_name`: Name override for the enterprise policy ARM resource (max 128 chars). Computed from environment_group_name if null.
- `failover_vnet_config`: Failover VNet configuration. Both primary and failover locations must differ for true resiliency. Only used when create_network_infrastructure is true.
- `network_config`: Existing network configuration to use when create_network_infrastructure is false (bring-your-own network).
- `nsg_additional_rules`: Additional NSG security rules for the PP-delegated subnet. The built-in posture includes DenyAllOutBound — add required PP service endpoint outbound allow rules here.
- `nsg_pe_additional_rules`: Additional NSG security rules for the private endpoint subnet.
- `primary_vnet_config`: Primary VNet configuration. Required when create_network_infrastructure is true.
- `private_dns_zone_names`: List of private DNS zone names to create (e.g. ["privatelink.blob.core.windows.net"]).
- `resource_group_name`: Name override for the Azure resource group (max 90 chars). Computed from environment_group_name if null.
DESCRIPTION
  type = object({
    resource_group_location       = string
    create_network_infrastructure = optional(bool, true)
    create_private_dns_zones      = optional(bool, false)
    enterprise_policy_name        = optional(string)
    failover_vnet_config = optional(object({
      location       = string
      address_space  = optional(string, "10.1.0.0/16")
      pp_subnet_cidr = optional(string, "10.1.0.0/24")
      pe_subnet_cidr = optional(string, "10.1.1.0/24")
    }))
    network_config = optional(object({
      primary = object({
        vnet_id     = string
        subnet_id   = string
        subnet_name = string
      })
      failover = object({
        vnet_id     = string
        subnet_id   = string
        subnet_name = string
      })
    }))
    nsg_additional_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
      description                = optional(string, "")
    })), [])
    nsg_pe_additional_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
      description                = optional(string, "")
    })), [])
    primary_vnet_config = optional(object({
      location       = string
      address_space  = optional(string, "10.0.0.0/16")
      pp_subnet_cidr = optional(string, "10.0.0.0/24")
      pe_subnet_cidr = optional(string, "10.0.1.0/24")
    }))
    private_dns_zone_names = optional(list(string), [])
    resource_group_name    = optional(string)
  })
  default = null
}

variable "production_tier" {
  description = <<DESCRIPTION
Configuration for the production tier VNet integration. Required when any environment
in `environments` has type == "Production". Set to null to disable the production tier.

Same shape as non_production_tier — see non_production_tier description for full field details.

Use non-overlapping CIDR ranges for production and non-production tiers when both are active
to avoid address space conflicts between the separate Azure subscriptions.
DESCRIPTION
  type = object({
    resource_group_location       = string
    create_network_infrastructure = optional(bool, true)
    create_private_dns_zones      = optional(bool, false)
    enterprise_policy_name        = optional(string)
    failover_vnet_config = optional(object({
      location       = string
      address_space  = optional(string, "10.1.0.0/16")
      pp_subnet_cidr = optional(string, "10.1.0.0/24")
      pe_subnet_cidr = optional(string, "10.1.1.0/24")
    }))
    network_config = optional(object({
      primary = object({
        vnet_id     = string
        subnet_id   = string
        subnet_name = string
      })
      failover = object({
        vnet_id     = string
        subnet_id   = string
        subnet_name = string
      })
    }))
    nsg_additional_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
      description                = optional(string, "")
    })), [])
    nsg_pe_additional_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
      description                = optional(string, "")
    })), [])
    primary_vnet_config = optional(object({
      location       = string
      address_space  = optional(string, "10.0.0.0/16")
      pp_subnet_cidr = optional(string, "10.0.0.0/24")
      pe_subnet_cidr = optional(string, "10.0.1.0/24")
    }))
    private_dns_zone_names = optional(list(string), [])
    resource_group_name    = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to apply to all Azure resources created by this module."
  type        = map(string)
  default     = {}
  nullable    = false
}
