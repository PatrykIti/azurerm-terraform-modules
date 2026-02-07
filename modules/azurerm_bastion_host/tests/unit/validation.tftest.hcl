# Validation tests for Bastion Host module

mock_provider "azurerm" {
  mock_resource "azurerm_bastion_host" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/bastionHosts/bastionunit"
      name                = "bastionunit"
      location            = "northeurope"
      resource_group_name = "test-rg"
      sku                 = "Basic"
      dns_name            = "bastionunit.eastus.bastion.azure.com"
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types  = ["BastionAuditLogs"]
      log_category_groups = ["allLogs"]
      metrics             = ["AllMetrics"]
    }
  }
}

variables {
  name                = "bastionunit"
  resource_group_name = "test-rg"
  location            = "northeurope"

  ip_configuration = [
    {
      name                 = "ipconfig"
      subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/AzureBastionSubnet"
      public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip"
    }
  ]
}

run "invalid_sku" {
  command = plan

  variables {
    sku = "Gold"
  }

  expect_failures = [
    var.sku
  ]
}

run "too_many_ip_configurations" {
  command = plan

  variables {
    ip_configuration = [
      {
        name                 = "ipconfig-1"
        subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/AzureBastionSubnet"
        public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip1"
      },
      {
        name                 = "ipconfig-2"
        subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/AzureBastionSubnet"
        public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip2"
      }
    ]
  }

  expect_failures = [
    var.ip_configuration
  ]
}

run "invalid_bastion_subnet_name" {
  command = plan

  variables {
    ip_configuration = [
      {
        name                 = "ipconfig"
        subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/NotBastionSubnet"
        public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/pip"
      }
    ]
  }

  expect_failures = [
    var.ip_configuration
  ]
}

run "standard_feature_requires_standard_sku" {
  command = plan

  variables {
    sku               = "Basic"
    file_copy_enabled = true
  }

  expect_failures = [
    var.file_copy_enabled
  ]
}

run "session_recording_requires_premium" {
  command = plan

  variables {
    sku                       = "Standard"
    session_recording_enabled = true
  }

  expect_failures = [
    var.session_recording_enabled
  ]
}

run "developer_requires_virtual_network_id" {
  command = plan

  variables {
    sku                = "Developer"
    ip_configuration   = []
    virtual_network_id = null
  }

  expect_failures = [
    var.virtual_network_id
  ]
}

run "developer_disallows_ip_configuration" {
  command = plan

  variables {
    sku                = "Developer"
    virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet"
  }

  expect_failures = [
    var.ip_configuration
  ]
}

run "virtual_network_id_only_for_developer" {
  command = plan

  variables {
    sku                = "Basic"
    virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet"
  }

  expect_failures = [
    var.virtual_network_id
  ]
}

run "scale_units_requires_standard_or_premium" {
  command = plan

  variables {
    sku         = "Basic"
    scale_units = 5
  }

  expect_failures = [
    var.scale_units
  ]
}

run "diagnostic_partner_solution_only_destination_is_allowed" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                = "diag-partner"
        partner_solution_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationsManagement/solutions/example"
        log_categories      = ["BastionAuditLogs"]
      }
    ]
  }

  assert {
    condition     = length(var.diagnostic_settings) == 1
    error_message = "diagnostic_settings should accept partner_solution_id as a valid destination."
  }
}

run "diagnostic_rejects_empty_partner_solution_id" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-empty-partner"
        partner_solution_id        = ""
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/law"
        log_categories             = ["BastionAuditLogs"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}
