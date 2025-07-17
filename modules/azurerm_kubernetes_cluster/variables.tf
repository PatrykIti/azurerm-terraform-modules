# Core Kubernetes Cluster Variables
variable "name" {
  description = "The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "The name must be between 1 and 63 characters long, start and end with a letter or number, and contain only letters, numbers, hyphens, underscores, and periods."
  }
}

variable "resource_group_name" {
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created."
  type        = string
}

# DNS Configuration
variable "dns_config" {
  description = <<-EOT
    DNS configuration for the Kubernetes cluster.
    
    dns_prefix: DNS prefix specified when creating the managed cluster. Required for public clusters.
    dns_prefix_private_cluster: DNS prefix to use with private clusters. Required for private clusters.
    
    Note: You must define either dns_prefix or dns_prefix_private_cluster, but not both.
  EOT

  type = object({
    dns_prefix                 = optional(string)
    dns_prefix_private_cluster = optional(string)
  })

  default = {}

  validation {
    condition = (
      (var.dns_config.dns_prefix != null && var.dns_config.dns_prefix_private_cluster == null) ||
      (var.dns_config.dns_prefix == null && var.dns_config.dns_prefix_private_cluster != null)
    )
    error_message = "You must define either dns_prefix or dns_prefix_private_cluster, but not both."
  }

  validation {
    condition = var.dns_config.dns_prefix == null || (
      try(length(var.dns_config.dns_prefix), 0) >= 1 && try(length(var.dns_config.dns_prefix), 0) <= 54 &&
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", try(var.dns_config.dns_prefix, "")))
    )
    error_message = "DNS prefix must begin and end with a letter or number, contain only letters, numbers, and hyphens and be between 1 and 54 characters in length."
  }
}

# Kubernetes Version and Upgrade Configuration
variable "kubernetes_config" {
  description = <<-EOT
    Kubernetes version and upgrade configuration.
    
    kubernetes_version: Version of Kubernetes specified when creating the AKS managed cluster.
    automatic_upgrade_channel: The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image, stable, or none.
    node_os_upgrade_channel: The upgrade channel for node OS security updates. Possible values are Unmanaged, SecurityPatch, NodeImage, or None.
  EOT

  type = object({
    kubernetes_version        = optional(string)
    automatic_upgrade_channel = optional(string)
    node_os_upgrade_channel   = optional(string, "NodeImage")
  })

  default = {
    node_os_upgrade_channel = "NodeImage"
  }

  validation {
    condition = alltrue([
      var.kubernetes_config.automatic_upgrade_channel == null ? true : contains(["patch", "rapid", "node-image", "stable", "none"], var.kubernetes_config.automatic_upgrade_channel)
    ])
    error_message = "The automatic_upgrade_channel must be one of: patch, rapid, node-image, stable, or none."
  }

  validation {
    condition     = contains(["Unmanaged", "SecurityPatch", "NodeImage", "None"], var.kubernetes_config.node_os_upgrade_channel)
    error_message = "The node_os_upgrade_channel must be one of: Unmanaged, SecurityPatch, NodeImage, or None."
  }
}

# SKU Configuration
variable "sku_config" {
  description = <<-EOT
    SKU configuration for the Kubernetes cluster.
    
    sku_tier: The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium.
    support_plan: Specifies the support plan which should be used for this Kubernetes Cluster. Possible values are KubernetesOfficial and AKSLongTermSupport.
  EOT

  type = object({
    sku_tier     = optional(string, "Free")
    support_plan = optional(string, "KubernetesOfficial")
  })

  default = {
    sku_tier     = "Free"
    support_plan = "KubernetesOfficial"
  }

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_config.sku_tier)
    error_message = "The sku_tier must be one of: Free, Standard, or Premium."
  }

  validation {
    condition     = contains(["KubernetesOfficial", "AKSLongTermSupport"], var.sku_config.support_plan)
    error_message = "The support_plan must be either KubernetesOfficial or AKSLongTermSupport."
  }
}

# Default Node Pool Configuration
variable "default_node_pool" {
  description = <<-EOT
    Configuration for the default node pool.
    
    Required fields:
    - name: The name which should be used for the default Kubernetes Node Pool.
    - vm_size: The size of the Virtual Machine, such as Standard_DS2_v2.
    
    Optional fields include node count, availability zones, max pods, OS disk configuration, and more.
  EOT

  type = object({
    name                          = string
    vm_size                       = string
    capacity_reservation_group_id = optional(string)
    auto_scaling_enabled          = optional(bool, false)
    host_encryption_enabled       = optional(bool, false)
    node_public_ip_enabled        = optional(bool, false)
    gpu_instance                  = optional(string)
    host_group_id                 = optional(string)

    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }))

    linux_os_config = optional(object({
      swap_file_size_mb = optional(number)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
      transparent_huge_page_defrag = optional(string)
      transparent_huge_page        = optional(string)
    }))

    fips_enabled      = optional(bool, false)
    kubelet_disk_type = optional(string)
    max_pods          = optional(number)
    node_network_profile = optional(object({
      allowed_host_ports = optional(list(object({
        port_start = optional(number)
        port_end   = optional(number)
        protocol   = optional(string)
      })))
      application_security_group_ids = optional(list(string))
      node_public_ip_tags            = optional(map(string))
    }))

    node_labels                  = optional(map(string))
    node_public_ip_prefix_id     = optional(string)
    only_critical_addons_enabled = optional(bool, false)
    orchestrator_version         = optional(string)
    os_disk_size_gb              = optional(number)
    os_disk_type                 = optional(string, "Managed")
    os_sku                       = optional(string, "Ubuntu")
    pod_subnet_id                = optional(string)
    proximity_placement_group_id = optional(string)
    scale_down_mode              = optional(string, "Delete")

    snapshot_id = optional(string)

    temporary_name_for_rotation = optional(string)
    type                        = optional(string, "VirtualMachineScaleSets")

    ultra_ssd_enabled = optional(bool, false)

    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      max_surge                     = string
    }))

    vnet_subnet_id   = optional(string)
    workload_runtime = optional(string)
    zones            = optional(list(string))

    max_count  = optional(number)
    min_count  = optional(number)
    node_count = optional(number, 1)
  })

  validation {
    condition     = var.default_node_pool.os_sku == null || contains(["Ubuntu", "AzureLinux", "CBLMariner", "Mariner", "Windows2019", "Windows2022"], var.default_node_pool.os_sku)
    error_message = "The os_sku must be one of: Ubuntu, AzureLinux, CBLMariner, Mariner, Windows2019, Windows2022."
  }

  validation {
    condition = alltrue([
      var.default_node_pool.workload_runtime == null ? true : contains(["OCIContainer", "WasmWasi", "KataMshvVmIsolation"], var.default_node_pool.workload_runtime)
    ])
    error_message = "The workload_runtime must be one of: OCIContainer, WasmWasi, KataMshvVmIsolation."
  }

  validation {
    condition     = var.default_node_pool.scale_down_mode == null || contains(["Delete", "Deallocate"], var.default_node_pool.scale_down_mode)
    error_message = "The scale_down_mode must be either Delete or Deallocate."
  }

  validation {
    condition     = !var.default_node_pool.auto_scaling_enabled || (var.default_node_pool.min_count != null && var.default_node_pool.max_count != null)
    error_message = "When auto_scaling_enabled is true, both min_count and max_count must be specified."
  }
}

# Identity Configuration
variable "identity" {
  description = <<-EOT
    An identity block. One of either identity or service_principal must be specified.
    
    type: Specifies the type of Managed Service Identity. Possible values are SystemAssigned or UserAssigned.
    identity_ids: Specifies a list of User Assigned Managed Identity IDs.
  EOT

  type = object({
    type         = string
    identity_ids = optional(list(string))
  })

  default = {
    type = "SystemAssigned"
  }

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.identity.type)
    error_message = "The identity type must be either SystemAssigned or UserAssigned."
  }

  validation {
    condition     = var.identity == null || var.identity.type != "UserAssigned" || (var.identity.identity_ids != null && length(coalesce(var.identity.identity_ids, [])) > 0)
    error_message = "When identity type is UserAssigned, identity_ids must be provided."
  }
}

# Service Principal Configuration (Alternative to Identity)
variable "service_principal" {
  description = <<-EOT
    A service_principal block. One of either identity or service_principal must be specified.
    Note: A migration scenario from service_principal to identity is supported.
  EOT

  type = object({
    client_id     = string
    client_secret = string
  })

  default   = null
  sensitive = true
}

# Network Configuration
variable "network_profile" {
  description = <<-EOT
    Network profile configuration for the cluster.
    
    network_plugin: Network plugin to use. Possible values are azure, kubenet and none.
    network_mode: Network mode to be used. Possible values are bridge and transparent.
    network_policy: Network policy to be used. Possible values are calico, azure and cilium.
    dns_service_ip: IP address within the Kubernetes service address range for cluster DNS service.
    service_cidr: The Network Range used by the Kubernetes service. Changing this forces a new resource.
    load_balancer_sku: Specifies the SKU of the Load Balancer used for this Kubernetes Cluster.
  EOT

  type = object({
    network_plugin      = string
    network_mode        = optional(string)
    network_policy      = optional(string)
    dns_service_ip      = optional(string)
    network_plugin_mode = optional(string)
    outbound_type       = optional(string, "loadBalancer")
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    ip_versions         = optional(list(string))
    load_balancer_sku   = optional(string, "standard")

    load_balancer_profile = optional(object({
      backend_pool_type           = optional(string, "NodeIPConfiguration")
      effective_outbound_ips      = optional(list(string))
      idle_timeout_in_minutes     = optional(number, 30)
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(list(string))
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ports_allocated    = optional(number, 0)
    }))

    nat_gateway_profile = optional(object({
      effective_outbound_ips    = optional(list(string))
      idle_timeout_in_minutes   = optional(number, 4)
      managed_outbound_ip_count = optional(number)
    }))
  })

  default = {
    network_plugin = "azure"
  }

  validation {
    condition     = contains(["azure", "kubenet", "none"], var.network_profile.network_plugin)
    error_message = "The network_plugin must be one of: azure, kubenet, or none."
  }

  validation {
    condition     = var.network_profile == null || try(var.network_profile.network_mode, null) == null || try(contains(["bridge", "transparent"], var.network_profile.network_mode), true)
    error_message = "The network_mode must be either bridge or transparent."
  }

  validation {
    condition     = var.network_profile.network_policy == null || contains(["calico", "azure", "cilium"], var.network_profile.network_policy)
    error_message = "The network_policy must be one of: calico, azure, or cilium."
  }

  validation {
    condition     = var.network_profile.outbound_type == null || contains(["loadBalancer", "userDefinedRouting", "managedNATGateway", "userAssignedNATGateway"], var.network_profile.outbound_type)
    error_message = "The outbound_type must be one of: loadBalancer, userDefinedRouting, managedNATGateway, or userAssignedNATGateway."
  }
}

# API Server Access Configuration
variable "api_server_access_profile" {
  description = <<-EOT
    API server access profile configuration.
    
    authorized_ip_ranges: Set of authorized IP ranges to allow access to API server.
  EOT

  type = object({
    authorized_ip_ranges = optional(list(string))
  })

  default = null
}

# Private Cluster Configuration
variable "private_cluster_config" {
  description = <<-EOT
    Private cluster configuration.
    
    private_cluster_enabled: Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?
    private_dns_zone_id: Either the ID of Private DNS Zone which should be delegated to this Cluster, System to have AKS manage this or None.
    private_cluster_public_fqdn_enabled: Specifies whether a Public FQDN for this Private Cluster should be added.
  EOT

  type = object({
    private_cluster_enabled             = optional(bool, false)
    private_dns_zone_id                 = optional(string)
    private_cluster_public_fqdn_enabled = optional(bool, false)
  })

  default = {
    private_cluster_enabled             = false
    private_cluster_public_fqdn_enabled = false
  }
}

# Feature Flags
variable "features" {
  description = <<-EOT
    Feature flags for enabling/disabling various Kubernetes cluster features.
    
    azure_policy_enabled: Should the Azure Policy Add-On be enabled?
    http_application_routing_enabled: Should HTTP Application Routing be enabled?
    workload_identity_enabled: Specifies whether Azure AD Workload Identity should be enabled for the Cluster.
    oidc_issuer_enabled: Enable or Disable the OIDC issuer URL.
    open_service_mesh_enabled: Is Open Service Mesh enabled?
    image_cleaner_enabled: Specifies whether Image Cleaner is enabled.
    run_command_enabled: Whether to enable run command for the cluster or not.
    local_account_disabled: If true local accounts will be disabled.
    cost_analysis_enabled: Should cost analysis be enabled for this Kubernetes Cluster?
  EOT

  type = object({
    azure_policy_enabled             = optional(bool, false)
    http_application_routing_enabled = optional(bool, false)
    workload_identity_enabled        = optional(bool, false)
    oidc_issuer_enabled              = optional(bool, false)
    open_service_mesh_enabled        = optional(bool, false)
    image_cleaner_enabled            = optional(bool, false)
    run_command_enabled              = optional(bool, true)
    local_account_disabled           = optional(bool, false)
    cost_analysis_enabled            = optional(bool, false)
  })

  default = {
    azure_policy_enabled             = false
    http_application_routing_enabled = false
    workload_identity_enabled        = false
    oidc_issuer_enabled              = false
    open_service_mesh_enabled        = false
    image_cleaner_enabled            = false
    run_command_enabled              = true
    local_account_disabled           = false
    cost_analysis_enabled            = false
  }
}

# Azure Active Directory RBAC
variable "azure_active_directory_role_based_access_control" {
  description = <<-EOT
    Azure Active Directory Role Based Access Control configuration.
    
    tenant_id: The Tenant ID used for Azure Active Directory Application.
    admin_group_object_ids: A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.
    azure_rbac_enabled: Is Role Based Access Control based on Azure AD enabled?
  EOT

  type = object({
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool, true)
  })

  default = null
}

# Add-ons Configuration

variable "oms_agent" {
  description = <<-EOT
    OMS Agent configuration for Azure Monitor.
    
    log_analytics_workspace_id: The ID of the Log Analytics Workspace which the OMS Agent should send data to.
    msi_auth_for_monitoring_enabled: Is managed identity authentication for monitoring enabled?
  EOT

  type = object({
    log_analytics_workspace_id      = string
    msi_auth_for_monitoring_enabled = optional(bool, true)
  })

  default = null
}

variable "ingress_application_gateway" {
  description = <<-EOT
    Application Gateway Ingress Controller add-on configuration.
    
    gateway_id: The ID of the Application Gateway to integrate with.
    gateway_name: The name of the Application Gateway to be used or created.
    subnet_cidr: The subnet CIDR to be used to create an Application Gateway.
    subnet_id: The ID of the subnet on which to create an Application Gateway.
  EOT

  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })

  default = null
}

variable "aci_connector_linux" {
  description = <<-EOT
    ACI Connector Linux configuration.
    
    subnet_name: The subnet name for the virtual nodes to run.
  EOT

  type = object({
    subnet_name = string
  })

  default = null
}

variable "key_vault_secrets_provider" {
  description = <<-EOT
    Azure Key Vault Secrets Provider configuration.
    
    secret_rotation_enabled: Is secret rotation enabled?
    secret_rotation_interval: The interval to poll for secret rotation.
  EOT

  type = object({
    secret_rotation_enabled  = optional(bool, true)
    secret_rotation_interval = optional(string, "2m")
  })

  default = null
}

# Auto Scaler Profile
variable "auto_scaler_profile" {
  description = "Auto Scaler Profile configuration."

  type = object({
    balance_similar_node_groups                   = optional(bool)
    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)
    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)
    empty_bulk_delete_max                         = optional(string)
    expander                                      = optional(string)
    ignore_daemonsets_utilization_enabled         = optional(bool)
    max_graceful_termination_sec                  = optional(string)
    max_node_provisioning_time                    = optional(string)
    max_unready_nodes                             = optional(number)
    max_unready_percentage                        = optional(number)
    new_pod_scale_up_delay                        = optional(string)
    scale_down_delay_after_add                    = optional(string)
    scale_down_delay_after_delete                 = optional(string)
    scale_down_delay_after_failure                = optional(string)
    scale_down_unneeded                           = optional(string)
    scale_down_unready                            = optional(string)
    scale_down_utilization_threshold              = optional(string)
    scan_interval                                 = optional(string)
    skip_nodes_with_local_storage                 = optional(bool)
    skip_nodes_with_system_pods                   = optional(bool)
  })

  default = null
}

# Maintenance Windows
variable "maintenance_window" {
  description = <<-EOT
    Maintenance window configuration.
    
    allowed: List of allowed maintenance windows.
    not_allowed: List of not allowed maintenance windows.
  EOT

  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })))
    not_allowed = optional(list(object({
      end   = string
      start = string
    })))
  })

  default = null
}

variable "maintenance_window_auto_upgrade" {
  description = "Maintenance window configuration for auto upgrade."

  type = object({
    duration     = number
    frequency    = string
    interval     = number
    day_of_month = optional(number)
    day_of_week  = optional(string)
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(list(object({
      end   = string
      start = string
    })))
  })

  default = null
}

variable "maintenance_window_node_os" {
  description = "Maintenance window configuration for node OS updates."

  type = object({
    duration     = number
    frequency    = string
    interval     = number
    day_of_month = optional(number)
    day_of_week  = optional(string)
    start_date   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    week_index   = optional(string)
    not_allowed = optional(list(object({
      end   = string
      start = string
    })))
  })

  default = null
}

# Security Configuration
variable "microsoft_defender" {
  description = <<-EOT
    Microsoft Defender configuration.
    
    log_analytics_workspace_id: Specifies the ID of the Log Analytics Workspace where the audit logs should be sent.
  EOT

  type = object({
    log_analytics_workspace_id = string
  })

  default = null
}


# Monitoring
variable "monitor_metrics" {
  description = <<-EOT
    Monitor metrics configuration.
    
    annotations_allowed: Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric.
    labels_allowed: Specifies a comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric.
  EOT

  type = object({
    annotations_allowed = optional(string)
    labels_allowed      = optional(string)
  })

  default = null
}

# Service Mesh
variable "service_mesh_profile" {
  description = <<-EOT
    Service mesh profile configuration.
    
    mode: The mode of the service mesh. Possible value is Istio.
    revisions: Specify 1 or 2 Istio control plane revisions for managing minor upgrades.
    internal_ingress_gateway_enabled: Is Istio Internal Ingress Gateway enabled?
    external_ingress_gateway_enabled: Is Istio External Ingress Gateway enabled?
  EOT

  type = object({
    mode                             = string
    revisions                        = list(string)
    internal_ingress_gateway_enabled = optional(bool)
    external_ingress_gateway_enabled = optional(bool)
  })

  default = null

  validation {
    condition     = var.service_mesh_profile == null || try(var.service_mesh_profile.mode, null) == "Istio"
    error_message = "The service mesh mode must be Istio."
  }

  validation {
    condition     = var.service_mesh_profile == null || (try(length(var.service_mesh_profile.revisions), 0) >= 1 && try(length(var.service_mesh_profile.revisions), 0) <= 2)
    error_message = "Service mesh revisions must contain 1 or 2 items."
  }
}

# Workload Autoscaler Profile
variable "workload_autoscaler_profile" {
  description = <<-EOT
    Workload autoscaler profile configuration.
    
    keda_enabled: Specifies whether KEDA Autoscaler can be used for workloads.
    vertical_pod_autoscaler_enabled: Specifies whether Vertical Pod Autoscaler should be enabled.
  EOT

  type = object({
    keda_enabled                    = optional(bool)
    vertical_pod_autoscaler_enabled = optional(bool)
  })

  default = null
}

# Other Features
variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Extended Zone (formerly called Edge Zone) within the Azure Region where this Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "http_proxy_config" {
  description = <<-EOT
    HTTP proxy configuration.
    
    http_proxy: Proxy server endpoint to use for creating HTTP connections.
    https_proxy: Proxy server endpoint to use for creating HTTPS connections.
    no_proxy: Endpoints that should not go through proxy.
    trusted_ca: Alternative CA bundle base64 string.
  EOT

  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })

  default   = null
  sensitive = true
}


variable "image_cleaner_interval_hours" {
  description = "Specifies the interval in hours when images should be cleaned up. Valid values are between 24 and 2160 (90 days). Defaults to 48."
  type        = number
  default     = 48
}


variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist. Azure requires that a new, non-existent Resource Group is used. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "key_management_service" {
  description = <<-EOT
    Key Management Service configuration.
    
    key_vault_key_id: Identifier of Azure Key Vault key.
    key_vault_network_access: Network access of the key vault. Possible values are Public and Private.
  EOT

  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string, "Public")
  })

  default = null

  validation {
    condition     = var.key_management_service == null || contains(["Public", "Private"], try(var.key_management_service.key_vault_network_access, "Public"))
    error_message = "The key_vault_network_access must be either Public or Private."
  }
}

variable "kubelet_identity" {
  description = <<-EOT
    Kubelet identity configuration.
    
    client_id: The Client ID of the user-defined Managed Identity to be assigned to the Kubelets.
    object_id: The Object ID of the user-defined Managed Identity assigned to the Kubelets.
    user_assigned_identity_id: The ID of the User Assigned Identity assigned to the Kubelets.
  EOT

  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })

  default = null
}

variable "linux_profile" {
  description = <<-EOT
    Linux profile configuration.
    
    admin_username: The Admin Username for the Cluster.
    ssh_key: An ssh_key block with key_data containing the SSH public key.
  EOT

  type = object({
    admin_username = string
    ssh_key = object({
      key_data = string
    })
  })

  default = null
}

variable "windows_profile" {
  description = <<-EOT
    Windows profile configuration.
    
    admin_username: The Admin Username for Windows VMs.
    admin_password: The Admin Password for Windows VMs.
    license: Specifies the type of on-premise license which should be used for Node Pool Windows VM's.
    gmsa: GMSA configuration for Windows node pools.
  EOT

  type = object({
    admin_username = string
    admin_password = optional(string)
    license        = optional(string)
    gmsa = optional(object({
      root_domain = string
      dns_server  = optional(string)
    }))
  })

  default   = null
  sensitive = true
}

variable "web_app_routing" {
  description = <<-EOT
    Web App Routing configuration.
    
    dns_zone_ids: Specifies the list of the DNS Zone IDs in which DNS entries are created for applications deployed to the cluster.
    web_app_routing_identity: A web_app_routing_identity block.
  EOT

  type = object({
    dns_zone_ids = list(string)
    web_app_routing_identity = optional(object({
      client_id                 = string
      object_id                 = string
      user_assigned_identity_id = string
    }))
  })

  default = null
}



variable "confidential_computing" {
  description = <<-EOT
    Confidential computing configuration.
    
    sgx_quote_helper_enabled: Should the SGX quote helper be enabled?
  EOT

  type = object({
    sgx_quote_helper_enabled = bool
  })

  default = null
}


# Storage Profile
variable "storage_profile" {
  description = <<-EOT
    Storage profile configuration.
    
    blob_driver_enabled: Is the Blob CSI driver enabled?
    disk_driver_enabled: Is the Disk CSI driver enabled?
    disk_driver_version: Disk CSI Driver version to be used.
    file_driver_enabled: Is the File CSI driver enabled?
    snapshot_controller_enabled: Is the Snapshot Controller enabled?
  EOT

  type = object({
    blob_driver_enabled         = optional(bool, false)
    disk_driver_enabled         = optional(bool, true)
    file_driver_enabled         = optional(bool, true)
    snapshot_controller_enabled = optional(bool, true)
  })

  default = {}
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# Additional Node Pools
variable "node_pools" {
  description = <<-EOT
    List of additional node pools to create.
    
    Each node pool supports the same configuration options as the default node pool,
    plus additional options for spot instances and taints.
  EOT

  type = list(object({
    # Required
    name    = string
    vm_size = string

    # Node Count Configuration
    node_count           = optional(number, 1)
    auto_scaling_enabled = optional(bool, false)
    min_count            = optional(number)
    max_count            = optional(number)

    # VM Configuration
    capacity_reservation_group_id = optional(string)
    host_encryption_enabled       = optional(bool, false)
    node_public_ip_enabled        = optional(bool, false)
    gpu_instance                  = optional(string)
    host_group_id                 = optional(string)

    # OS Configuration
    os_disk_size_gb      = optional(number)
    os_disk_type         = optional(string, "Managed")
    os_sku               = optional(string, "Ubuntu")
    orchestrator_version = optional(string)

    # Network Configuration
    vnet_subnet_id           = optional(string)
    pod_subnet_id            = optional(string)
    node_public_ip_prefix_id = optional(string)

    # Advanced Configuration
    eviction_policy              = optional(string)
    fips_enabled                 = optional(bool, false)
    kubelet_disk_type            = optional(string)
    max_pods                     = optional(number)
    mode                         = optional(string, "User")
    priority                     = optional(string, "Regular")
    proximity_placement_group_id = optional(string)
    scale_down_mode              = optional(string, "Delete")
    snapshot_id                  = optional(string)
    spot_max_price               = optional(number, -1)
    ultra_ssd_enabled            = optional(bool, false)
    workload_runtime             = optional(string)
    zones                        = optional(list(string))

    # Node Labels and Taints
    node_labels = optional(map(string))
    node_taints = optional(list(string))

    # Kubelet Configuration
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }))

    # Linux OS Configuration
    linux_os_config = optional(object({
      swap_file_size_mb            = optional(number)
      transparent_huge_page_defrag = optional(string)
      transparent_huge_page        = optional(string)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
    }))

    # Node Network Profile
    node_network_profile = optional(object({
      application_security_group_ids = optional(list(string))
      node_public_ip_tags            = optional(map(string))
      allowed_host_ports = optional(list(object({
        port_start = optional(number)
        port_end   = optional(number)
        protocol   = optional(string)
      })))
    }))

    # Windows Profile
    windows_profile = optional(object({
      outbound_nat_enabled = optional(bool, true)
    }))

    # Upgrade Settings
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number)
      max_surge                     = string
      node_soak_duration_in_minutes = optional(number)
    }))

    # Tags
    tags = optional(map(string), {})
  }))

  default = []
}

# Cluster Extensions
variable "extensions" {
  description = <<-EOT
    List of cluster extensions to install.
    
    Common extension types:
    - microsoft.azuremonitor.containers (Azure Monitor)
    - microsoft.azure-policy (Azure Policy)
    - microsoft.azuredefender.kubernetes (Azure Defender)
    - microsoft.openservicemesh (Open Service Mesh)
    - microsoft.flux (GitOps Flux v2)
  EOT

  type = list(object({
    name                   = string
    extension_type         = string
    release_train          = optional(string)
    release_namespace      = optional(string)
    target_namespace       = optional(string)
    version                = optional(string)
    configuration_settings = optional(map(string))

    plan = optional(object({
      name      = string
      product   = string
      publisher = string
      version   = optional(string)
    }))
  }))

  default = []
}

# Private Endpoints Configuration
variable "private_endpoints" {
  description = <<-EOT
    List of private endpoints to create for the AKS cluster.
    
    Private endpoints allow secure access to the AKS API server from other VNets.
    Requires private_cluster_enabled = true.
  EOT

  type = list(object({
    name      = string
    subnet_id = string
    private_dns_zone_group = optional(object({
      name                 = string
      private_dns_zone_ids = list(string)
    }))
    tags = optional(map(string), {})
  }))

  default = []
}

# Diagnostic Settings
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the AKS cluster.
    
    Specify destinations for logs and metrics:
    - Log Analytics workspace
    - Storage account
    - Event Hub
    - Partner solutions
  EOT

  type = object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    partner_solution_id            = optional(string)

    enabled_log_categories = optional(list(string), [
      "kube-apiserver",
      "kube-audit",
      "kube-audit-admin",
      "kube-controller-manager",
      "kube-scheduler",
      "cluster-autoscaler",
      "cloud-controller-manager",
      "guard",
      "csi-azuredisk-controller",
      "csi-azurefile-controller",
      "csi-snapshot-controller"
    ])

    metrics = optional(list(object({
      category = string
      enabled  = optional(bool, true)
      })), [
      {
        category = "AllMetrics"
        enabled  = true
      }
    ])
  })

  default = null
}