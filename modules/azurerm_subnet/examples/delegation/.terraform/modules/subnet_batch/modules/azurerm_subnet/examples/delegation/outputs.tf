# Outputs for Subnet Delegation Example

# Container Instances Subnet
output "container_instances_subnet_id" {
  description = "The ID of the Container Instances delegated subnet"
  value       = module.subnet_container_instances.id
}

output "container_instances_subnet_name" {
  description = "The name of the Container Instances delegated subnet"
  value       = module.subnet_container_instances.name
}

output "container_instances_delegations" {
  description = "The delegations configured on the Container Instances subnet"
  value       = module.subnet_container_instances.delegations
}

# PostgreSQL Subnet
output "postgresql_subnet_id" {
  description = "The ID of the PostgreSQL delegated subnet"
  value       = module.subnet_postgresql.id
}

output "postgresql_subnet_name" {
  description = "The name of the PostgreSQL delegated subnet"
  value       = module.subnet_postgresql.name
}

output "postgresql_delegations" {
  description = "The delegations configured on the PostgreSQL subnet"
  value       = module.subnet_postgresql.delegations
}

# App Service Subnet
output "app_service_subnet_id" {
  description = "The ID of the App Service delegated subnet"
  value       = module.subnet_app_service.id
}

output "app_service_subnet_name" {
  description = "The name of the App Service delegated subnet"
  value       = module.subnet_app_service.name
}

output "app_service_delegations" {
  description = "The delegations configured on the App Service subnet"
  value       = module.subnet_app_service.delegations
}

# Batch Subnet
output "batch_subnet_id" {
  description = "The ID of the Batch delegated subnet"
  value       = module.subnet_batch.id
}

output "batch_subnet_name" {
  description = "The name of the Batch delegated subnet"
  value       = module.subnet_batch.name
}

output "batch_delegations" {
  description = "The delegations configured on the Batch subnet"
  value       = module.subnet_batch.delegations
}

# Regular Subnet
output "regular_subnet_id" {
  description = "The ID of the regular (non-delegated) subnet"
  value       = module.subnet_regular.id
}

output "regular_subnet_name" {
  description = "The name of the regular (non-delegated) subnet"
  value       = module.subnet_regular.name
}

# Container Group
output "container_group_id" {
  description = "The ID of the Container Group deployed in the delegated subnet"
  value       = azurerm_container_group.example.id
}

output "container_group_ip_address" {
  description = "The private IP address of the Container Group"
  value       = azurerm_container_group.example.ip_address
}

# General
output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.example.name
}

# Subnet Address Prefixes
output "all_subnet_address_prefixes" {
  description = "Address prefixes for all subnets"
  value = {
    container_instances = module.subnet_container_instances.address_prefixes
    postgresql          = module.subnet_postgresql.address_prefixes
    app_service         = module.subnet_app_service.address_prefixes
    batch               = module.subnet_batch.address_prefixes
    regular             = module.subnet_regular.address_prefixes
  }
}