# Test variable validation for the Kubernetes Cluster module

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = [
        "kube-apiserver",
        "kube-audit",
        "kube-audit-admin",
        "kube-scheduler",
        "cluster-autoscaler",
        "guard",
        "cloud-controller-manager"
      ]
      metrics = ["AllMetrics"]
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
  dns_config = {
    dns_prefix = "akstest"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
}

# Test invalid cluster name with uppercase letters
run "invalid_name_uppercase" {
  command = plan

  variables {
    name = "InvalidAKSName"
  }

  expect_failures = [
    var.name,
  ]
}

# Test invalid cluster name with special characters
run "invalid_name_special_chars" {
  command = plan

  variables {
    name = "invalid_aks_name"
  }

  expect_failures = [
    var.name,
  ]
}

# Test that one of dns_prefix or dns_prefix_private_cluster is required
run "missing_dns_prefix" {
  command = plan

  variables {
    name       = "validname"
    dns_config = {} # Empty dns_config block
  }

  expect_failures = [
    var.dns_config, # The validation is on the variable
  ]
}

# Test that both dns_prefix and dns_prefix_private_cluster cannot be set
run "both_dns_prefixes_set" {
  command = plan

  variables {
    name = "validname"
    dns_config = {
      dns_prefix                 = "publicprefix"
      dns_prefix_private_cluster = "privateprefix"
    }
  }

  expect_failures = [
    var.dns_config,
  ]
}

# Test that a single-character dns_prefix is allowed
run "single_character_dns_prefix_passes" {
  command = plan

  variables {
    name = "validname"
    dns_config = {
      dns_prefix = "a"
    }
  }
}

# Diagnostic settings validation: missing destination
run "diagnostic_settings_missing_destination" {
  command = plan

  variables {
    name = "validname"
    diagnostic_settings = [
      {
        name  = "missing-destination"
        areas = ["api_plane"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

# Diagnostic settings validation: Event Hub name required
run "diagnostic_settings_missing_eventhub_name" {
  command = plan

  variables {
    name = "validname"
    diagnostic_settings = [
      {
        name                           = "eventhub-missing-name"
        areas                          = ["metrics"]
        eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ns/authorizationRules/rule"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

# Diagnostic settings validation: invalid area
run "diagnostic_settings_invalid_area" {
  command = plan

  variables {
    name = "validname"
    diagnostic_settings = [
      {
        name                       = "invalid-area"
        areas                      = ["pods"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

# Diagnostic settings validation: duplicate names
run "diagnostic_settings_duplicate_names" {
  command = plan

  variables {
    name = "validname"
    diagnostic_settings = [
      {
        name                       = "duplicate"
        areas                      = ["api_plane"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      },
      {
        name                       = "duplicate"
        areas                      = ["metrics"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

# Diagnostic settings validation: limit exceeded
run "diagnostic_settings_limit_exceeded" {
  command = plan

  variables {
    name = "validname"
    diagnostic_settings = [
      for idx in range(6) : {
        name                       = "diag-${idx}"
        areas                      = ["api_plane"]
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}
