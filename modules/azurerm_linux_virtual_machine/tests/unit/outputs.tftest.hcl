# Outputs tests for Linux Virtual Machine module

mock_provider "azurerm" {
  mock_resource "azurerm_linux_virtual_machine" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/virtualMachines/linuxvm-output"
      name                  = "linuxvm-output"
      location              = "westeurope"
      resource_group_name   = "rg-test"
      network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic1"]
      identity = [{
        type         = "SystemAssigned"
        principal_id = "11111111-1111-1111-1111-111111111111"
        tenant_id    = "22222222-2222-2222-2222-222222222222"
      }]
    }
  }
}

variables {
  name                = "linuxvm-output"
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

run "verify_outputs" {
  command = plan

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Compute/virtualMachines/linuxvm-output"
    error_message = "Output id should match mocked VM id."
  }

  assert {
    condition     = output.name == "linuxvm-output"
    error_message = "Output name should match mocked VM name."
  }

  assert {
    condition     = output.location == "westeurope"
    error_message = "Output location should match mocked VM location."
  }

  assert {
    condition     = output.resource_group_name == "rg-test"
    error_message = "Output resource group should match mocked VM resource group."
  }
}
