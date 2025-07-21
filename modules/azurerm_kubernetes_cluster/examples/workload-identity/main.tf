# Workload Identity AKS Cluster Example
# This example creates an AKS cluster with Azure AD RBAC and Workload Identity enabled

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Get current user/service principal
data "azuread_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create an Azure AD group for AKS administrators
resource "azuread_group" "aks_admins" {
  display_name     = var.aks_admins_group_name
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
  
  description = "AKS Administrators for workload identity example cluster"
}

# Add current user to the AKS admins group
resource "azuread_group_member" "current_user" {
  group_object_id  = azuread_group.aks_admins.object_id
  member_object_id = data.azuread_client_config.current.object_id
}

# Create a virtual network for the cluster
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet for the AKS nodes
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the AKS cluster with workload identity
module "kubernetes_cluster" {
  source = "../../"

  # Basic cluster configuration
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration
  dns_config = {
    dns_prefix = var.dns_prefix
  }

  # Use system-assigned managed identity
  identity = {
    type         = "SystemAssigned"
    identity_ids = null
  }

  # Minimal node pool for cost savings
  default_node_pool = {
    name                 = "default"
    vm_size              = "Standard_D2s_v3"
    node_count           = 2
    auto_scaling_enabled = false
    vnet_subnet_id       = azurerm_subnet.example.id
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  # Enable Azure AD RBAC
  azure_active_directory_role_based_access_control = {
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = [azuread_group.aks_admins.object_id]
    azure_rbac_enabled     = true
  }

  # Enable workload identity and OIDC
  features = {
    azure_policy_enabled             = false
    http_application_routing_enabled = false
    workload_identity_enabled        = true   # Enable workload identity
    oidc_issuer_enabled              = true   # Enable OIDC issuer
    open_service_mesh_enabled        = false
    image_cleaner_enabled            = false
    run_command_enabled              = true
    local_account_disabled           = true   # Disable local accounts for security
    cost_analysis_enabled            = false
  }

  # Basic network profile
  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  # Free tier for cost savings
  sku_config = {
    sku_tier     = "Free"
    support_plan = "KubernetesOfficial"
  }

  tags = {
    Environment = "Development"
    Example     = "WorkloadIdentity"
    Features    = "RBAC,OIDC"
  }
}

# Example: Create a demo managed identity for workload identity
resource "azurerm_user_assigned_identity" "example_workload" {
  name                = var.workload_identity_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

# Create federated identity credential for the workload identity
resource "azurerm_federated_identity_credential" "example" {
  name                = "example-federated-credential"
  resource_group_name = azurerm_resource_group.example.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.kubernetes_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.example_workload.id
  subject             = "system:serviceaccount:default:workload-identity-sa"
}

# Example: Grant the workload identity access to a resource (e.g., Key Vault)
resource "azurerm_key_vault" "example" {
  name                = var.key_vault_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = "standard"
  
  enable_rbac_authorization = true
  purge_protection_enabled  = false # Disabled for easy cleanup in examples
}

# Grant the workload identity access to the Key Vault
resource "azurerm_role_assignment" "workload_identity_key_vault" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.example_workload.principal_id
}