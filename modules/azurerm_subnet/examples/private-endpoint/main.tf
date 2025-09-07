# Secure Subnet Example
# This example demonstrates a security-focused Subnet configuration

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-subnet-secure-example"
  location = var.location
}

# Create DDoS Protection Plan for enhanced security
resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "ddos-subnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Production"
    Purpose     = "DDoS Protection"
  }
}

# Create a Virtual Network with DDoS protection
resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # DDoS Protection Plan
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  tags = {
    Environment   = "Production"
    Example       = "Secure"
    Purpose       = "Secure Virtual Network"
    SecurityLevel = "High"
  }
}

# Create Log Analytics Workspace for security monitoring
resource "azurerm_log_analytics_workspace" "security" {
  name                = "law-subnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90 # Extended retention for security logs

  tags = {
    Environment = "Production"
    Purpose     = "Security Monitoring"
  }
}

# Create Storage Account for security logs
resource "azurerm_storage_account" "security" {
  name                     = "stsubnetsecureexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant for security logs

  # Security settings
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  shared_access_key_enabled       = true # Required for flow logs
  allow_nested_items_to_be_public = false

  tags = {
    Environment = "Production"
    Purpose     = "Security Logs Storage"
  }
}

# Create Network Watcher for flow logs
resource "azurerm_network_watcher" "example" {
  name                = "nw-subnet-secure-example-${var.location}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Production"
    Purpose     = "Network Monitoring"
  }
}

# Create highly restrictive Network Security Group
resource "azurerm_network_security_group" "secure" {
  name                = "nsg-subnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Allow only HTTPS inbound from specific IP ranges
  security_rule {
    name                       = "AllowHTTPSFromTrustedIPs"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = ["203.0.113.0/24", "198.51.100.0/24"] # Replace with your trusted IP ranges
    destination_address_prefix = "*"
  }

  # Allow internal VNet communication
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound to Azure services via service tags
  security_rule {
    name                         = "AllowAzureServicesOutbound"
    priority                     = 1000
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "443"
    source_address_prefix        = "*"
    destination_address_prefixes = ["Storage", "KeyVault", "AzureActiveDirectory"]
  }

  # Allow internal VNet communication outbound
  security_rule {
    name                       = "AllowVNetOutbound"
    priority                   = 1100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Deny all other outbound traffic
  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment   = "Production"
    Purpose       = "Network Security"
    SecurityLevel = "High"
  }
}

# Create Route Table with security-focused routing
resource "azurerm_route_table" "secure" {
  name                = "rt-subnet-secure-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Route internet traffic through security appliance
  route {
    name                   = "RouteToSecurityAppliance"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.10.4" # Replace with your security appliance IP
  }


  tags = {
    Environment   = "Production"
    Purpose       = "Secure Routing"
    SecurityLevel = "High"
  }
}

# Secure Subnet configuration
module "subnet" {
  source = "../../"

  name                 = "subnet-secure-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service endpoints for secure access to Azure services
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]

  # No service endpoint policies in this example for simplicity
  service_endpoint_policy_ids = []

  # Enable network policies for enhanced security
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Associate Network Security Group with Subnet
resource "azurerm_subnet_network_security_group_association" "secure" {
  subnet_id                 = module.subnet.id
  network_security_group_id = azurerm_network_security_group.secure.id

  depends_on = [module.subnet]
}

# Associate Route Table with Subnet
resource "azurerm_subnet_route_table_association" "secure" {
  subnet_id      = module.subnet.id
  route_table_id = azurerm_route_table.secure.id

  depends_on = [module.subnet]
}

# Network Watcher Flow Log for security monitoring
resource "azurerm_network_watcher_flow_log" "secure" {
  network_watcher_name = azurerm_network_watcher.example.name
  resource_group_name  = azurerm_resource_group.example.name
  name                 = "${module.subnet.name}-flowlog"
  target_resource_id   = azurerm_network_security_group.secure.id
  storage_account_id   = azurerm_storage_account.security.id
  enabled              = true
  version              = 2

  retention_policy {
    enabled = true
    days    = 90
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.security.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.security.location
    workspace_resource_id = azurerm_log_analytics_workspace.security.id
    interval_in_minutes   = 10
  }

  tags = {
    Environment   = "Production"
    Example       = "Secure"
    Purpose       = "Security Monitoring"
    SecurityLevel = "High"
  }

  depends_on = [module.subnet]
}