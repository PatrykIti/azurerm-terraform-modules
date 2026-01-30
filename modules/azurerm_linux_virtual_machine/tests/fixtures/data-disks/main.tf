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
  name     = "rg-linux-vm-data-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-linux-vm-data-${var.random_suffix}"
  address_space       = ["10.40.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-linux-vm-data-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "pip-linux-vm-data-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "example" {
  name                = "nic-linux-vm-data-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "linux_virtual_machine" {
  source = "../../"

  name                = "linuxvm-data-${var.random_suffix}"
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

  data_disks = [
    {
      name                 = "linuxvm-data-disk-0"
      lun                  = 0
      caching              = "ReadOnly"
      disk_size_gb         = 128
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "linuxvm-data-disk-1"
      lun                  = 1
      caching              = "None"
      disk_size_gb         = 256
      storage_account_type = "StandardSSD_LRS"
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Data-Disks"
  }
}
