# Outputs tests for Windows Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_windows_virtual_machine" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/winvmunittest01"
      name = "winvmunittest01"
    }
  }
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

run "outputs_plan" {
  command = plan

  assert {
    condition     = output.network_interface_ids[0] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkInterfaces/nic1"
    error_message = "Outputs validation failed."
  }
}
