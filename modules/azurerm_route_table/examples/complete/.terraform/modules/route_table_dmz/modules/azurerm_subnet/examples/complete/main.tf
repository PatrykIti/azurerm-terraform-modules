# Complete Subnet Example
# This example demonstrates a comprehensive Subnet configuration with all features

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-complete-example"
  location = var.location
}

# Create a Virtual Network for the subnet
resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Example     = "Complete"
    Purpose     = "Subnet Complete Example"
  }
}

# Create Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "nsg-subnet-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Allow HTTP inbound
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS inbound
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
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

# Create Route Table
resource "azurerm_route_table" "example" {
  name                = "rt-subnet-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Route to force traffic through a virtual appliance
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

# Create Storage Account for service endpoint policy
resource "azurerm_storage_account" "example" {
  name                     = "stsubnetcompleteexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Purpose     = "Service Endpoint Demo"
  }
}

# Create Service Endpoint Policy
resource "azurerm_subnet_service_endpoint_storage_policy" "example" {
  name                = "sep-storage-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  definition {
    name        = "AllowSpecificStorage"
    description = "Allow access to specific storage account"
    service_resources = [
      azurerm_storage_account.example.id,
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/*/providers/Microsoft.Storage/storageAccounts/account1",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/*/providers/Microsoft.Storage/storageAccounts/account2"
    ]
  }

  tags = {
    Environment = "Development"
    Purpose     = "Service Endpoint Policy"
  }
}

# Complete Subnet configuration with all features
module "subnet" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_route_table?ref=RTv1.0.4"

  name                 = "subnet-complete-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]

  # Service Endpoints for multiple Azure services
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.EventHub",
    "Microsoft.ServiceBus"
  ]

  # Service Endpoint Policies
  service_endpoint_policy_ids = [
    azurerm_subnet_service_endpoint_storage_policy.example.id
  ]

  # Network Policies
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Associate Network Security Group with Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = module.subnet.id
  network_security_group_id = azurerm_network_security_group.example.id

  depends_on = [module.subnet]
}

# Associate Route Table with Subnet
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = module.subnet.id
  route_table_id = azurerm_route_table.example.id

  depends_on = [module.subnet]
}