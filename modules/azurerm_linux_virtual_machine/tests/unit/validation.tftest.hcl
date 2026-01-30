# Validation tests for Linux Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_virtual_machine" {}
}

variables {
  name                = "linuxvm-unit"
  resource_group_name = "rg-test"
  location            = "westeurope"
  size                = "Standard_B2s"

  network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic1"]

  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys = [
    {
      username   = "azureuser"
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7example"
    }
  ]

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

run "ssh_required_when_password_auth_disabled" {
  command = plan

  variables {
    admin_ssh_keys = []
  }

  expect_failures = [
    var.disable_password_authentication,
  ]
}

run "password_required_when_auth_enabled" {
  command = plan

  variables {
    disable_password_authentication = false
    admin_password                  = null
  }

  expect_failures = [
    var.disable_password_authentication,
  ]
}

run "source_image_reference_and_id_conflict" {
  command = plan

  variables {
    source_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/images/img"
  }

  expect_failures = [
    var.source_image_reference,
  ]
}

run "availability_set_and_zone_conflict" {
  command = plan

  variables {
    availability_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/availabilitySets/as"
    zone                = "1"
  }

  expect_failures = [
    var.availability_set_id,
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
