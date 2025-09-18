# Cluster Identity Information
output "id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.id, null)
}

output "name" {
  description = "The name of the Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.name, null)
}

output "location" {
  description = "The Azure Region where the Kubernetes Cluster exists."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.location, null)
}

output "resource_group_name" {
  description = "The name of the Resource Group where the Kubernetes Cluster exists."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.resource_group_name, null)
}

# Cluster Access Information
output "fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.fqdn, null)
}

output "private_fqdn" {
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.private_fqdn, null)
}

output "portal_fqdn" {
  description = "The FQDN for the Azure Portal resources when private link has been enabled."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.portal_fqdn, null)
}

output "current_kubernetes_version" {
  description = "The current version running on the Azure Kubernetes Managed Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.current_kubernetes_version, null)
}

# Kubeconfig
output "kube_config" {
  description = "Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config[0], null)
  sensitive   = true
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw, null)
  sensitive   = true
}

output "kube_admin_config" {
  description = "Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config[0], null)
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config_raw, null)
  sensitive   = true
}

# Cluster Configuration
output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group, null)
}

output "node_resource_group_id" {
  description = "The ID of the Resource Group containing the resources for this Managed Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group_id, null)
}

# Identity Information
output "identity" {
  description = "The assigned managed identity for the Kubernetes Cluster."
  value = try({
    type         = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type
    principal_id = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].tenant_id
    identity_ids = try(azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].identity_ids, null)
  }, null)
  sensitive = true
}

output "kubelet_identity" {
  description = "The Kubelet Identity used by the Kubernetes Cluster."
  value = try({
    client_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].user_assigned_identity_id
  }, null)
  sensitive = true
}

# Service Principal (if used instead of managed identity)
output "service_principal" {
  description = "The Service Principal used by the Kubernetes Cluster."
  value = try({
    client_id = azurerm_kubernetes_cluster.kubernetes_cluster.service_principal[0].client_id
  }, null)
  sensitive = true
}

# OIDC Configuration
output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url, null)
}

# Key Vault Secrets Provider
output "key_vault_secrets_provider" {
  description = "The Key Vault Secrets Provider secret_identity."
  value = try({
    secret_identity = {
      client_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.key_vault_secrets_provider[0].secret_identity[0].client_id
      object_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
      user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.key_vault_secrets_provider[0].secret_identity[0].user_assigned_identity_id
    }
  }, null)
}

# OMS Agent
output "oms_agent" {
  description = "The OMS Agent Identity."
  value = try({
    oms_agent_identity = {
      client_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.oms_agent[0].oms_agent_identity[0].client_id
      object_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.oms_agent[0].oms_agent_identity[0].object_id
      user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.oms_agent[0].oms_agent_identity[0].user_assigned_identity_id
    }
  }, null)
}

# Application Gateway Ingress Controller
output "ingress_application_gateway" {
  description = "The Application Gateway Ingress Controller addon configuration."
  value = try({
    effective_gateway_id = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].effective_gateway_id
    gateway_id           = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].gateway_id
    gateway_name         = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].gateway_name
    subnet_cidr          = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].subnet_cidr
    subnet_id            = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].subnet_id

    ingress_application_gateway_identity = try({
      client_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].client_id
      object_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
      user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].user_assigned_identity_id
    }, null)
  }, null)
}

# ACI Connector Linux
output "aci_connector_linux" {
  description = "The ACI Connector Linux addon configuration."
  value = try({
    connector_identity = {
      client_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.aci_connector_linux[0].connector_identity[0].client_id
      object_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.aci_connector_linux[0].connector_identity[0].object_id
      user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.aci_connector_linux[0].connector_identity[0].user_assigned_identity_id
    }
  }, null)
}

# Web App Routing
output "web_app_routing" {
  description = "The Web App Routing addon configuration."
  value = try({
    web_app_routing_identity = {
      client_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.web_app_routing[0].web_app_routing_identity[0].client_id
      object_id                 = azurerm_kubernetes_cluster.kubernetes_cluster.web_app_routing[0].web_app_routing_identity[0].object_id
      user_assigned_identity_id = azurerm_kubernetes_cluster.kubernetes_cluster.web_app_routing[0].web_app_routing_identity[0].user_assigned_identity_id
    }
  }, null)
}

# Microsoft Defender
output "microsoft_defender" {
  description = "The Microsoft Defender configuration."
  value = try({
    log_analytics_workspace_id = azurerm_kubernetes_cluster.kubernetes_cluster.microsoft_defender[0].log_analytics_workspace_id
  }, null)
}

# Network Profile
output "network_profile" {
  description = "The network profile of the Kubernetes Cluster."
  value = try({
    network_plugin      = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_plugin
    network_mode        = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_mode
    network_policy      = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_policy
    dns_service_ip      = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].dns_service_ip
    network_plugin_mode = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].network_plugin_mode
    outbound_type       = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].outbound_type
    pod_cidr            = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].pod_cidr
    pod_cidrs           = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].pod_cidrs
    service_cidr        = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].service_cidr
    service_cidrs       = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].service_cidrs
    ip_versions         = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].ip_versions
    load_balancer_sku   = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_sku

    load_balancer_profile = try({
      effective_outbound_ips      = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].effective_outbound_ips
      idle_timeout_in_minutes     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].idle_timeout_in_minutes
      managed_outbound_ip_count   = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].managed_outbound_ip_count
      managed_outbound_ipv6_count = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].managed_outbound_ipv6_count
      outbound_ip_address_ids     = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].outbound_ip_address_ids
      outbound_ip_prefix_ids      = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].outbound_ip_prefix_ids
      outbound_ports_allocated    = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].load_balancer_profile[0].outbound_ports_allocated
    }, null)

    nat_gateway_profile = try({
      effective_outbound_ips    = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].nat_gateway_profile[0].effective_outbound_ips
      idle_timeout_in_minutes   = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].nat_gateway_profile[0].idle_timeout_in_minutes
      managed_outbound_ip_count = azurerm_kubernetes_cluster.kubernetes_cluster.network_profile[0].nat_gateway_profile[0].managed_outbound_ip_count
    }, null)
  }, null)
}

# HTTP Proxy Configuration
output "http_proxy_config" {
  description = "The HTTP proxy configuration."
  value = try({
    http_proxy  = azurerm_kubernetes_cluster.kubernetes_cluster.http_proxy_config[0].http_proxy
    https_proxy = azurerm_kubernetes_cluster.kubernetes_cluster.http_proxy_config[0].https_proxy
    no_proxy    = azurerm_kubernetes_cluster.kubernetes_cluster.http_proxy_config[0].no_proxy
  }, null)
  sensitive = true
}

# Windows Profile
output "windows_profile" {
  description = "The Windows Profile configuration."
  value = try({
    admin_username = azurerm_kubernetes_cluster.kubernetes_cluster.windows_profile[0].admin_username
  }, null)
}

# Service Mesh Profile
output "service_mesh_profile" {
  description = "The Service Mesh (Istio) configuration."
  value = try({
    mode                             = azurerm_kubernetes_cluster.kubernetes_cluster.service_mesh_profile[0].mode
    revisions                        = azurerm_kubernetes_cluster.kubernetes_cluster.service_mesh_profile[0].revisions
    internal_ingress_gateway_enabled = azurerm_kubernetes_cluster.kubernetes_cluster.service_mesh_profile[0].internal_ingress_gateway_enabled
    external_ingress_gateway_enabled = azurerm_kubernetes_cluster.kubernetes_cluster.service_mesh_profile[0].external_ingress_gateway_enabled
  }, null)
}

# Workload Autoscaler Profile
output "workload_autoscaler_profile" {
  description = "The Workload Autoscaler Profile configuration."
  value = try({
    keda_enabled                    = azurerm_kubernetes_cluster.kubernetes_cluster.workload_autoscaler_profile[0].keda_enabled
    vertical_pod_autoscaler_enabled = azurerm_kubernetes_cluster.kubernetes_cluster.workload_autoscaler_profile[0].vertical_pod_autoscaler_enabled
  }, null)
}

# Tags
output "tags" {
  description = "A mapping of tags assigned to the Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.tags, null)
}

# Additional Node Pools Outputs
output "node_pools" {
  description = "List of created node pools with their IDs and details"
  value = [
    for k, v in azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool : {
      id   = v.id
      name = v.name
    }
  ]
}

# Extensions Outputs
output "extensions" {
  description = "List of installed extensions with their IDs and details"
  value = [
    for k, v in azurerm_kubernetes_cluster_extension.kubernetes_cluster_extension : {
      id                    = v.id
      name                  = v.name
      current_version       = v.current_version
      release_train_applied = v.release_train_applied
    }
  ]
}

