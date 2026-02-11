output "cognitive_account_id" {
  description = "The Cognitive Account resource ID."
  value       = module.cognitive_account.id
}

output "customer_managed_key_id" {
  description = "The CMK resource ID."
  value       = module.cognitive_account.customer_managed_key_id
}
