# Network integration test fixture
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-subnet-network-test"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-subnet-network-test"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}

# Test with network security group association
resource "azurerm_network_security_group" "test" {
  name                = "nsg-subnet-network-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

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
    Environment = "Test"
    Scenario    = "Network"
  }
}

# Test with service endpoints
module "subnet" {
  source = "../../../"

  name                 = "subnetnetworktest"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service endpoints for network testing
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]

  # Network policies
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = module.subnet.id
  network_security_group_id = azurerm_network_security_group.test.id
}
