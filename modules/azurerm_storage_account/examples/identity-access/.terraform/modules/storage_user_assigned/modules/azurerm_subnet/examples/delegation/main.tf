# Subnet Delegation Example
# This example demonstrates subnet delegation for Azure services

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
  name     = "rg-subnet-delegation-example"
  location = var.location
}

# Create a Virtual Network for subnet delegation
resource "azurerm_virtual_network" "example" {
  name                = "vnet-subnet-delegation-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Example     = "Delegation"
    Purpose     = "Subnet Delegation Demo"
  }
}

# Subnet delegated to Azure Container Instances
module "subnet_container_instances" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  name                 = "subnet-container-instances"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Service endpoints that work well with Container Instances
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]

  # Delegation to Azure Container Instances
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

  # Standard network policies
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Subnet delegated to Azure Database for PostgreSQL Flexible Server
module "subnet_postgresql" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  name                 = "subnet-postgresql"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  # No service endpoints needed for delegated subnet
  service_endpoints = []

  # Delegation to PostgreSQL Flexible Server
  delegations = {
    postgresql = {
      name = "postgresql_delegation"
      service_delegation = {
        name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }

  # Network policies must be disabled for database delegations
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  depends_on = [azurerm_virtual_network.example]
}

# Subnet delegated to Azure App Service (Web Apps)
module "subnet_app_service" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  name                 = "subnet-app-service"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]

  # Service endpoints commonly used with App Service
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]

  # Delegation to Azure App Service
  delegations = {
    app_service = {
      name = "app_service_delegation"
      service_delegation = {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action"
        ]
      }
    }
  }

  # Standard network policies for App Service
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Subnet delegated to Azure Batch
module "subnet_batch" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  name                 = "subnet-batch"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.4.0/24"]

  # Service endpoints for Batch scenarios
  service_endpoints = [
    "Microsoft.Storage"
  ]

  # Delegation to Azure Batch
  delegations = {
    batch = {
      name = "batch_delegation"
      service_delegation = {
        name = "Microsoft.Batch/batchAccounts"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action"
        ]
      }
    }
  }

  # Network policies for Batch
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Regular subnet for comparison (no delegation)
module "subnet_regular" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.3"

  name                 = "subnet-regular"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.5.0/24"]

  # No delegations - regular subnet
  delegations = {}

  # Standard configuration
  service_endpoints                             = []
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_virtual_network.example]
}

# Example: Create a Container Instance in the delegated subnet
resource "azurerm_container_group" "example" {
  name                = "aci-delegation-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_address_type     = "Private"
  subnet_ids          = [module.subnet_container_instances.id]
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = {
    Environment = "Development"
    Purpose     = "Delegation Demo"
  }

  depends_on = [module.subnet_container_instances]
}