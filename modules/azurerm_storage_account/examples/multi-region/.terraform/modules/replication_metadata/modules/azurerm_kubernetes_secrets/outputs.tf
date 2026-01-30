output "strategy" {
  description = "Selected secret management strategy."
  value       = var.strategy
}

output "name" {
  description = "Base name for created Kubernetes objects."
  value       = var.name
}

output "namespace" {
  description = "Namespace for created Kubernetes objects."
  value       = var.namespace
}

output "kubernetes_secret_name" {
  description = "Name of the Kubernetes Secret created by manual strategy or CSI sync."
  value = var.strategy == "manual" ? var.name : (
    var.strategy == "csi" ? (try(var.csi.sync_to_kubernetes_secret, false) ? var.csi.kubernetes_secret_name : null) : null
  )
}

output "secret_provider_class_name" {
  description = "Name of the SecretProviderClass (CSI strategy)."
  value       = var.strategy == "csi" ? var.name : null
}

output "secret_store_name" {
  description = "Name of the SecretStore/ClusterSecretStore (ESO strategy)."
  value       = var.strategy == "eso" ? nonsensitive(try(var.eso.secret_store.name, null)) : null
}

output "external_secret_names" {
  description = "Names of ExternalSecret resources (ESO strategy)."
  value       = var.strategy == "eso" ? nonsensitive([for external_secret in var.eso.external_secrets : external_secret.name]) : []
}
