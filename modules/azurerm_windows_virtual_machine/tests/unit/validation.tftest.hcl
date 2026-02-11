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
}

variables {
  name                = "winvmunittest01"
  resource_group_name = "test-rg"
  location            = "northeurope"
  size                = "Standard_B2s"

  network = {
    network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/nic1"]
  }

  admin = {
    username = "azureuser"
    password = "Str0ngPassw0rd!"
  }

  image = {
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }
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
    admin = {
      username = "Admin"
      password = "Str0ngPassw0rd!"
    }
  }

  expect_failures = [
    var.admin
  ]
}

run "weak_admin_password" {
  command = plan

  variables {
    admin = {
      username = "azureuser"
      password = "weak"
    }
  }

  expect_failures = [
    var.admin
  ]
}

run "image_reference_and_id_conflict" {
  command = plan

  variables {
    image = {
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      source_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/images/custom"
    }
  }

  expect_failures = [
    var.image
  ]
}

run "availability_set_zone_conflict" {
  command = plan

  variables {
    placement = {
      availability_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/availabilitySets/as"
      zone                = "1"
    }
  }

  expect_failures = [
    var.placement
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
