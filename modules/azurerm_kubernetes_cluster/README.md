# Terraform Azure Kubernetes Cluster Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **2.1.0**
<!-- END_VERSION -->

## Description

This module creates a comprehensive Azure Kubernetes Service (AKS) cluster with support for enterprise features including multiple node pools, advanced networking, security configurations, monitoring integration, and various add-ons. It provides secure defaults while allowing full customization for production workloads.

## Features

- ✅ **Multiple Node Pools** - System and user pools with different configurations
- ✅ **Advanced Networking** - Azure CNI, Kubenet, custom VNet integration
- ✅ **Security** - Azure AD RBAC, Workload Identity, OIDC, private clusters
- ✅ **Monitoring** - Azure Monitor, Log Analytics, Prometheus metrics
- ✅ **Add-ons** - Azure Policy, Key Vault Secrets Provider, Application Gateway Ingress
- ✅ **Auto-scaling** - Cluster autoscaler, KEDA, Vertical Pod Autoscaler
- ✅ **High Availability** - Multi-zone deployments, SLA configurations
- ✅ **Cost Optimization** - Spot instances, node pool scaling, maintenance windows

## Prerequisites

- Azure subscription with appropriate permissions
- Resource Group where the cluster will be deployed
- Virtual Network and Subnet (if using custom networking)
- Azure AD configuration (if using Azure AD RBAC)
- Log Analytics Workspace (optional, for monitoring)

## Usage

### Basic Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "path/to/azurerm_kubernetes_cluster"

  # Core configuration
  name                = "aks-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration
  dns_config = {
    dns_prefix = "aks-example"
  }

  # Identity configuration (secure default)
  identity = {
    type = "SystemAssigned"
  }

  # Default node pool
  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v3"
    node_count     = 2
    vnet_subnet_id = azurerm_subnet.example.id
  }

  # Network configuration
  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### Advanced Usage with Multiple Node Pools

```hcl
module "kubernetes_cluster" {
  source = "path/to/azurerm_kubernetes_cluster"

  # ... basic configuration ...

  # Additional node pools
  node_pools = [
    {
      name           = "userpool"
      vm_size        = "Standard_D4s_v3"
      node_count     = 3
      mode           = "User"
      vnet_subnet_id = azurerm_subnet.example.id
      node_labels = {
        workload = "applications"
      }
    },
    {
      name                = "spotpool"
      vm_size             = "Standard_D2s_v3"
      priority            = "Spot"
      eviction_policy     = "Delete"
      spot_max_price      = -1
      auto_scaling_enabled = true
      min_count           = 1
      max_count           = 5
      vnet_subnet_id      = azurerm_subnet.example.id
    }
  ]
}
```

### Diagnostic Settings (Control Plane)

```hcl
module "kubernetes_cluster" {
  source = "path/to/azurerm_kubernetes_cluster"

  # ... basic configuration ...

  monitoring = [
    {
      name                       = "aks-api-logs"
      log_categories             = ["kube-apiserver", "kube-audit"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    },
    {
      name                           = "aks-metrics-stream"
      metric_categories              = ["AllMetrics"]
      eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.example.id
      eventhub_name                  = azurerm_eventhub.example.name
    }
  ]
}
```

Notes:
- Azure allows a maximum of 5 diagnostic settings per AKS resource.
- Entries with no log or metric categories are skipped and reported in `diagnostic_settings_skipped`.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure Kubernetes Service (AKS) cluster configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive Azure Kubernetes Service (AKS) cluster configuration showcasing advanced features and production-ready settings.
- [Diagnostic Settings](examples/diagnostic-settings) - This example demonstrates configuring AKS control plane diagnostic settings with a Log Analytics workspace.
- [Multi Node Pool](examples/multi-node-pool) - This example demonstrates an Azure Kubernetes Service (AKS) cluster with multiple node pools, optimized for cost-effective testing scenarios.
- [Secure](examples/secure) - This example demonstrates a maximum-security Kubernetes Cluster configuration suitable for highly sensitive data and regulated environments.
- [Workload Identity](examples/workload-identity) - This example demonstrates an Azure Kubernetes Service (AKS) cluster with Azure AD RBAC and Workload Identity enabled for secure, passwordless authentication.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 1.13.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.13.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.kubernetes_cluster_custom_patch](https://registry.terraform.io/providers/azure/azapi/1.13.0/docs/resources/update_resource) | resource |
| [azapi_update_resource.kubernetes_cluster_oms_agent_patch](https://registry.terraform.io/providers/azure/azapi/1.13.0/docs/resources/update_resource) | resource |
| [azurerm_kubernetes_cluster.kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_extension.kubernetes_cluster_extension](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/kubernetes_cluster_extension) | resource |
| [azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aci_connector_linux"></a> [aci\_connector\_linux](#input\_aci\_connector\_linux) | ACI Connector Linux configuration.<br/><br/>subnet\_name: The subnet name for the virtual nodes to run. | <pre>object({<br/>    subnet_name = string<br/>  })</pre> | `null` | no |
| <a name="input_aks_azapi_patch"></a> [aks\_azapi\_patch](#input\_aks\_azapi\_patch) | Optional AzAPI patch configuration for the AKS ManagedCluster.<br/><br/>enabled: Whether to apply the custom patch.<br/>api\_version: API version for Microsoft.ContainerService/managedClusters.<br/>body: Request body for the patch (applied as-is). | <pre>object({<br/>    enabled     = optional(bool, false)<br/>    api_version = optional(string)<br/>    body        = optional(map(any))<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_api_server_access_profile"></a> [api\_server\_access\_profile](#input\_api\_server\_access\_profile) | API server access profile configuration.<br/><br/>authorized\_ip\_ranges: Set of authorized IP ranges to allow access to API server. | <pre>object({<br/>    authorized_ip_ranges                = optional(list(string))<br/>    subnet_id                           = optional(string)<br/>    virtual_network_integration_enabled = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_auto_scaler_profile"></a> [auto\_scaler\_profile](#input\_auto\_scaler\_profile) | Auto Scaler Profile configuration. | <pre>object({<br/>    balance_similar_node_groups                   = optional(bool)<br/>    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)<br/>    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)<br/>    empty_bulk_delete_max                         = optional(string)<br/>    expander                                      = optional(string)<br/>    ignore_daemonsets_utilization_enabled         = optional(bool)<br/>    max_graceful_termination_sec                  = optional(string)<br/>    max_node_provisioning_time                    = optional(string)<br/>    max_unready_nodes                             = optional(number)<br/>    max_unready_percentage                        = optional(number)<br/>    new_pod_scale_up_delay                        = optional(string)<br/>    scale_down_delay_after_add                    = optional(string)<br/>    scale_down_delay_after_delete                 = optional(string)<br/>    scale_down_delay_after_failure                = optional(string)<br/>    scale_down_unneeded                           = optional(string)<br/>    scale_down_unready                            = optional(string)<br/>    scale_down_utilization_threshold              = optional(string)<br/>    scan_interval                                 = optional(string)<br/>    skip_nodes_with_local_storage                 = optional(bool)<br/>    skip_nodes_with_system_pods                   = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_azure_active_directory_role_based_access_control"></a> [azure\_active\_directory\_role\_based\_access\_control](#input\_azure\_active\_directory\_role\_based\_access\_control) | Azure Active Directory Role Based Access Control configuration.<br/><br/>tenant\_id: The Tenant ID used for Azure Active Directory Application.<br/>admin\_group\_object\_ids: A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.<br/>azure\_rbac\_enabled: Is Role Based Access Control based on Azure AD enabled? | <pre>object({<br/>    tenant_id              = optional(string)<br/>    admin_group_object_ids = optional(list(string))<br/>    azure_rbac_enabled     = optional(bool, true)<br/>  })</pre> | `null` | no |
| <a name="input_confidential_computing"></a> [confidential\_computing](#input\_confidential\_computing) | Confidential computing configuration.<br/><br/>sgx\_quote\_helper\_enabled: Should the SGX quote helper be enabled? | <pre>object({<br/>    sgx_quote_helper_enabled = bool<br/>  })</pre> | `null` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Configuration for the default node pool.<br/><br/>Required fields:<br/>- name: The name which should be used for the default Kubernetes Node Pool.<br/>- vm\_size: The size of the Virtual Machine, such as Standard\_DS2\_v2.<br/><br/>Notes:<br/>- When auto\_scaling\_enabled is false, node\_count is required.<br/>- When auto\_scaling\_enabled is true, node\_count is optional (defaults to min\_count). | <pre>object({<br/>    name                          = string<br/>    vm_size                       = string<br/>    capacity_reservation_group_id = optional(string)<br/>    auto_scaling_enabled          = optional(bool, false)<br/>    host_encryption_enabled       = optional(bool, false)<br/>    node_public_ip_enabled        = optional(bool, false)<br/>    gpu_instance                  = optional(string)<br/>    host_group_id                 = optional(string)<br/><br/>    kubelet_config = optional(object({<br/>      allowed_unsafe_sysctls    = optional(list(string))<br/>      container_log_max_line    = optional(number)<br/>      container_log_max_size_mb = optional(number)<br/>      cpu_cfs_quota_enabled     = optional(bool)<br/>      cpu_cfs_quota_period      = optional(string)<br/>      cpu_manager_policy        = optional(string)<br/>      image_gc_high_threshold   = optional(number)<br/>      image_gc_low_threshold    = optional(number)<br/>      pod_max_pid               = optional(number)<br/>      topology_manager_policy   = optional(string)<br/>    }))<br/><br/>    linux_os_config = optional(object({<br/>      swap_file_size_mb = optional(number)<br/>      sysctl_config = optional(object({<br/>        fs_aio_max_nr                      = optional(number)<br/>        fs_file_max                        = optional(number)<br/>        fs_inotify_max_user_watches        = optional(number)<br/>        fs_nr_open                         = optional(number)<br/>        kernel_threads_max                 = optional(number)<br/>        net_core_netdev_max_backlog        = optional(number)<br/>        net_core_optmem_max                = optional(number)<br/>        net_core_rmem_default              = optional(number)<br/>        net_core_rmem_max                  = optional(number)<br/>        net_core_somaxconn                 = optional(number)<br/>        net_core_wmem_default              = optional(number)<br/>        net_core_wmem_max                  = optional(number)<br/>        net_ipv4_ip_local_port_range_max   = optional(number)<br/>        net_ipv4_ip_local_port_range_min   = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh1  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh2  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh3  = optional(number)<br/>        net_ipv4_tcp_fin_timeout           = optional(number)<br/>        net_ipv4_tcp_keepalive_intvl       = optional(number)<br/>        net_ipv4_tcp_keepalive_probes      = optional(number)<br/>        net_ipv4_tcp_keepalive_time        = optional(number)<br/>        net_ipv4_tcp_max_syn_backlog       = optional(number)<br/>        net_ipv4_tcp_max_tw_buckets        = optional(number)<br/>        net_ipv4_tcp_tw_reuse              = optional(bool)<br/>        net_netfilter_nf_conntrack_buckets = optional(number)<br/>        net_netfilter_nf_conntrack_max     = optional(number)<br/>        vm_max_map_count                   = optional(number)<br/>        vm_swappiness                      = optional(number)<br/>        vm_vfs_cache_pressure              = optional(number)<br/>      }))<br/>      transparent_huge_page_defrag = optional(string)<br/>      transparent_huge_page        = optional(string)<br/>    }))<br/><br/>    fips_enabled      = optional(bool, false)<br/>    kubelet_disk_type = optional(string)<br/>    max_pods          = optional(number)<br/>    node_network_profile = optional(object({<br/>      allowed_host_ports = optional(list(object({<br/>        port_start = optional(number)<br/>        port_end   = optional(number)<br/>        protocol   = optional(string)<br/>      })))<br/>      application_security_group_ids = optional(list(string))<br/>      node_public_ip_tags            = optional(map(string))<br/>    }))<br/><br/>    node_labels                  = optional(map(string))<br/>    node_public_ip_prefix_id     = optional(string)<br/>    only_critical_addons_enabled = optional(bool, false)<br/>    orchestrator_version         = optional(string)<br/>    os_disk_size_gb              = optional(number)<br/>    os_disk_type                 = optional(string, "Managed")<br/>    os_sku                       = optional(string, "Ubuntu")<br/>    pod_subnet_id                = optional(string)<br/>    proximity_placement_group_id = optional(string)<br/>    scale_down_mode              = optional(string, "Delete")<br/><br/>    snapshot_id = optional(string)<br/><br/>    temporary_name_for_rotation = optional(string)<br/>    type                        = optional(string, "VirtualMachineScaleSets")<br/><br/>    ultra_ssd_enabled = optional(bool, false)<br/><br/>    upgrade_settings = optional(object({<br/>      drain_timeout_in_minutes      = optional(number)<br/>      node_soak_duration_in_minutes = optional(number)<br/>      max_surge                     = string<br/>    }))<br/><br/>    vnet_subnet_id   = optional(string)<br/>    workload_runtime = optional(string)<br/>    zones            = optional(list(string))<br/><br/>    max_count  = optional(number)<br/>    min_count  = optional(number)<br/>    node_count = optional(number)<br/>  })</pre> | n/a | yes |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_dns_config"></a> [dns\_config](#input\_dns\_config) | DNS configuration for the Kubernetes cluster.<br/><br/>dns\_prefix: DNS prefix specified when creating the managed cluster. Typically used for public clusters.<br/>dns\_prefix\_private\_cluster: DNS prefix to use with private clusters.<br/><br/>Note: You must define exactly one: either dns\_prefix or dns\_prefix\_private\_cluster, but not both. | <pre>object({<br/>    dns_prefix                 = optional(string, null)<br/>    dns_prefix_private_cluster = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Specifies the Extended Zone (formerly called Edge Zone) within the Azure Region where this Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_extensions"></a> [extensions](#input\_extensions) | List of cluster extensions to install.<br/><br/>Common extension types:<br/>- microsoft.azuremonitor.containers (Azure Monitor)<br/>- microsoft.azure-policy (Azure Policy)<br/>- microsoft.azuredefender.kubernetes (Azure Defender)<br/>- microsoft.openservicemesh (Open Service Mesh)<br/>- microsoft.flux (GitOps Flux v2) | <pre>list(object({<br/>    name                   = string<br/>    extension_type         = string<br/>    release_train          = optional(string)<br/>    release_namespace      = optional(string)<br/>    target_namespace       = optional(string)<br/>    version                = optional(string)<br/>    configuration_settings = optional(map(string))<br/><br/>    plan = optional(object({<br/>      name      = string<br/>      product   = string<br/>      publisher = string<br/>      version   = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_features"></a> [features](#input\_features) | Feature flags for enabling/disabling various Kubernetes cluster features.<br/><br/>azure\_policy\_enabled: Should the Azure Policy Add-On be enabled?<br/>http\_application\_routing\_enabled: Should HTTP Application Routing be enabled?<br/>workload\_identity\_enabled: Specifies whether Azure AD Workload Identity should be enabled for the Cluster.<br/>oidc\_issuer\_enabled: Enable or Disable the OIDC issuer URL.<br/>open\_service\_mesh\_enabled: Is Open Service Mesh enabled?<br/>image\_cleaner\_enabled: Specifies whether Image Cleaner is enabled.<br/>run\_command\_enabled: Whether to enable run command for the cluster or not.<br/>local\_account\_disabled: If true local accounts will be disabled.<br/>cost\_analysis\_enabled: Should cost analysis be enabled for this Kubernetes Cluster? | <pre>object({<br/>    azure_policy_enabled             = optional(bool, false)<br/>    http_application_routing_enabled = optional(bool, false)<br/>    workload_identity_enabled        = optional(bool, false)<br/>    oidc_issuer_enabled              = optional(bool, false)<br/>    open_service_mesh_enabled        = optional(bool, false)<br/>    image_cleaner_enabled            = optional(bool, false)<br/>    run_command_enabled              = optional(bool, true)<br/>    local_account_disabled           = optional(bool, false)<br/>    cost_analysis_enabled            = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "azure_policy_enabled": false,<br/>  "cost_analysis_enabled": false,<br/>  "http_application_routing_enabled": false,<br/>  "image_cleaner_enabled": false,<br/>  "local_account_disabled": false,<br/>  "oidc_issuer_enabled": false,<br/>  "open_service_mesh_enabled": false,<br/>  "run_command_enabled": true,<br/>  "workload_identity_enabled": false<br/>}</pre> | no |
| <a name="input_http_proxy_config"></a> [http\_proxy\_config](#input\_http\_proxy\_config) | HTTP proxy configuration.<br/><br/>http\_proxy: Proxy server endpoint to use for creating HTTP connections.<br/>https\_proxy: Proxy server endpoint to use for creating HTTPS connections.<br/>no\_proxy: Endpoints that should not go through proxy.<br/>trusted\_ca: Alternative CA bundle base64 string. | <pre>object({<br/>    http_proxy  = optional(string)<br/>    https_proxy = optional(string)<br/>    no_proxy    = optional(list(string))<br/>    trusted_ca  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | An identity block (optional). If not set and service\_principal is not provided, the module will use a SystemAssigned identity by default.<br/><br/>type: Specifies the type of Managed Service Identity. Possible values are SystemAssigned or UserAssigned.<br/>identity\_ids: Specifies a list of User Assigned Managed Identity IDs. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | Specifies the interval in hours when images should be cleaned up. Valid values are between 24 and 2160 (90 days). Defaults to 48. | `number` | `48` | no |
| <a name="input_ingress_application_gateway"></a> [ingress\_application\_gateway](#input\_ingress\_application\_gateway) | Application Gateway Ingress Controller add-on configuration.<br/><br/>gateway\_id: The ID of the Application Gateway to integrate with.<br/>gateway\_name: The name of the Application Gateway to be used or created.<br/>subnet\_cidr: The subnet CIDR to be used to create an Application Gateway.<br/>subnet\_id: The ID of the subnet on which to create an Application Gateway. | <pre>object({<br/>    gateway_id   = optional(string)<br/>    gateway_name = optional(string)<br/>    subnet_cidr  = optional(string)<br/>    subnet_id    = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_key_management_service"></a> [key\_management\_service](#input\_key\_management\_service) | Key Management Service configuration.<br/><br/>key\_vault\_key\_id: Identifier of Azure Key Vault key.<br/>key\_vault\_network\_access: Network access of the key vault. Possible values are Public and Private. | <pre>object({<br/>    key_vault_key_id         = string<br/>    key_vault_network_access = optional(string, "Public")<br/>  })</pre> | `null` | no |
| <a name="input_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#input\_key\_vault\_secrets\_provider) | Azure Key Vault Secrets Provider configuration.<br/><br/>secret\_rotation\_enabled: Is secret rotation enabled?<br/>secret\_rotation\_interval: The interval to poll for secret rotation. | <pre>object({<br/>    secret_rotation_enabled  = optional(bool, true)<br/>    secret_rotation_interval = optional(string, "2m")<br/>  })</pre> | `null` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | Kubelet identity configuration.<br/><br/>client\_id: The Client ID of the user-defined Managed Identity to be assigned to the Kubelets.<br/>object\_id: The Object ID of the user-defined Managed Identity assigned to the Kubelets.<br/>user\_assigned\_identity\_id: The ID of the User Assigned Identity assigned to the Kubelets. | <pre>object({<br/>    client_id                 = optional(string)<br/>    object_id                 = optional(string)<br/>    user_assigned_identity_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_kubernetes_config"></a> [kubernetes\_config](#input\_kubernetes\_config) | Kubernetes version and upgrade configuration.<br/><br/>kubernetes\_version: Version of Kubernetes specified when creating the AKS managed cluster.<br/>automatic\_upgrade\_channel: The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image, stable, or none.<br/>node\_os\_upgrade\_channel: The upgrade channel for node OS security updates. Possible values are Unmanaged, SecurityPatch, NodeImage, or None. | <pre>object({<br/>    kubernetes_version        = optional(string)<br/>    automatic_upgrade_channel = optional(string)<br/>    node_os_upgrade_channel   = optional(string, "NodeImage")<br/>  })</pre> | <pre>{<br/>  "node_os_upgrade_channel": "NodeImage"<br/>}</pre> | no |
| <a name="input_linux_profile"></a> [linux\_profile](#input\_linux\_profile) | Linux profile configuration.<br/><br/>admin\_username: The Admin Username for the Cluster.<br/>ssh\_key: An ssh\_key block with key\_data containing the SSH public key. | <pre>object({<br/>    admin_username = string<br/>    ssh_key = object({<br/>      key_data = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window configuration.<br/><br/>allowed: List of allowed maintenance windows.<br/>not\_allowed: List of not allowed maintenance windows. | <pre>object({<br/>    allowed = optional(list(object({<br/>      day   = string<br/>      hours = list(number)<br/>    })))<br/>    not_allowed = optional(list(object({<br/>      end   = string<br/>      start = string<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_window_auto_upgrade"></a> [maintenance\_window\_auto\_upgrade](#input\_maintenance\_window\_auto\_upgrade) | Maintenance window configuration for auto upgrade. | <pre>object({<br/>    duration     = number<br/>    frequency    = string<br/>    interval     = number<br/>    day_of_month = optional(number)<br/>    day_of_week  = optional(string)<br/>    start_date   = optional(string)<br/>    start_time   = optional(string)<br/>    utc_offset   = optional(string)<br/>    week_index   = optional(string)<br/>    not_allowed = optional(list(object({<br/>      end   = string<br/>      start = string<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_window_node_os"></a> [maintenance\_window\_node\_os](#input\_maintenance\_window\_node\_os) | Maintenance window configuration for node OS updates. | <pre>object({<br/>    duration     = number<br/>    frequency    = string<br/>    interval     = number<br/>    day_of_month = optional(number)<br/>    day_of_week  = optional(string)<br/>    start_date   = optional(string)<br/>    start_time   = optional(string)<br/>    utc_offset   = optional(string)<br/>    week_index   = optional(string)<br/>    not_allowed = optional(list(object({<br/>      end   = string<br/>      start = string<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_microsoft_defender"></a> [microsoft\_defender](#input\_microsoft\_defender) | Microsoft Defender configuration.<br/><br/>log\_analytics\_workspace\_id: Specifies the ID of the Log Analytics Workspace where the audit logs should be sent. | <pre>object({<br/>    log_analytics_workspace_id = string<br/>  })</pre> | `null` | no |
| <a name="input_monitor_metrics"></a> [monitor\_metrics](#input\_monitor\_metrics) | Monitor metrics configuration.<br/><br/>annotations\_allowed: Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric.<br/>labels\_allowed: Specifies a comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric. | <pre>object({<br/>    annotations_allowed = optional(string)<br/>    labels_allowed      = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for AKS control plane logs and metrics.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | Network profile configuration for the cluster.<br/><br/>network\_plugin: Network plugin to use. Possible values are azure, kubenet and none.<br/>network\_mode: Network mode to be used. Possible values are bridge and transparent.<br/>network\_policy: Network policy to be used. Possible values are calico, azure and cilium.<br/>dns\_service\_ip: IP address within the Kubernetes service address range for cluster DNS service.<br/>service\_cidr: The Network Range used by the Kubernetes service. Changing this forces a new resource.<br/>load\_balancer\_sku: Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. | <pre>object({<br/>    network_plugin      = optional(string, "azure")<br/>    network_mode        = optional(string)<br/>    network_policy      = optional(string)<br/>    dns_service_ip      = optional(string)<br/>    network_plugin_mode = optional(string)<br/>    outbound_type       = optional(string, "loadBalancer")<br/>    pod_cidr            = optional(string)<br/>    pod_cidrs           = optional(list(string))<br/>    service_cidr        = optional(string)<br/>    service_cidrs       = optional(list(string))<br/>    ip_versions         = optional(list(string))<br/>    load_balancer_sku   = optional(string, "standard")<br/><br/>    load_balancer_profile = optional(object({<br/>      backend_pool_type           = optional(string, "NodeIPConfiguration")<br/>      effective_outbound_ips      = optional(list(string))<br/>      idle_timeout_in_minutes     = optional(number, 30)<br/>      managed_outbound_ip_count   = optional(number)<br/>      managed_outbound_ipv6_count = optional(number)<br/>      outbound_ip_address_ids     = optional(list(string))<br/>      outbound_ip_prefix_ids      = optional(list(string))<br/>      outbound_ports_allocated    = optional(number, 0)<br/>    }))<br/><br/>    nat_gateway_profile = optional(object({<br/>      effective_outbound_ips    = optional(list(string))<br/>      idle_timeout_in_minutes   = optional(number, 4)<br/>      managed_outbound_ip_count = optional(number)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "network_plugin": "azure"<br/>}</pre> | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | List of additional node pools to create.<br/><br/>Each node pool supports the same configuration options as the default node pool,<br/>plus additional options for spot instances and taints.<br/><br/>Notes:<br/>- When auto\_scaling\_enabled is false, node\_count is required.<br/>- When auto\_scaling\_enabled is true, node\_count is optional (defaults to min\_count). | <pre>list(object({<br/>    # Required<br/>    name    = string<br/>    vm_size = string<br/><br/>    # Node Count Configuration<br/>    node_count           = optional(number)<br/>    auto_scaling_enabled = optional(bool, false)<br/>    min_count            = optional(number)<br/>    max_count            = optional(number)<br/><br/>    # VM Configuration<br/>    capacity_reservation_group_id = optional(string)<br/>    host_encryption_enabled       = optional(bool, false)<br/>    node_public_ip_enabled        = optional(bool, false)<br/>    gpu_instance                  = optional(string)<br/>    host_group_id                 = optional(string)<br/><br/>    # OS Configuration<br/>    os_disk_size_gb      = optional(number)<br/>    os_disk_type         = optional(string, "Managed")<br/>    os_sku               = optional(string, "Ubuntu")<br/>    orchestrator_version = optional(string)<br/><br/>    # Network Configuration<br/>    vnet_subnet_id           = optional(string)<br/>    pod_subnet_id            = optional(string)<br/>    node_public_ip_prefix_id = optional(string)<br/><br/>    # Advanced Configuration<br/>    eviction_policy              = optional(string)<br/>    fips_enabled                 = optional(bool, false)<br/>    kubelet_disk_type            = optional(string)<br/>    max_pods                     = optional(number)<br/>    mode                         = optional(string, "User")<br/>    priority                     = optional(string, "Regular")<br/>    proximity_placement_group_id = optional(string)<br/>    scale_down_mode              = optional(string, "Delete")<br/>    snapshot_id                  = optional(string)<br/>    spot_max_price               = optional(number, -1)<br/>    ultra_ssd_enabled            = optional(bool, false)<br/>    workload_runtime             = optional(string)<br/>    zones                        = optional(list(string))<br/><br/>    # Node Labels and Taints<br/>    node_labels = optional(map(string))<br/>    node_taints = optional(list(string))<br/><br/>    # Kubelet Configuration<br/>    kubelet_config = optional(object({<br/>      allowed_unsafe_sysctls    = optional(list(string))<br/>      container_log_max_line    = optional(number)<br/>      container_log_max_size_mb = optional(number)<br/>      cpu_cfs_quota_enabled     = optional(bool)<br/>      cpu_cfs_quota_period      = optional(string)<br/>      cpu_manager_policy        = optional(string)<br/>      image_gc_high_threshold   = optional(number)<br/>      image_gc_low_threshold    = optional(number)<br/>      pod_max_pid               = optional(number)<br/>      topology_manager_policy   = optional(string)<br/>    }))<br/><br/>    # Linux OS Configuration<br/>    linux_os_config = optional(object({<br/>      swap_file_size_mb            = optional(number)<br/>      transparent_huge_page_defrag = optional(string)<br/>      transparent_huge_page        = optional(string)<br/>      sysctl_config = optional(object({<br/>        fs_aio_max_nr                      = optional(number)<br/>        fs_file_max                        = optional(number)<br/>        fs_inotify_max_user_watches        = optional(number)<br/>        fs_nr_open                         = optional(number)<br/>        kernel_threads_max                 = optional(number)<br/>        net_core_netdev_max_backlog        = optional(number)<br/>        net_core_optmem_max                = optional(number)<br/>        net_core_rmem_default              = optional(number)<br/>        net_core_rmem_max                  = optional(number)<br/>        net_core_somaxconn                 = optional(number)<br/>        net_core_wmem_default              = optional(number)<br/>        net_core_wmem_max                  = optional(number)<br/>        net_ipv4_ip_local_port_range_max   = optional(number)<br/>        net_ipv4_ip_local_port_range_min   = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh1  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh2  = optional(number)<br/>        net_ipv4_neigh_default_gc_thresh3  = optional(number)<br/>        net_ipv4_tcp_fin_timeout           = optional(number)<br/>        net_ipv4_tcp_keepalive_intvl       = optional(number)<br/>        net_ipv4_tcp_keepalive_probes      = optional(number)<br/>        net_ipv4_tcp_keepalive_time        = optional(number)<br/>        net_ipv4_tcp_max_syn_backlog       = optional(number)<br/>        net_ipv4_tcp_max_tw_buckets        = optional(number)<br/>        net_ipv4_tcp_tw_reuse              = optional(bool)<br/>        net_netfilter_nf_conntrack_buckets = optional(number)<br/>        net_netfilter_nf_conntrack_max     = optional(number)<br/>        vm_max_map_count                   = optional(number)<br/>        vm_swappiness                      = optional(number)<br/>        vm_vfs_cache_pressure              = optional(number)<br/>      }))<br/>    }))<br/><br/>    # Node Network Profile<br/>    node_network_profile = optional(object({<br/>      application_security_group_ids = optional(list(string))<br/>      node_public_ip_tags            = optional(map(string))<br/>      allowed_host_ports = optional(list(object({<br/>        port_start = optional(number)<br/>        port_end   = optional(number)<br/>        protocol   = optional(string)<br/>      })))<br/>    }))<br/><br/>    # Windows Profile<br/>    windows_profile = optional(object({<br/>      outbound_nat_enabled = optional(bool, true)<br/>    }))<br/><br/>    # Upgrade Settings<br/>    upgrade_settings = optional(object({<br/>      drain_timeout_in_minutes      = optional(number)<br/>      max_surge                     = string<br/>      node_soak_duration_in_minutes = optional(number)<br/>    }))<br/><br/>    # Tags<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_node_resource_group"></a> [node\_resource\_group](#input\_node\_resource\_group) | The name of the Resource Group where the Kubernetes Nodes should exist. Azure requires that a new, non-existent Resource Group is used. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_oms_agent"></a> [oms\_agent](#input\_oms\_agent) | OMS Agent configuration for Azure Monitor.<br/><br/>log\_analytics\_workspace\_id: The ID of the Log Analytics Workspace which the OMS Agent should send data to.<br/>msi\_auth\_for\_monitoring\_enabled: Is managed identity authentication for monitoring enabled?<br/>ampls\_settings: Azure Monitor Private Link Scope (AMPLS) settings.<br/>  id: The Resource ID of the Azure Monitor Private Link Scope (AMPLS).<br/>  enabled: Whether to apply the AMPLS patch (default: true).<br/>collection\_profile: Collection profile for Container Insights streams.<br/>  basic: Microsoft-Perf + Microsoft-ContainerLogV2.<br/>  advanced: basic + Microsoft-KubeEvents + Microsoft-KubePodInventory. | <pre>object({<br/>    log_analytics_workspace_id      = string<br/>    msi_auth_for_monitoring_enabled = optional(bool, true)<br/>    ampls_settings = optional(object({<br/>      id      = string<br/>      enabled = optional(bool, true)<br/>    }))<br/>    collection_profile     = optional(string, "basic")<br/>    namespaceFilteringMode = optional(string, "Off")<br/>  })</pre> | `null` | no |
| <a name="input_private_cluster_config"></a> [private\_cluster\_config](#input\_private\_cluster\_config) | Private cluster configuration.<br/><br/>private\_cluster\_enabled: Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?<br/>private\_dns\_zone\_id: Either the ID of Private DNS Zone which should be delegated to this Cluster, System to have AKS manage this or None.<br/>private\_cluster\_public\_fqdn\_enabled: Specifies whether a Public FQDN for this Private Cluster should be added. | <pre>object({<br/>    private_cluster_enabled             = optional(bool, false)<br/>    private_dns_zone_id                 = optional(string)<br/>    private_cluster_public_fqdn_enabled = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "private_cluster_enabled": false,<br/>  "private_cluster_public_fqdn_enabled": false<br/>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_service_mesh_profile"></a> [service\_mesh\_profile](#input\_service\_mesh\_profile) | Service mesh profile configuration.<br/><br/>mode: The mode of the service mesh. Possible value is Istio.<br/>revisions: Specify 1 or 2 Istio control plane revisions for managing minor upgrades.<br/>internal\_ingress\_gateway\_enabled: Is Istio Internal Ingress Gateway enabled?<br/>external\_ingress\_gateway\_enabled: Is Istio External Ingress Gateway enabled? | <pre>object({<br/>    mode                             = string<br/>    revisions                        = list(string)<br/>    internal_ingress_gateway_enabled = optional(bool)<br/>    external_ingress_gateway_enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_service_principal"></a> [service\_principal](#input\_service\_principal) | A service\_principal block (optional). If set, this will be used instead of managed identity.<br/>Note: A migration scenario from service\_principal to identity is supported (switch configuration over time). | <pre>object({<br/>    client_id     = string<br/>    client_secret = string<br/>  })</pre> | `null` | no |
| <a name="input_sku_config"></a> [sku\_config](#input\_sku\_config) | SKU configuration for the Kubernetes cluster.<br/><br/>sku\_tier: The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium.<br/>support\_plan: Specifies the support plan which should be used for this Kubernetes Cluster. Possible values are KubernetesOfficial and AKSLongTermSupport. | <pre>object({<br/>    sku_tier     = optional(string, "Free")<br/>    support_plan = optional(string, "KubernetesOfficial")<br/>  })</pre> | <pre>{<br/>  "sku_tier": "Free",<br/>  "support_plan": "KubernetesOfficial"<br/>}</pre> | no |
| <a name="input_storage_profile"></a> [storage\_profile](#input\_storage\_profile) | Storage profile configuration.<br/><br/>blob\_driver\_enabled: Is the Blob CSI driver enabled?<br/>disk\_driver\_enabled: Is the Disk CSI driver enabled?<br/>disk\_driver\_version: Disk CSI Driver version to be used.<br/>file\_driver\_enabled: Is the File CSI driver enabled?<br/>snapshot\_controller\_enabled: Is the Snapshot Controller enabled? | <pre>object({<br/>    blob_driver_enabled         = optional(bool, false)<br/>    disk_driver_enabled         = optional(bool, true)<br/>    file_driver_enabled         = optional(bool, true)<br/>    snapshot_controller_enabled = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_web_app_routing"></a> [web\_app\_routing](#input\_web\_app\_routing) | Web App Routing configuration.<br/><br/>dns\_zone\_ids: Specifies the list of the DNS Zone IDs in which DNS entries are created for applications deployed to the cluster.<br/>web\_app\_routing\_identity: A web\_app\_routing\_identity block. | <pre>object({<br/>    dns_zone_ids = list(string)<br/>    web_app_routing_identity = optional(object({<br/>      client_id                 = string<br/>      object_id                 = string<br/>      user_assigned_identity_id = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_windows_profile"></a> [windows\_profile](#input\_windows\_profile) | Windows profile configuration.<br/><br/>admin\_username: The Admin Username for Windows VMs.<br/>admin\_password: The Admin Password for Windows VMs.<br/>license: Specifies the type of on-premise license which should be used for Node Pool Windows VM's.<br/>gmsa: GMSA configuration for Windows node pools. | <pre>object({<br/>    admin_username = string<br/>    admin_password = optional(string)<br/>    license        = optional(string)<br/>    gmsa = optional(object({<br/>      root_domain = string<br/>      dns_server  = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_workload_autoscaler_profile"></a> [workload\_autoscaler\_profile](#input\_workload\_autoscaler\_profile) | Workload autoscaler profile configuration.<br/><br/>keda\_enabled: Specifies whether KEDA Autoscaler can be used for workloads.<br/>vertical\_pod\_autoscaler\_enabled: Specifies whether Vertical Pod Autoscaler should be enabled. | <pre>object({<br/>    keda_enabled                    = optional(bool)<br/>    vertical_pod_autoscaler_enabled = optional(bool)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aci_connector_linux"></a> [aci\_connector\_linux](#output\_aci\_connector\_linux) | The ACI Connector Linux addon configuration. |
| <a name="output_current_kubernetes_version"></a> [current\_kubernetes\_version](#output\_current\_kubernetes\_version) | The current version running on the Azure Kubernetes Managed Cluster. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_extensions"></a> [extensions](#output\_extensions) | List of installed extensions with their IDs and details |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN of the Azure Kubernetes Managed Cluster. |
| <a name="output_http_proxy_config"></a> [http\_proxy\_config](#output\_http\_proxy\_config) | The HTTP proxy configuration. |
| <a name="output_id"></a> [id](#output\_id) | The Kubernetes Managed Cluster ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | The assigned managed identity for the Kubernetes Cluster. |
| <a name="output_ingress_application_gateway"></a> [ingress\_application\_gateway](#output\_ingress\_application\_gateway) | The Application Gateway Ingress Controller addon configuration. |
| <a name="output_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#output\_key\_vault\_secrets\_provider) | The Key Vault Secrets Provider secret\_identity. |
| <a name="output_kube_admin_config"></a> [kube\_admin\_config](#output\_kube\_admin\_config) | Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled. |
| <a name="output_kube_admin_config_raw"></a> [kube\_admin\_config\_raw](#output\_kube\_admin\_config\_raw) | Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled. |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | Raw Kubernetes config to be used by kubectl and other compatible tools. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | The Kubelet Identity used by the Kubernetes Cluster. |
| <a name="output_location"></a> [location](#output\_location) | The Azure Region where the Kubernetes Cluster exists. |
| <a name="output_microsoft_defender"></a> [microsoft\_defender](#output\_microsoft\_defender) | The Microsoft Defender configuration. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Kubernetes Cluster. |
| <a name="output_network_profile"></a> [network\_profile](#output\_network\_profile) | The network profile of the Kubernetes Cluster. |
| <a name="output_node_pools"></a> [node\_pools](#output\_node\_pools) | List of created node pools with their IDs and details |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. |
| <a name="output_node_resource_group_id"></a> [node\_resource\_group\_id](#output\_node\_resource\_group\_id) | The ID of the Resource Group containing the resources for this Managed Kubernetes Cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The OIDC issuer URL that is associated with the cluster. |
| <a name="output_oms_agent"></a> [oms\_agent](#output\_oms\_agent) | The OMS Agent Identity. |
| <a name="output_portal_fqdn"></a> [portal\_fqdn](#output\_portal\_fqdn) | The FQDN for the Azure Portal resources when private link has been enabled. |
| <a name="output_private_fqdn"></a> [private\_fqdn](#output\_private\_fqdn) | The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group where the Kubernetes Cluster exists. |
| <a name="output_service_mesh_profile"></a> [service\_mesh\_profile](#output\_service\_mesh\_profile) | The Service Mesh (Istio) configuration. |
| <a name="output_service_principal"></a> [service\_principal](#output\_service\_principal) | The Service Principal used by the Kubernetes Cluster. |
| <a name="output_tags"></a> [tags](#output\_tags) | A mapping of tags assigned to the Kubernetes Cluster. |
| <a name="output_web_app_routing"></a> [web\_app\_routing](#output\_web\_app\_routing) | The Web App Routing addon configuration. |
| <a name="output_windows_profile"></a> [windows\_profile](#output\_windows\_profile) | The Windows Profile configuration. |
| <a name="output_workload_autoscaler_profile"></a> [workload\_autoscaler\_profile](#output\_workload\_autoscaler\_profile) | The Workload Autoscaler Profile configuration. |
<!-- END_TF_DOCS -->

## Security Considerations

This module implements several security best practices by default:

- **System-assigned managed identity** is used by default (no service principal passwords)
- **Azure RBAC** can be enabled for fine-grained access control
- **Private cluster** option available to restrict API server access
- **Network policies** supported for pod-to-pod security
- **Workload Identity** and OIDC for secure workload authentication
- **Disk encryption** enabled by default
- **Security patches** automated through upgrade channels

For production deployments, see the [secure example](examples/secure) which demonstrates all security features.

## Monitoring and Observability

The module supports comprehensive monitoring through:

- **Azure Monitor** integration with Container Insights
- **Log Analytics** workspace for centralized logging
- **Prometheus metrics** collection
- **Diagnostic settings** for control plane logs
- **Application Insights** integration for APM

## Cost Optimization

To optimize costs:

- Use **spot instances** for non-critical workloads
- Enable **cluster autoscaler** to scale nodes based on demand
- Configure **maintenance windows** during off-peak hours
- Use **Standard SKU** only when SLA is required
- Consider **B-series VMs** for development/testing

## Troubleshooting

Common issues and solutions:

1. **Subnet size too small**: Ensure subnet has enough IPs for nodes and pods
2. **DNS resolution issues**: Check DNS service IP is within service CIDR
3. **Node pool scaling**: Verify quota limits in your subscription
4. **Private cluster access**: Configure VPN or jump box for kubectl access

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [IMPORT.md](docs/IMPORT.md) - Import existing AKS using Terraform import blocks
- [Module Documentation](docs/) - Additional guides and best practices

## External Resources

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [AKS Networking Concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [AKS Security Baseline](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/aks-security-baseline)
