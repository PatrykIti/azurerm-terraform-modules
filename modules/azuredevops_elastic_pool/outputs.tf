output "elastic_pool_id" {
  description = "ID of the elastic pool created by the module."
  value       = azuredevops_elastic_pool.elastic_pool.id
}
