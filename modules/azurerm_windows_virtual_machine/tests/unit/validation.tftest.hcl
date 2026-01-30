# Validation tests for Windows Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_windows_virtual_machine" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/winvmunittest01"
      name = "winvmunittest01"
    }
  }

  mock_resource "azurerm_virtual_machine_extension" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}

  mock_data_source "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types    = ["AuditEvent"]
      log_category_groups   = []
      metric_category_types = ["AllMetrics"]
    }
  }
}

variables {
  name                = "winvmunittest01"
  resource_group_name = "test-rg"
  location            = "northeurope"
  size                = "Standard_B2s"

  network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/nic1"]

  admin_username = "azureuser"
  admin_password = "Str0ngPassw0rd!"

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

run "invalid_vm_name" {
  command = plan

  variables {
    name = "-badname"
  }

  expect_failures = [
    var.name
  ]
}

run "reserved_admin_username" {
  command = plan

  variables {
    admin_username = "Admin"
  }

  expect_failures = [
    var.admin_username
  ]
}

run "weak_admin_password" {
  command = plan

  variables {
    admin_password = "weak"
  }

  expect_failures = [
    var.admin_password
  ]
}

run "image_reference_and_id_conflict" {
  command = plan

  variables {
    source_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/images/custom"
  }

  expect_failures = [
    var.source_image_reference
  ]
}

run "availability_set_zone_conflict" {
  command = plan

  variables {
    availability_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/availabilitySets/as"
    zone                = "1"
  }

  expect_failures = [
    var.availability_set_id
  ]
}

run "diagnostic_missing_destination" {
  command = plan

  variables {
    diagnostic_settings = [
      {
        name           = "diag"
        log_categories = ["AuditEvent"]
      }
    ]
  }

  expect_failures = [
    var.diagnostic_settings
  ]
}
