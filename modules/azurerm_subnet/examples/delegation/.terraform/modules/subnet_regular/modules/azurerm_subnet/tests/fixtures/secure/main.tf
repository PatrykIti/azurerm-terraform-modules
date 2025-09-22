provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment   = "Production"
    Example       = "Secure"
    SecurityLevel = "High"
  }
}

module "subnet" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_subnet?ref=SNv1.0.3"

  name                 = "subnet-secure-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service endpoints for secure access to Azure services
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]

  # Enable network policies for enhanced security
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
}
