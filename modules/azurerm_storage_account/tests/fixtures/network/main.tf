provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "test" {
  name     = "rg-devpciti-net-${var.random_suffix}"
  location = var.location
}

# Virtual network with multiple subnets
resource "azurerm_virtual_network" "test" {
  name                = "vnet-devpciti-net-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "storage" {
  name                 = "subnet-storage"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

module "storage_account" {
  source = "../../../"

  name                     = "dpcnet${random_string.suffix.result}${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable shared access key for tests
  security_settings = {
    shared_access_key_enabled = true
  }

  # Network rules with multiple configurations
  network_rules = {
    default_action = "Deny"
    ip_rules = [
      "203.0.113.0/24",  # Test IP range 1
      "198.51.100.0/24", # Test IP range 2
      "192.0.2.1"        # Single IP
    ]
    subnet_ids = [
      azurerm_subnet.storage.id,
      azurerm_subnet.app.id
    ]
    bypass = ["AzureServices"]
  }

  # Blob properties with CORS rules
  blob_properties = {
    cors_rules = [
      {
        allowed_origins    = ["https://example.com", "https://test.example.com"]
        allowed_methods    = ["GET", "POST", "PUT"]
        allowed_headers    = ["*"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    ]
  }

  tags = {
    Environment = "Test"
    TestType    = "Network"
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "primary_blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}

output "subnet_ids" {
  value = [azurerm_subnet.storage.id, azurerm_subnet.app.id]
}