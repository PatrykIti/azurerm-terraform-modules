# Test variable validation for the Kubernetes Cluster module

mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
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
