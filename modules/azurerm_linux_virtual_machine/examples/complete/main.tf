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

locals {
  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - curl
    runcmd:
      - echo "hello from cloud-init" > /var/tmp/hello.txt
  EOT
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-linux-vm-complete"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-linux-vm-complete"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "pip-linux-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "example" {
  name                = "nic-linux-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-linux-vm-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-linux-vm-complete"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "linux_virtual_machine" {
  source = "../../"

  name                = "linuxvm-complete-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B2s"

  network = {
    network_interface_ids = [azurerm_network_interface.example.id]
  }

  admin = {
    username                        = "azureuser"
    disable_password_authentication = true
    ssh_keys = [
      {
        username   = "azureuser"
        public_key = tls_private_key.example.public_key_openssh
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
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  data_disks = [
    {
      name                 = "linuxvm-complete-data-0"
      lun                  = 0
      caching              = "ReadOnly"
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    },
    {
      name                 = "linuxvm-complete-data-1"
      lun                  = 1
      caching              = "None"
      disk_size_gb         = 256
      storage_account_type = "Premium_LRS"
    }
  ]

  boot_diagnostics = {
    enabled             = true
    storage_account_uri = azurerm_storage_account.example.primary_blob_endpoint
  }

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  additional_capabilities = {
    ultra_ssd_enabled = false
  }

  patching = {
    patch_mode            = "AutomaticByPlatform"
    patch_assessment_mode = "AutomaticByPlatform"
    reboot_setting        = "IfRequired"
  }

  runtime = {
    custom_data = base64encode(local.cloud_init)
  }

  extensions = [
    {
      name                 = "custom-script"
      publisher            = "Microsoft.Azure.Extensions"
      type                 = "CustomScript"
      type_handler_version = "2.1"
      settings = {
        commandToExecute = "echo hello > /var/tmp/extension.txt"
      }
    }
  ]

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      metric_categories          = ["AllMetrics"]
    }
  ]

  tags = {
    Environment = "Test"
    Example     = "Complete"
  }
}
