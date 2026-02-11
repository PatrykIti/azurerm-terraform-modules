provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-pe-basic-example"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pe-basic-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.10.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_storage_account" "example" {
  name                     = "stpebasicexample01"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
}

module "private_endpoint" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_private_endpoint?ref=PEv1.0.0"

  name                = "pe-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connections = [
    {
      name                           = "pe-basic-psc"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.example.id
      subresource_names              = ["blob"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
