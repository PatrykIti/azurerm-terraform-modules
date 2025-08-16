# Secure AKS Cluster Example
# This example demonstrates a hardened AKS cluster configuration with security best practices

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
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

# Create resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create Log Analytics Workspace for monitoring and security
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnet for AKS nodes
resource "azurerm_subnet" "nodes" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group for nodes
resource "azurerm_network_security_group" "example" {
  name                = var.nsg_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Associate NSG with node subnet
resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = azurerm_subnet.nodes.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Create User Assigned Identity for the cluster
resource "azurerm_user_assigned_identity" "example" {
  name                = var.user_assigned_identity_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create secure AKS cluster
module "kubernetes_cluster" {
  source = "../../"

  # Core configuration
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration
  dns_config = {
    dns_prefix = var.dns_prefix
  }

  # Kubernetes configuration
  kubernetes_config = {
    kubernetes_version        = "1.30.12" # Updated to a supported version
    automatic_upgrade_channel = "stable"
    node_os_upgrade_channel   = "NodeImage"
  }

  # SKU configuration - Standard for security features
  sku_config = {
    sku_tier     = "Standard"
    support_plan = "KubernetesOfficial"
  }

  # Node resource group
  node_resource_group = var.node_resource_group_name

  # Identity configuration - User Assigned for better control
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  # Secure default node pool
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D2s_v3"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
    node_count           = 1
    vnet_subnet_id       = azurerm_subnet.nodes.id

    # Security hardening
    os_disk_type                 = "Managed" # Changed from Ephemeral due to VM size constraints
    os_sku                       = "AzureLinux"
    host_encryption_enabled      = false # Enable if supported by subscription
    node_public_ip_enabled       = false
    only_critical_addons_enabled = true
    fips_enabled                 = false # Enable for FIPS compliance

    # Availability zones for resilience
    zones = ["2"] # Only zone 2 is supported in North Europe for this configuration

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "secure"
    }

    upgrade_settings = {
      max_surge = "33%"
    }
  }

  # Network configuration
  network_profile = {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
    outbound_type     = "loadBalancer"

    load_balancer_profile = {
      managed_outbound_ip_count = 1
      idle_timeout_in_minutes   = 4
    }
  }

  # Security features
  features = {
    azure_policy_enabled             = true
    http_application_routing_enabled = false
    workload_identity_enabled        = true
    oidc_issuer_enabled              = true
    open_service_mesh_enabled        = false
    image_cleaner_enabled            = true
    run_command_enabled              = false # Disable for security
    local_account_disabled           = true  # Disable local accounts
    cost_analysis_enabled            = true
  }

  # Image cleaner configuration
  image_cleaner_interval_hours = 48

  # Private cluster configuration
  private_cluster_config = {
    private_cluster_enabled             = false # Set to true for private cluster
    private_cluster_public_fqdn_enabled = false
  }

  # API Server Access Profile - Restrict access
  api_server_access_profile = {
    authorized_ip_ranges = ["0.0.0.0/0"] # Replace with your IP ranges
  }

  # Azure AD RBAC configuration
  azure_active_directory_role_based_access_control = {
    azure_rbac_enabled = true
    tenant_id          = "b8e7b798-6929-432e-b94b-8a117708f2c5" # Using the provided tenant ID
  }

  # Enable monitoring
  oms_agent = {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.example.id
    msi_auth_for_monitoring_enabled = true
  }

  # Microsoft Defender for Cloud
  microsoft_defender = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  }

  # Key Vault Secrets Provider
  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Monitor metrics
  monitor_metrics = {
    annotations_allowed = null
    labels_allowed      = null
  }

  # Maintenance windows
  maintenance_window = {
    allowed = [
      {
        day   = "Saturday"
        hours = [1, 2, 3, 4]
      },
      {
        day   = "Sunday"
        hours = [1, 2, 3, 4]
      }
    ]
  }


  tags = {
    Environment = "Production"
    Example     = "Secure"
    Security    = "Hardened"
  }
}
