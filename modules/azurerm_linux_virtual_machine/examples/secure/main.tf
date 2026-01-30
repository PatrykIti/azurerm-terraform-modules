terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "tls" {}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-linux-vm-secure"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-linux-vm-secure"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "nic-linux-vm-secure"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "linux_virtual_machine" {
  source = "../../"

  name                = "linuxvm-secure-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B2s"

  network_interface_ids = [azurerm_network_interface.example.id]

  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys = [
    {
      username   = "azureuser"
      public_key = tls_private_key.example.public_key_openssh
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
    storage_account_type = "StandardSSD_LRS"
  }

  boot_diagnostics = {
    enabled = true
  }

  security_profile = {
    secure_boot_enabled        = true
    vtpm_enabled               = true
    encryption_at_host_enabled = true
  }

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
