terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-complete-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg-subnet-complete-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Development"
    Purpose     = "Subnet Security"
  }
}

resource "azurerm_route_table" "example" {
  name                = "rt-subnet-complete-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  route {
    name                   = "RouteToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.10.4"
  }

  tags = {
    Environment = "Development"
    Purpose     = "Subnet Routing"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "stsubnet${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Purpose     = "Service Endpoint Demo"
  }
}

resource "azurerm_subnet_service_endpoint_storage_policy" "example" {
  name                = "sep-subnet-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  definition {
    name        = "AllowSpecificStorage"
    description = "Allow access to specific storage account"
    service_resources = [
      azurerm_storage_account.example.id
    ]
  }

  tags = {
    Environment = "Development"
    Purpose     = "Service Endpoint Policy"
  }
}

module "subnet" {
  source = "../../../"

  name                 = "snet-subnet-complete-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  # Note: When using delegation, only single address prefix is supported
  address_prefixes = ["10.0.1.0/24"]

  service_endpoints = length(var.service_endpoints) > 0 ? var.service_endpoints : [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]

  service_endpoint_policy_ids = [
    azurerm_subnet_service_endpoint_storage_policy.example.id
  ]

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

  private_endpoint_network_policies_enabled     = var.enforce_private_link_endpoint_network_policies
  private_link_service_network_policies_enabled = true

  associations = {
    network_security_group = {
      id = azurerm_network_security_group.example.id
    }
    route_table = {
      id = azurerm_route_table.example.id
    }
  }
}
