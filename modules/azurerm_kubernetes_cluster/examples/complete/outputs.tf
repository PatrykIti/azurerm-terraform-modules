# Cluster identification outputs
output "kubernetes_cluster_id" {
  description = "The ID of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.name
}

output "kubernetes_cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes Service"
  value       = module.kubernetes_cluster.fqdn
}

# Resource group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "node_resource_group" {
  description = "The name of the node resource group"
  value       = module.kubernetes_cluster.node_resource_group
}

# Identity outputs
output "cluster_identity" {
  description = "The managed identity of the cluster"
  value = {
    type         = module.kubernetes_cluster.identity[0].type
    principal_id = module.kubernetes_cluster.identity[0].principal_id
    tenant_id    = module.kubernetes_cluster.identity[0].tenant_id
  }
}

output "kubelet_identity" {
  description = "The kubelet identity of the cluster"
  value = module.kubernetes_cluster.kubelet_identity
}

# Network outputs
output "network_profile" {
  description = "The network profile of the cluster"
  value = module.kubernetes_cluster.network_profile
}

# OIDC outputs
output "oidc_issuer_url" {
  description = "The OIDC issuer URL"
  value       = module.kubernetes_cluster.oidc_issuer_url
}

# Monitoring outputs
output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

# Access commands
output "connect_command" {
  description = "Command to connect to the cluster using kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${module.kubernetes_cluster.name}"
}

output "get_token_command" {
  description = "Command to get token for the cluster (when using Azure AD)"
  value       = "kubelogin get-token --login azurecli --server-id 6dae42f8-4368-4678-94ff-3960e28e3630"
}
