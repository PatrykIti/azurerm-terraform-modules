output "cognitive_account_id" {
  description = "The Cognitive Account resource ID."
  value       = module.cognitive_account.id
}

output "cognitive_account_name" {
  description = "The Cognitive Account name."
  value       = module.cognitive_account.name
}

output "cognitive_account_endpoint" {
  description = "The Cognitive Account endpoint."
  value       = module.cognitive_account.endpoint
}
