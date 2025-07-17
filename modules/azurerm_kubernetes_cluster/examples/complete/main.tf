# Complete AKS Cluster Example
# This example demonstrates a comprehensive AKS cluster configuration with advanced features

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
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

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-aks-complete-${random_string.suffix.result}"
  location = var.location
}

# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-complete-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnet for AKS nodes
resource "azurerm_subnet" "nodes" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create subnet for pods (if using Azure CNI with custom pod subnet)
resource "azurerm_subnet" "pods" {
  name                 = "snet-aks-pods"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.4.0/22"]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

# Create Network Security Group for nodes
resource "azurerm_network_security_group" "example" {
  name                = "nsg-aks-nodes-${random_string.suffix.result}"
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
  name                = "uai-aks-complete-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create the AKS cluster with comprehensive configuration
module "kubernetes_cluster" {
  source = "../../"

  # Core configuration
  name                = "aks-complete-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  # DNS configuration
  dns_config = {
    dns_prefix = "aks-complete-${random_string.suffix.result}"
  }

  # Kubernetes configuration
  kubernetes_config = {
    kubernetes_version        = var.kubernetes_version
    automatic_upgrade_channel = "stable"
    node_os_upgrade_channel   = "NodeImage"
  }

  # SKU configuration
  sku_config = {
    sku_tier     = "Standard"
    support_plan = "KubernetesOfficial"
  }

  # Node resource group
  node_resource_group = "rg-aks-nodes-${random_string.suffix.result}"

  # Identity configuration
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  # Comprehensive default node pool configuration
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D4s_v3"
    node_count           = 2
    auto_scaling_enabled = true
    min_count            = 2
    max_count            = 5
    vnet_subnet_id       = azurerm_subnet.nodes.id

    # VM configuration
    os_disk_size_gb      = 100
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    orchestrator_version = var.kubernetes_version

    # Security and features
    host_encryption_enabled      = false
    node_public_ip_enabled       = false
    only_critical_addons_enabled = true
    fips_enabled                 = false

    # Advanced configuration
    max_pods          = 110
    scale_down_mode   = "Delete"
    ultra_ssd_enabled = false
    zones             = ["1"]

    # Node labels
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "production"
      "nodepoolos"    = "linux"
    }

    # Kubelet configuration
    kubelet_config = {
      cpu_manager_policy      = "static"
      cpu_cfs_quota_enabled   = true
      cpu_cfs_quota_period    = "100ms"
      image_gc_high_threshold = 85
      image_gc_low_threshold  = 80
      topology_manager_policy = "best-effort"
      pod_max_pid             = -1
    }

    # Linux OS configuration
    linux_os_config = {
      transparent_huge_page        = "always"
      transparent_huge_page_defrag = "madvise"
      swap_file_size_mb            = 0

      sysctl_config = {
        kernel_threads_max                 = 200000
        net_core_netdev_max_backlog        = 5000
        net_core_rmem_max                  = 134217728
        net_core_wmem_max                  = 134217728
        net_core_rmem_default              = 262144
        net_core_wmem_default              = 262144
        net_ipv4_tcp_max_syn_backlog       = 4096
        net_ipv4_tcp_keepalive_time        = 7200
        net_ipv4_tcp_keepalive_probes      = 9
        net_ipv4_tcp_keepalive_intvl       = 75
        net_ipv4_tcp_tw_reuse              = false
        net_netfilter_nf_conntrack_max     = 1000000
        net_netfilter_nf_conntrack_buckets = 262144
        fs_file_max                        = 2097152
        fs_inotify_max_user_watches        = 1048576
        fs_nr_open                         = 1048576
        vm_max_map_count                   = 262144
        vm_swappiness                      = 10
        vm_vfs_cache_pressure              = 100
      }
    }

    # Upgrade settings
    upgrade_settings = {
      max_surge                     = "33%"
      drain_timeout_in_minutes      = 30
      node_soak_duration_in_minutes = 0
    }
  }

  # Advanced network profile
  network_profile = {
    network_plugin      = "azure"
    network_mode        = "transparent"
    network_policy      = "azure"
    network_plugin_mode = "overlay"
    outbound_type       = "loadBalancer"
    load_balancer_sku   = "standard"

    # Service and pod CIDRs
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"

    # Load balancer configuration
    load_balancer_profile = {
      managed_outbound_ip_count = 2
      idle_timeout_in_minutes   = 30
      outbound_ports_allocated  = 0
    }
  }

  # Feature flags
  features = {
    azure_policy_enabled             = true
    http_application_routing_enabled = false
    workload_identity_enabled        = true
    oidc_issuer_enabled              = true
    open_service_mesh_enabled        = false
    image_cleaner_enabled            = true
    run_command_enabled              = false
    local_account_disabled           = false
    cost_analysis_enabled            = true
  }

  image_cleaner_interval_hours = 48

  # API Server Access Profile (for public clusters)
  api_server_access_profile = {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  # Azure AD RBAC configuration
  azure_active_directory_role_based_access_control = {
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }

  # OMS Agent (Container Insights)
  oms_agent = {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.example.id
    msi_auth_for_monitoring_enabled = true
  }

  # Auto scaler profile
  auto_scaler_profile = {
    balance_similar_node_groups      = true
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "0s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }

  # Key Vault Secrets Provider
  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Maintenance windows
  maintenance_window_auto_upgrade = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "00:00"
    utc_offset  = "+00:00"

    not_allowed = [
      {
        start = "2024-12-24T00:00:00Z"
        end   = "2024-12-26T23:59:59Z"
      }
    ]
  }

  maintenance_window_node_os = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "04:00"
    utc_offset  = "+00:00"
  }

  # Workload autoscaler profile
  workload_autoscaler_profile = {
    keda_enabled                    = true
    vertical_pod_autoscaler_enabled = true
  }

  tags = merge(var.common_tags, {
    Environment = "Production"
    Example     = "Complete"
  })
}
