output "cluster_role_name" { value = module.kubernetes_cluster_role.name }
output "cluster_role_rule_count" { value = length(module.kubernetes_cluster_role.rules) }
