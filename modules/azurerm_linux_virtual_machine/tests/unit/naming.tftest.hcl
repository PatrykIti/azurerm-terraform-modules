# Naming tests for Linux Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_virtual_machine" {}
}

variables {
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

run "invalid_name_trailing_hyphen" {
  command = plan

  variables {
    name = "linuxvm-"
  }

  expect_failures = [
    var.name,
  ]
}

run "invalid_name_special_chars" {
  command = plan

  variables {
    name = "linuxvm!bad"
  }

  expect_failures = [
    var.name,
  ]
}
