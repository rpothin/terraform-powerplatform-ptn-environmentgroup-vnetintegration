terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source                = "azure/azapi"
      version               = "~> 2.0"
      configuration_aliases = [azapi.non_production, azapi.production]
    }
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 4.0"
      configuration_aliases = [azurerm.non_production, azurerm.production]
    }
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "~> 4.0"
    }
  }
}
