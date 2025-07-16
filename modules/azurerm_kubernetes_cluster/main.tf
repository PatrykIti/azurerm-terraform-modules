# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # DNS Configuration - One of dns_prefix or dns_prefix_private_cluster is required
  dns_prefix                  = var.dns_prefix
  dns_prefix_private_cluster  = var.dns_prefix_private_cluster

  # Kubernetes Version and Upgrade Configuration
  kubernetes_version          = var.kubernetes_version
  automatic_upgrade_channel   = var.automatic_upgrade_channel
  node_os_upgrade_channel     = var.node_os_upgrade_channel

  # SKU Configuration
  sku_tier     = var.sku_tier
  support_plan = var.support_plan

  # Node Resource Group
  node_resource_group = var.node_resource_group

  # Private Cluster Configuration
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  # Feature Flags
  azure_policy_enabled              = var.azure_policy_enabled
  http_application_routing_enabled  = var.http_application_routing_enabled
  workload_identity_enabled         = var.workload_identity_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  open_service_mesh_enabled        = var.open_service_mesh_enabled
  image_cleaner_enabled            = var.image_cleaner_enabled
  run_command_enabled              = var.run_command_enabled
  local_account_disabled           = var.local_account_disabled
  cost_analysis_enabled            = var.cost_analysis_enabled

  # Image Cleaner Configuration
  image_cleaner_interval_hours = var.image_cleaner_enabled ? var.image_cleaner_interval_hours : 0

  # Encryption Configuration
  disk_encryption_set_id = var.disk_encryption_set_id

  # Edge Zone
  edge_zone = var.edge_zone

  # Default Node Pool - Required
  default_node_pool {
    name                          = var.default_node_pool.name
    vm_size                       = var.default_node_pool.vm_size
    
    # Node Count Configuration
    node_count                    = var.default_node_pool.node_count
    auto_scaling_enabled          = var.default_node_pool.auto_scaling_enabled
    min_count                     = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.min_count : null
    max_count                     = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.max_count : null
    
    # VM Configuration
    capacity_reservation_group_id = var.default_node_pool.capacity_reservation_group_id
    host_encryption_enabled       = var.default_node_pool.host_encryption_enabled
    node_public_ip_enabled        = var.default_node_pool.node_public_ip_enabled
    gpu_instance                  = var.default_node_pool.gpu_instance
    host_group_id                = var.default_node_pool.host_group_id
    
    # OS Configuration
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    os_sku                       = var.default_node_pool.os_sku
    orchestrator_version         = var.default_node_pool.orchestrator_version
    
    # Network Configuration
    vnet_subnet_id               = var.default_node_pool.vnet_subnet_id
    pod_subnet_id                = var.default_node_pool.pod_subnet_id
    node_public_ip_prefix_id     = var.default_node_pool.node_public_ip_prefix_id
    
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
    node_labels                  = var.default_node_pool.node_labels
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

  # Tags
  tags = var.tags

  # Lifecycle management
  lifecycle {
    precondition {
      condition = (
        (var.dns_prefix != null && var.dns_prefix_private_cluster == null) ||
        (var.dns_prefix == null && var.dns_prefix_private_cluster != null)
      )
      error_message = "You must define either dns_prefix or dns_prefix_private_cluster, but not both."
    }

    precondition {
      condition = (
        (var.identity != null && var.service_principal == null) ||
        (var.identity == null && var.service_principal != null)
      )
      error_message = "You must define either identity or service_principal, but not both."
    }

    precondition {
      condition = var.cost_analysis_enabled == false || contains(["Standard", "Premium"], var.sku_tier)
      error_message = "Cost analysis can only be enabled when sku_tier is set to Standard or Premium."
    }

    precondition {
      condition = var.private_cluster_enabled == false || var.dns_prefix_private_cluster != null
      error_message = "When private_cluster_enabled is true, dns_prefix_private_cluster must be specified."
    }
  }
}