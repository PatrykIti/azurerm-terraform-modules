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

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity"
  value       = module.kubernetes_cluster.oidc_issuer_url
}

output "workload_identity_client_id" {
  description = "The client ID of the workload identity"
  value       = azurerm_user_assigned_identity.example_workload.client_id
}

output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = azurerm_key_vault.example.name
}

output "aks_admins_group_id" {
  description = "The object ID of the AKS administrators group"
  value       = azuread_group.aks_admins.object_id
}

output "connect_command" {
  description = "Command to connect to the cluster using kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${module.kubernetes_cluster.name}"
}

output "workload_identity_setup_commands" {
  description = "Commands to set up workload identity in the cluster"
  value       = <<-EOT
    # Create namespace (if not using default)
    kubectl create namespace workload-identity-demo || true
    
    # Create service account with workload identity annotation
    kubectl create serviceaccount workload-identity-sa \
      --namespace default
    
    # Annotate the service account with the workload identity
    kubectl annotate serviceaccount workload-identity-sa \
      --namespace default \
      azure.workload.identity/client-id="${azurerm_user_assigned_identity.example_workload.client_id}"
    
    # Label the namespace for workload identity
    kubectl label namespace default \
      azure.workload.identity/use=true
    
    # Deploy a test pod with workload identity
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: workload-identity-test
      namespace: default
    spec:
      serviceAccountName: workload-identity-sa
      containers:
      - name: test
        image: mcr.microsoft.com/azure-cli:latest
        command: ["/bin/bash", "-c", "--"]
        args: ["while true; do sleep 30; done;"]
    EOF
    
    # Test workload identity (run inside the pod)
    kubectl exec -it workload-identity-test -- az login --federated-token \$(cat /var/run/secrets/azure/tokens/azure-identity-token) --service-principal -u ${azurerm_user_assigned_identity.example_workload.client_id} -t ${data.azurerm_client_config.current.tenant_id}
  EOT
}