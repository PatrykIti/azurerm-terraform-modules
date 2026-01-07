output "securityrole_assignment_ids" {
  description = "Map of security role assignment IDs keyed by assignment key."
  value       = module.azuredevops_securityrole_assignment.securityrole_assignment_ids
}
