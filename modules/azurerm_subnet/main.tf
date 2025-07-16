# Azure Subnet Module
# This module creates and manages Azure Subnets with advanced features

# Local values for resource configuration
locals {
  # Resource naming convention  
  resource_name = var.name
  
  # Merge default tags with user-provided tags
  tags = merge(
    {
      Module    = "azurerm_subnet"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

# Main Subnet Resource
resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  # Network Security Group association
  # This is deprecated in favor of azurerm_subnet_network_security_group_association
  # but we'll handle it in later subtasks

  # Route Table association  
  # This is deprecated in favor of azurerm_subnet_route_table_association
  # but we'll handle it in later subtasks

  # Service Endpoints
  service_endpoints = var.service_endpoints

  # Service Endpoint Policies
  service_endpoint_policy_ids = var.service_endpoint_policy_ids

  # Subnet Delegation
  dynamic "delegation" {
    for_each = var.delegations

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  # Network Policies
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
}

# Network Security Group Association (separate resource)
resource "azurerm_subnet_network_security_group_association" "subnet" {
  count = var.network_security_group_id != null ? 1 : 0

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = var.network_security_group_id
}

# Route Table Association (separate resource)
resource "azurerm_subnet_route_table_association" "subnet" {
  count = var.route_table_id != null ? 1 : 0

  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = var.route_table_id
}