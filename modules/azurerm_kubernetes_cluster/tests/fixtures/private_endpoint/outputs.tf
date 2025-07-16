output "kubernetes_cluster_id" {
  description = "The ID of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.name
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.kubernetes_cluster.private_endpoints
}

# Create module.json and .releaserc.js
print_info "Creating module.json and .releaserc.js..."
if [[ -x "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/scripts/create-module-json.sh" ]]; then
    "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/scripts/create-module-json.sh" "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/modules/azurerm_kubernetes_cluster" "Kubernetes Cluster" "kubernetes-cluster" "AKS"
else
    print_warning "scripts/create-module-json.sh not found or not executable."
fi

