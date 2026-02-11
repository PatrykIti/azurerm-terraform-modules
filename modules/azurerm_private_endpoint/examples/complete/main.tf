provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-pe-complete-example"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-pe-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_storage_account" "example" {
  name                     = "stpecompleteex01"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "vnet-link-blob"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

module "private_endpoint" {
  source = "../../"

  name                          = "pe-complete-example"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  subnet_id                     = azurerm_subnet.private_endpoints.id
  custom_network_interface_name = "pe-complete-nic"

  private_service_connections = [
    {
      name                           = "pe-complete-psc"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.example.id
      subresource_names              = ["blob"]
    }
  ]

  ip_configurations = [
    {
      name               = "blob"
      private_ip_address = "10.20.1.10"
      subresource_name   = "blob"
      member_name        = "blob"
    }
  ]

  private_dns_zone_groups = [
    {
      name                 = "pe-complete-dns"
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
