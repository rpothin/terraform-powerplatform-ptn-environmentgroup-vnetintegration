# Unit tests — mock providers, no credentials required.
#
# These tests validate module logic: variable validation, cross-variable preconditions,
# environment tier splitting, and output structure. All provider calls are mocked.

mock_provider "azapi" {
  alias = "non_production"
}

mock_provider "azapi" {
  alias = "production"
}

mock_provider "azurerm" {
  alias = "non_production"
}

mock_provider "azurerm" {
  alias = "production"
}

mock_provider "powerplatform" {}

# ==============================================================================
# VARIABLE VALIDATION TESTS
# ==============================================================================

run "rejects_invalid_enterprise_policy_location" {
  command = plan

  variables {
    enterprise_policy_location = "invalidregion"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  expect_failures = [var.enterprise_policy_location]
}

run "rejects_environment_group_name_too_long" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "this-name-is-way-too-long-and-exceeds-fifty-characters-limit"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  expect_failures = [var.environment_group_name]
}

run "rejects_invalid_environment_uuid" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "not-a-valid-uuid"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  expect_failures = [var.environments]
}

# ==============================================================================
# PRECONDITION TESTS
# ==============================================================================

run "rejects_trial_environment" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      trial = {
        id           = "00000000-0000-0000-0000-000000000002"
        display_name = "Trial"
        type         = "Trial"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  expect_failures = [terraform_data.preconditions]
}

run "rejects_mismatched_environment_location" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "europe"
      }
    }
    non_production_tier = {
      resource_group_location = "westeurope"
      primary_vnet_config = {
        location = "westeurope"
      }
      failover_vnet_config = {
        location = "northeurope"
      }
    }
  }

  expect_failures = [terraform_data.preconditions]
}

run "rejects_missing_non_production_tier" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = null
  }

  expect_failures = [terraform_data.preconditions]
}

run "rejects_missing_production_tier" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      prod = {
        id           = "00000000-0000-0000-0000-000000000003"
        display_name = "Production"
        type         = "Production"
        location     = "unitedstates"
      }
    }
    production_tier = null
  }

  expect_failures = [terraform_data.preconditions]
}

run "rejects_missing_primary_vnet_config_when_creating_infra" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location       = "eastus"
      create_network_infrastructure = true
      primary_vnet_config           = null
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  expect_failures = [terraform_data.preconditions]
}

run "rejects_missing_failover_vnet_config_when_creating_infra" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location       = "eastus"
      create_network_infrastructure = true
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = null
    }
  }

  expect_failures = [terraform_data.preconditions]
}

# ==============================================================================
# TIER ROUTING TESTS
# ==============================================================================

run "plans_non_production_only" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
      uat = {
        id           = "00000000-0000-0000-0000-000000000002"
        display_name = "UAT"
        type         = "Sandbox"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  assert {
    condition     = length(module.non_production) == 1
    error_message = "Non-production module should be instantiated when non-production environments exist."
  }

  assert {
    condition     = length(module.production) == 0
    error_message = "Production module should not be instantiated when no production environments exist."
  }
}

run "plans_production_only" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      prod = {
        id           = "00000000-0000-0000-0000-000000000003"
        display_name = "Production"
        type         = "Production"
        location     = "unitedstates"
      }
    }
    production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location = "eastus"
      }
      failover_vnet_config = {
        location = "westus"
      }
    }
  }

  assert {
    condition     = length(module.production) == 1
    error_message = "Production module should be instantiated when production environments exist."
  }

  assert {
    condition     = length(module.non_production) == 0
    error_message = "Non-production module should not be instantiated when no non-production environments exist."
  }
}

run "plans_both_tiers" {
  command = plan

  variables {
    enterprise_policy_location = "unitedstates"
    environment_group_name     = "test-group"
    environments = {
      dev = {
        id           = "00000000-0000-0000-0000-000000000001"
        display_name = "Dev"
        type         = "Sandbox"
        location     = "unitedstates"
      }
      prod = {
        id           = "00000000-0000-0000-0000-000000000003"
        display_name = "Production"
        type         = "Production"
        location     = "unitedstates"
      }
    }
    non_production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location      = "eastus"
        address_space = "10.0.0.0/16"
      }
      failover_vnet_config = {
        location      = "westus"
        address_space = "10.1.0.0/16"
      }
    }
    production_tier = {
      resource_group_location = "eastus"
      primary_vnet_config = {
        location      = "eastus"
        address_space = "10.10.0.0/16"
      }
      failover_vnet_config = {
        location      = "westus"
        address_space = "10.11.0.0/16"
      }
    }
  }

  assert {
    condition     = length(module.production) == 1
    error_message = "Production module should be instantiated."
  }

  assert {
    condition     = length(module.non_production) == 1
    error_message = "Non-production module should be instantiated."
  }
}
