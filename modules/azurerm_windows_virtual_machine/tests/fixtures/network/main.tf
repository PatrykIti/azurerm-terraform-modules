terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}

locals {
  suffix              = lower(replace(var.random_suffix, "-", ""))
  short_suffix        = substr(local.suffix, 0, min(length(local.suffix), 8))
  resource_group_name = coalesce(var.resource_group_name, "rg-win-vm-network-${local.short_suffix}")
}

resource "random_password" "admin" {
  length      = 20
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-win-vm-network-${local.short_suffix}"
  address_space       = ["10.140.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-win-vm-network-${local.short_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.140.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "pip-win-vm-network-${local.short_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "example" {
  name                = "nic-win-vm-network-${local.short_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

module "windows_virtual_machine" {
  source = "../../../"

  name                = "wvm-net-${local.short_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B2s"

  network = {
    network_interface_ids = [azurerm_network_interface.example.id]
  }

  admin = {
    username = "azureuser"
    password = random_password.admin.result
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

  windows_profile = {
    computer_name = "wvn${local.short_suffix}"
  }

  tags = {
    Environment = "Test"
    Example     = "Network"
  }
}
