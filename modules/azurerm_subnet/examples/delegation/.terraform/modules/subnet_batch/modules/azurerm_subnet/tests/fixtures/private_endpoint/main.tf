provider "azurerm" {
  features {}
}

# Get current client configuration
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-pe-${var.random_suffix}"
  location = var.location
}

# Virtual Network for private endpoint
resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-pe-${var.random_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    Example     = "Private-Endpoint"
  }
}

# Storage Account for private endpoint demo
resource "azurerm_storage_account" "example" {
  name                     = "stsubpe${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public access to force private endpoint usage
  public_network_access_enabled = false

  tags = {
    Environment = "Development"
    Purpose     = "Private Endpoint Demo"
  }
}

# Subnet optimized for private endpoints
module "subnet" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.2"

  name                 = "subnet-pe-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Disable network policies for private endpoints (required for private endpoints)
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true

  # No service endpoints needed when using private endpoints
  service_endpoints           = []
  service_endpoint_policy_ids = []
}
