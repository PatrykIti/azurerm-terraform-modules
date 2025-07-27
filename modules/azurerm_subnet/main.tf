# Azure Subnet Module
# This module creates and manages Azure Subnets with advanced features
# Note: Network Security Group and Route Table associations should be managed
# at the wrapper/composition level for maximum flexibility

# Main Subnet Resource
resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

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
  private_endpoint_network_policies             = var.private_endpoint_network_policies_enabled ? "Enabled" : "Disabled"
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
}