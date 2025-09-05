provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-complete-example"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

# Create Storage Account for service endpoint policy
resource "azurerm_storage_account" "example" {
  name                     = "stsubnetcompletetest"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Purpose     = "Service Endpoint Demo"
  }
}

module "subnet" {
  source = "../../../"

  name                 = "subnetexample002"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]

  # Service endpoints configuration
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]

  # Subnet delegation for Container Instances
  delegations = {
    container_instances = {
      name = "container_instances_delegation"
      service_delegation = {
        name = "Microsoft.ContainerInstance/containerGroups"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
        ]
      }
    }
  }

  # Network policies
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
}
