terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "~> 4.0"
    }
  }
}

# Non-production provider (default azurerm instance).
# In this single-subscription example, both aliases use the same subscription.
# In a multi-subscription setup, use separate subscriptions for each tier.
provider "azurerm" {
  alias           = "non_production"
  subscription_id = var.subscription_id

  features {}
}

# Production alias — must be declared even when no Production environments exist.
# The production module call is skipped (count = 0) when no Production-type
# environments are provided, so no API calls are made to this subscription.
provider "azurerm" {
  alias           = "production"
  subscription_id = var.subscription_id

  features {}
}

provider "azapi" {
  alias           = "non_production"
  subscription_id = var.subscription_id
}

provider "azapi" {
  alias           = "production"
  subscription_id = var.subscription_id
}

provider "powerplatform" {
  # Configuration is provided via environment variables:
  #   POWER_PLATFORM_TENANT_ID
  #   POWER_PLATFORM_CLIENT_ID
  # For OIDC: ARM_USE_OIDC=true
}
