# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # DNS Configuration - One of dns_prefix or dns_prefix_private_cluster is required
  dns_prefix                 = var.dns_config.dns_prefix
  dns_prefix_private_cluster = var.dns_config.dns_prefix_private_cluster

  # Kubernetes Version and Upgrade Configuration
  kubernetes_version        = var.kubernetes_config.kubernetes_version
  automatic_upgrade_channel = var.kubernetes_config.automatic_upgrade_channel
  node_os_upgrade_channel   = var.kubernetes_config.node_os_upgrade_channel

  # SKU Configuration
  sku_tier     = var.sku_config.sku_tier
  support_plan = var.sku_config.support_plan

  # Node Resource Group
  node_resource_group = var.node_resource_group

  # Private Cluster Configuration
  private_cluster_enabled             = var.private_cluster_config.private_cluster_enabled
  private_dns_zone_id                 = var.private_cluster_config.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_config.private_cluster_public_fqdn_enabled

  # Feature Flags
  azure_policy_enabled             = var.features.azure_policy_enabled
  http_application_routing_enabled = var.features.http_application_routing_enabled
  workload_identity_enabled        = var.features.workload_identity_enabled
  oidc_issuer_enabled              = var.features.oidc_issuer_enabled
  open_service_mesh_enabled        = var.features.open_service_mesh_enabled
  image_cleaner_enabled            = var.features.image_cleaner_enabled
  run_command_enabled              = var.features.run_command_enabled
  local_account_disabled           = var.features.local_account_disabled
  cost_analysis_enabled            = var.features.cost_analysis_enabled

  # Image Cleaner Configuration
  image_cleaner_interval_hours = var.features.image_cleaner_enabled ? var.image_cleaner_interval_hours : null

  # Encryption Configuration
  disk_encryption_set_id = var.disk_encryption_set_id

  # Edge Zone
  edge_zone = var.edge_zone

  # Default Node Pool - Required
  default_node_pool {
    name    = var.default_node_pool.name
    vm_size = var.default_node_pool.vm_size

    # Node Count Configuration
    node_count           = var.default_node_pool.node_count
    auto_scaling_enabled = var.default_node_pool.auto_scaling_enabled
    min_count            = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.min_count : null
    max_count            = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.max_count : null

    # VM Configuration
    capacity_reservation_group_id = var.default_node_pool.capacity_reservation_group_id
    host_encryption_enabled       = var.default_node_pool.host_encryption_enabled
    node_public_ip_enabled        = var.default_node_pool.node_public_ip_enabled
    gpu_instance                  = var.default_node_pool.gpu_instance
    host_group_id                 = var.default_node_pool.host_group_id

    # OS Configuration
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    os_disk_type         = var.default_node_pool.os_disk_type
    os_sku               = var.default_node_pool.os_sku
    orchestrator_version = var.default_node_pool.orchestrator_version

    # Network Configuration
    vnet_subnet_id           = var.default_node_pool.vnet_subnet_id
    pod_subnet_id            = var.default_node_pool.pod_subnet_id
    node_public_ip_prefix_id = var.default_node_pool.node_public_ip_prefix_id

    # Advanced Configuration
    fips_enabled                 = var.default_node_pool.fips_enabled
    kubelet_disk_type            = var.default_node_pool.kubelet_disk_type
    max_pods                     = var.default_node_pool.max_pods
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    proximity_placement_group_id = var.default_node_pool.proximity_placement_group_id
    scale_down_mode              = var.default_node_pool.scale_down_mode
    snapshot_id                  = var.default_node_pool.snapshot_id
    temporary_name_for_rotation  = var.default_node_pool.temporary_name_for_rotation
    type                         = var.default_node_pool.type
    ultra_ssd_enabled            = var.default_node_pool.ultra_ssd_enabled
    workload_runtime             = var.default_node_pool.workload_runtime
    zones                        = var.default_node_pool.zones

    # Node Labels
    node_labels = var.default_node_pool.node_labels

    # Kubelet Configuration
    dynamic "kubelet_config" {
      for_each = var.default_node_pool.kubelet_config != null ? [var.default_node_pool.kubelet_config] : []
      content {
        allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
        container_log_max_line    = kubelet_config.value.container_log_max_line
        container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
        cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
        cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
        cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
        image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
        image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
        pod_max_pid               = kubelet_config.value.pod_max_pid
        topology_manager_policy   = kubelet_config.value.topology_manager_policy
      }
    }

    # Linux OS Configuration
    dynamic "linux_os_config" {
      for_each = var.default_node_pool.linux_os_config != null ? [var.default_node_pool.linux_os_config] : []
      content {
        swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
        transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
        transparent_huge_page        = linux_os_config.value.transparent_huge_page

        dynamic "sysctl_config" {
          for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
          content {
            fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
            fs_file_max                        = sysctl_config.value.fs_file_max
            fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
            fs_nr_open                         = sysctl_config.value.fs_nr_open
            kernel_threads_max                 = sysctl_config.value.kernel_threads_max
            net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
            net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
            net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
            net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
            net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
            net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
            net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
            net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
            net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
            net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
            net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
            net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
            net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
            net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
            net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
            net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
            net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
            net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
            net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
            net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
            net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
            vm_max_map_count                   = sysctl_config.value.vm_max_map_count
            vm_swappiness                      = sysctl_config.value.vm_swappiness
            vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
          }
        }
      }
    }

    # Node Network Profile
    dynamic "node_network_profile" {
      for_each = var.default_node_pool.node_network_profile != null ? [var.default_node_pool.node_network_profile] : []
      content {
        application_security_group_ids = node_network_profile.value.application_security_group_ids
        node_public_ip_tags            = node_network_profile.value.node_public_ip_tags

        dynamic "allowed_host_ports" {
          for_each = node_network_profile.value.allowed_host_ports != null ? node_network_profile.value.allowed_host_ports : []
          content {
            port_start = allowed_host_ports.value.port_start
            port_end   = allowed_host_ports.value.port_end
            protocol   = allowed_host_ports.value.protocol
          }
        }
      }
    }

    # Upgrade Settings
    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings != null ? [var.default_node_pool.upgrade_settings] : []
      content {
        drain_timeout_in_minutes      = upgrade_settings.value.drain_timeout_in_minutes
        max_surge                     = upgrade_settings.value.max_surge
        node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
      }
    }
  }

  # Identity Configuration - One of identity or service_principal must be specified
  dynamic "identity" {
    for_each = var.service_principal == null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  # Service Principal Configuration (Alternative to Identity)
  dynamic "service_principal" {
    for_each = var.service_principal != null ? [var.service_principal] : []
    content {
      client_id     = service_principal.value.client_id
      client_secret = service_principal.value.client_secret
    }
  }

  # Network Profile
  network_profile {
    network_plugin      = var.network_profile.network_plugin
    network_mode        = var.network_profile.network_mode
    network_policy      = var.network_profile.network_policy
    dns_service_ip      = var.network_profile.dns_service_ip
    network_plugin_mode = var.network_profile.network_plugin_mode
    outbound_type       = var.network_profile.outbound_type
    pod_cidr            = var.network_profile.pod_cidr
    pod_cidrs           = var.network_profile.pod_cidrs
    service_cidr        = var.network_profile.service_cidr
    service_cidrs       = var.network_profile.service_cidrs
    ip_versions         = var.network_profile.ip_versions
    load_balancer_sku   = var.network_profile.load_balancer_sku

    # Load Balancer Profile
    dynamic "load_balancer_profile" {
      for_each = var.network_profile.load_balancer_profile != null ? [var.network_profile.load_balancer_profile] : []
      content {
        backend_pool_type           = load_balancer_profile.value.backend_pool_type
        idle_timeout_in_minutes     = load_balancer_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count   = load_balancer_profile.value.managed_outbound_ip_count
        managed_outbound_ipv6_count = load_balancer_profile.value.managed_outbound_ipv6_count
        outbound_ip_address_ids     = load_balancer_profile.value.outbound_ip_address_ids
        outbound_ip_prefix_ids      = load_balancer_profile.value.outbound_ip_prefix_ids
        outbound_ports_allocated    = load_balancer_profile.value.outbound_ports_allocated
      }
    }

    # NAT Gateway Profile
    dynamic "nat_gateway_profile" {
      for_each = var.network_profile.nat_gateway_profile != null ? [var.network_profile.nat_gateway_profile] : []
      content {
        idle_timeout_in_minutes   = nat_gateway_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count = nat_gateway_profile.value.managed_outbound_ip_count
      }
    }
  }

  # Storage Profile
  storage_profile {
    blob_driver_enabled         = var.storage_profile.blob_driver_enabled
    disk_driver_enabled         = var.storage_profile.disk_driver_enabled
    file_driver_enabled         = var.storage_profile.file_driver_enabled
    snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
  }

  # API Server Access Profile
  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [var.api_server_access_profile] : []
    content {
      authorized_ip_ranges = api_server_access_profile.value.authorized_ip_ranges
    }
  }

  # Azure Active Directory RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control != null ? [var.azure_active_directory_role_based_access_control] : []
    content {
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
    }
  }

  # OMS Agent (Azure Monitor)
  dynamic "oms_agent" {
    for_each = var.oms_agent != null ? [var.oms_agent] : []
    content {
      log_analytics_workspace_id      = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = oms_agent.value.msi_auth_for_monitoring_enabled
    }
  }

  # Ingress Application Gateway
  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway != null ? [var.ingress_application_gateway] : []
    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
      subnet_id    = ingress_application_gateway.value.subnet_id
    }
  }

  # ACI Connector Linux
  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux != null ? [var.aci_connector_linux] : []
    content {
      subnet_name = aci_connector_linux.value.subnet_name
    }
  }

  # Azure Key Vault Secrets Provider
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  # Auto Scaler Profile
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups                   = auto_scaler_profile.value.balance_similar_node_groups
      daemonset_eviction_for_empty_nodes_enabled    = auto_scaler_profile.value.daemonset_eviction_for_empty_nodes_enabled
      daemonset_eviction_for_occupied_nodes_enabled = auto_scaler_profile.value.daemonset_eviction_for_occupied_nodes_enabled
      empty_bulk_delete_max                         = auto_scaler_profile.value.empty_bulk_delete_max
      expander                                      = auto_scaler_profile.value.expander
      ignore_daemonsets_utilization_enabled         = auto_scaler_profile.value.ignore_daemonsets_utilization_enabled
      max_graceful_termination_sec                  = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time                    = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                             = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage                        = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay                        = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add                    = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete                 = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure                = auto_scaler_profile.value.scale_down_delay_after_failure
      scale_down_unneeded                           = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready                            = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold              = auto_scaler_profile.value.scale_down_utilization_threshold
      scan_interval                                 = auto_scaler_profile.value.scan_interval
      skip_nodes_with_local_storage                 = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods                   = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  # HTTP Proxy Configuration
  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config != null ? [var.http_proxy_config] : []
    content {
      http_proxy  = http_proxy_config.value.http_proxy
      https_proxy = http_proxy_config.value.https_proxy
      no_proxy    = http_proxy_config.value.no_proxy
      trusted_ca  = http_proxy_config.value.trusted_ca
    }
  }

  # Kubelet Identity
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [var.kubelet_identity] : []
    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }

  # Linux Profile
  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [var.linux_profile] : []
    content {
      admin_username = linux_profile.value.admin_username

      ssh_key {
        key_data = linux_profile.value.ssh_key.key_data
      }
    }
  }

  # Windows Profile
  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []
    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
      license        = windows_profile.value.license

      dynamic "gmsa" {
        for_each = windows_profile.value.gmsa != null ? [windows_profile.value.gmsa] : []
        content {
          root_domain = gmsa.value.root_domain
          dns_server  = gmsa.value.dns_server
        }
      }
    }
  }

  # Maintenance Window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed != null ? maintenance_window.value.allowed : []
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed != null ? maintenance_window.value.not_allowed : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  # Maintenance Window Auto Upgrade
  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade != null ? [var.maintenance_window_auto_upgrade] : []
    content {
      duration     = maintenance_window_auto_upgrade.value.duration
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      start_date   = maintenance_window_auto_upgrade.value.start_date
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      week_index   = maintenance_window_auto_upgrade.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed != null ? maintenance_window_auto_upgrade.value.not_allowed : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  # Maintenance Window Node OS
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [var.maintenance_window_node_os] : []
    content {
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed != null ? maintenance_window_node_os.value.not_allowed : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  # Microsoft Defender
  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender != null ? [var.microsoft_defender] : []
    content {
      log_analytics_workspace_id = microsoft_defender.value.log_analytics_workspace_id
    }
  }

  # Monitor Metrics
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics != null ? [var.monitor_metrics] : []
    content {
      annotations_allowed = monitor_metrics.value.annotations_allowed
      labels_allowed      = monitor_metrics.value.labels_allowed
    }
  }

  # Service Mesh Profile
  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile != null ? [var.service_mesh_profile] : []
    content {
      mode                             = service_mesh_profile.value.mode
      revisions                        = service_mesh_profile.value.revisions
      internal_ingress_gateway_enabled = service_mesh_profile.value.internal_ingress_gateway_enabled
      external_ingress_gateway_enabled = service_mesh_profile.value.external_ingress_gateway_enabled
    }
  }

  # Workload Autoscaler Profile
  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile != null ? [var.workload_autoscaler_profile] : []
    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }

  # Key Management Service
  dynamic "key_management_service" {
    for_each = var.key_management_service != null ? [var.key_management_service] : []
    content {
      key_vault_key_id         = key_management_service.value.key_vault_key_id
      key_vault_network_access = key_management_service.value.key_vault_network_access
    }
  }

  # Confidential Computing
  dynamic "confidential_computing" {
    for_each = var.confidential_computing != null ? [var.confidential_computing] : []
    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }

  # Web App Routing
  dynamic "web_app_routing" {
    for_each = var.web_app_routing != null ? [var.web_app_routing] : []
    content {
      dns_zone_ids = web_app_routing.value.dns_zone_ids

      dynamic "web_app_routing_identity" {
        for_each = web_app_routing.value.web_app_routing_identity != null ? [web_app_routing.value.web_app_routing_identity] : []
        content {
          client_id                 = web_app_routing_identity.value.client_id
          object_id                 = web_app_routing_identity.value.object_id
          user_assigned_identity_id = web_app_routing_identity.value.user_assigned_identity_id
        }
      }
    }
  }

  # Tags
  tags = var.tags

  # Lifecycle management - all validations moved to variables.tf
  lifecycle {
  }
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "kubernetes_cluster_node_pool" {
  for_each = {
    for node_pool in var.node_pools : node_pool.name => node_pool
  }

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id

  # Required fields
  vm_size = each.value.vm_size

  # Node Count Configuration
  node_count           = each.value.node_count
  auto_scaling_enabled = each.value.auto_scaling_enabled
  min_count            = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count            = each.value.auto_scaling_enabled ? each.value.max_count : null

  # VM Configuration
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  host_encryption_enabled       = each.value.host_encryption_enabled
  node_public_ip_enabled        = each.value.node_public_ip_enabled
  gpu_instance                  = each.value.gpu_instance
  host_group_id                 = each.value.host_group_id

  # OS Configuration
  os_disk_size_gb      = each.value.os_disk_size_gb
  os_disk_type         = each.value.os_disk_type
  os_sku               = each.value.os_sku
  orchestrator_version = each.value.orchestrator_version

  # Network Configuration
  vnet_subnet_id           = each.value.vnet_subnet_id
  pod_subnet_id            = each.value.pod_subnet_id
  node_public_ip_prefix_id = each.value.node_public_ip_prefix_id

  # Advanced Configuration
  eviction_policy              = each.value.eviction_policy
  fips_enabled                 = each.value.fips_enabled
  kubelet_disk_type            = each.value.kubelet_disk_type
  max_pods                     = each.value.max_pods
  mode                         = each.value.mode
  priority                     = each.value.priority
  proximity_placement_group_id = each.value.proximity_placement_group_id
  scale_down_mode              = each.value.scale_down_mode
  snapshot_id                  = each.value.snapshot_id
  spot_max_price               = each.value.spot_max_price
  ultra_ssd_enabled            = each.value.ultra_ssd_enabled
  workload_runtime             = each.value.workload_runtime
  zones                        = each.value.zones

  # Node Labels and Taints
  node_labels = each.value.node_labels
  node_taints = each.value.node_taints

  # Kubelet Configuration
  dynamic "kubelet_config" {
    for_each = each.value.kubelet_config != null ? [each.value.kubelet_config] : []
    content {
      allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
      container_log_max_line    = kubelet_config.value.container_log_max_line
      container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
      cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
      cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
      image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
      image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
      pod_max_pid               = kubelet_config.value.pod_max_pid
      topology_manager_policy   = kubelet_config.value.topology_manager_policy
    }
  }

  # Linux OS Configuration
  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config != null ? [each.value.linux_os_config] : []
    content {
      swap_file_size_mb            = linux_os_config.value.swap_file_size_mb
      transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
      transparent_huge_page        = linux_os_config.value.transparent_huge_page

      dynamic "sysctl_config" {
        for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
        content {
          fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
          fs_file_max                        = sysctl_config.value.fs_file_max
          fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
          fs_nr_open                         = sysctl_config.value.fs_nr_open
          kernel_threads_max                 = sysctl_config.value.kernel_threads_max
          net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
          net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
          net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
          net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
          net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
          net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
          net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
          net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
          net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
          net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
          net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
          net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
          net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
          net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
          net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
          net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
          net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
          net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
          net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
          net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
          net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
          vm_max_map_count                   = sysctl_config.value.vm_max_map_count
          vm_swappiness                      = sysctl_config.value.vm_swappiness
          vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
        }
      }
    }
  }

  # Node Network Profile
  dynamic "node_network_profile" {
    for_each = each.value.node_network_profile != null ? [each.value.node_network_profile] : []
    content {
      application_security_group_ids = node_network_profile.value.application_security_group_ids
      node_public_ip_tags            = node_network_profile.value.node_public_ip_tags

      dynamic "allowed_host_ports" {
        for_each = node_network_profile.value.allowed_host_ports != null ? node_network_profile.value.allowed_host_ports : []
        content {
          port_start = allowed_host_ports.value.port_start
          port_end   = allowed_host_ports.value.port_end
          protocol   = allowed_host_ports.value.protocol
        }
      }
    }
  }

  # Windows Profile
  dynamic "windows_profile" {
    for_each = each.value.windows_profile != null ? [each.value.windows_profile] : []
    content {
      outbound_nat_enabled = windows_profile.value.outbound_nat_enabled
    }
  }

  # Upgrade Settings
  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? [each.value.upgrade_settings] : []
    content {
      drain_timeout_in_minutes      = upgrade_settings.value.drain_timeout_in_minutes
      max_surge                     = upgrade_settings.value.max_surge
      node_soak_duration_in_minutes = upgrade_settings.value.node_soak_duration_in_minutes
    }
  }

  # Tags
  tags = merge(var.tags, each.value.tags)

  # Ensure the cluster is created before node pools
  depends_on = [azurerm_kubernetes_cluster.kubernetes_cluster]
}

# Cluster Extensions
resource "azurerm_kubernetes_cluster_extension" "kubernetes_cluster_extension" {
  for_each = {
    for extension in var.extensions : extension.name => extension
  }

  name           = each.value.name
  cluster_id     = azurerm_kubernetes_cluster.kubernetes_cluster.id
  extension_type = each.value.extension_type

  # Optional fields
  release_train          = each.value.release_train
  release_namespace      = each.value.release_namespace
  target_namespace       = each.value.target_namespace
  version                = each.value.version
  configuration_settings = each.value.configuration_settings

  dynamic "plan" {
    for_each = each.value.plan != null ? [each.value.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
      version   = plan.value.version
    }
  }

  depends_on = [azurerm_kubernetes_cluster.kubernetes_cluster]
}

