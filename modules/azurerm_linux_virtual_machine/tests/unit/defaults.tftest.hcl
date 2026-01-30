# Defaults tests for Linux Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_virtual_machine" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/virtualMachines/linuxvm-unit"
      name                  = "linuxvm-unit"
      location              = "westeurope"
      resource_group_name   = "rg-test"
      network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic1"]
    }
  }
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

run "defaults_plan" {
  command = plan

  assert {
    condition     = azurerm_linux_virtual_machine.linux_virtual_machine.name == var.name
    error_message = "Linux VM name should match input."
  }
}
