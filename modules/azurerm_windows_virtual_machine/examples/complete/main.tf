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

resource "random_password" "admin" {
  length      = 24
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-win-vm-complete"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-win-vm-complete"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "pip-win-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "example" {
  name                = "nic-win-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-win-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-win-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

module "windows_virtual_machine" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_windows_virtual_machine?ref=WINDOWSVMv1.0.0"

  name                = "winvm-complete-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2s_v3"

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
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 128
  }

  data_disks = [
    {
      name                 = "winvm-complete-data-01"
      lun                  = 0
      caching              = "ReadWrite"
      disk_size_gb         = 64
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "winvm-complete-data-02"
      lun                  = 1
      caching              = "ReadOnly"
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  ]

  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  boot_diagnostics = {
    enabled = true
  }

  windows_profile = {
    timezone = "UTC"
  }

  custom_data = base64encode("<powershell>Write-Output 'hello'</powershell>")

  extensions = [
    {
      name                 = "custom-script"
      publisher            = "Microsoft.Compute"
      type                 = "CustomScriptExtension"
      type_handler_version = "1.10"
      settings = {
        commandToExecute = "powershell -Command \"Write-Output 'Hello from extension'\""
      }
    }
  ]

  diagnostic_settings = [
    {
      name                       = "diag-win-vm-complete"
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
