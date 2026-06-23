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

provider "azurerm" {
  alias           = "non_production"
  subscription_id = var.non_production_subscription_id

  features {}
}

provider "azurerm" {
  alias           = "production"
  subscription_id = var.production_subscription_id

  features {}
}

provider "azapi" {
  alias           = "non_production"
  subscription_id = var.non_production_subscription_id
}

provider "azapi" {
  alias           = "production"
  subscription_id = var.production_subscription_id
}

provider "powerplatform" {
  # Configuration is provided via environment variables:
  #   POWER_PLATFORM_TENANT_ID
  #   POWER_PLATFORM_CLIENT_ID
  # For OIDC: ARM_USE_OIDC=true
}
