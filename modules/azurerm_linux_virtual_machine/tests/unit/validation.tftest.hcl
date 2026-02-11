# Validation tests for Linux Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_virtual_machine" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "linuxvm-unit"
  resource_group_name = "rg-test"
  location            = "westeurope"
  size                = "Standard_B2s"

  network = {
    network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic1"]
  }

  admin = {
    username                        = "azureuser"
    disable_password_authentication = true
    ssh_keys = [
      {
        username   = "azureuser"
        public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6pEPPOMrZJib6o/ao9ia0OoMyaHS5kQ/4mml7U7edCx/BPbHji3BCz8oTKnJY/CKQ7gRIDCzPxgqv86TTYkQSMiJF5F8BwSB6lZ5X+MPNTPA37y9WzxXtzNaRvt95VlmNFScSd5AzmGFdedw5QGsDsKo06SA9LbTajR1FVnGS6hy02hM4C/AfOIF5O5nLDvb63fU+yh+kAT+WjEWkf+bGh4QNiFlY+T3uCJSuIO88v8TNxYCRRj1oYgF4CoXTWCUR5ftoldFATHX4A+OatuoX4kXJM1rnJwnTluhVBGhHR8siEI8SmRf+iHM+uzdKIIMSTnmySJIVpRpgDVzP1UWh"
      }
    ]
  }

  image = {
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

run "ssh_required_when_password_auth_disabled" {
  command = plan

  variables {
    admin = {
      username                        = "azureuser"
      disable_password_authentication = true
      ssh_keys                        = []
    }
  }

  expect_failures = [
    var.admin,
  ]
}

run "password_required_when_auth_enabled" {
  command = plan

  variables {
    admin = {
      username                        = "azureuser"
      disable_password_authentication = false
      password                        = null
      ssh_keys                        = []
    }
  }

  expect_failures = [
    var.admin,
  ]
}

run "source_image_reference_and_id_conflict" {
  command = plan

  variables {
    image = {
      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }
      source_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/images/img"
    }
  }

  expect_failures = [
    var.image,
  ]
}

run "availability_set_and_zone_conflict" {
  command = plan

  variables {
    placement = {
      availability_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/availabilitySets/as"
      zone                = "1"
    }
  }

  expect_failures = [
    var.placement,
  ]
}

run "duplicate_data_disk_lun" {
  command = plan

  variables {
    data_disks = [
      {
        name                 = "disk-a"
        lun                  = 0
        caching              = "ReadOnly"
        disk_size_gb         = 64
        storage_account_type = "Standard_LRS"
      },
      {
        name                 = "disk-b"
        lun                  = 0
        caching              = "ReadOnly"
        disk_size_gb         = 64
        storage_account_type = "Standard_LRS"
      }
    ]
  }

  expect_failures = [
    var.data_disks,
  ]
}

run "spot_requires_eviction_policy" {
  command = plan

  variables {
    spot = {
      priority = "Spot"
    }
  }

  expect_failures = [
    var.spot,
  ]
}

run "diagnostic_partner_solution_destination_is_allowed" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                = "diag-partner"
        partner_solution_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationsManagement/solutions/example"
        metric_categories   = ["AllMetrics"]
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
        partner_solution_id        = " "
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law"
        metric_categories          = ["AllMetrics"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_requires_categories" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-no-categories"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law"
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_requires_eventhub_name_when_rule_is_set" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "diag-eventhub-missing-name"
        eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.EventHub/namespaces/ns/authorizationRules/rule"
        metric_categories              = ["AllMetrics"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_rejects_eventhub_name_without_rule" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                       = "diag-eventhub-name-without-rule"
        eventhub_name              = "hub1"
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law"
        metric_categories          = ["AllMetrics"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}

run "diagnostic_log_analytics_destination_type_requires_workspace" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name                           = "diag-law-destination-without-law"
        storage_account_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/stdiag"
        log_analytics_destination_type = "Dedicated"
        metric_categories              = ["AllMetrics"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings,
  ]
}
