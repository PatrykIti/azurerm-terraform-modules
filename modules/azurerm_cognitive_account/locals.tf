locals {
  kind_normalized = var.kind == "Language" ? "TextAnalytics" : var.kind
  openai_enabled  = local.kind_normalized == "OpenAI"

  deployments_by_name  = { for deployment in var.deployments : deployment.name => deployment }
  rai_policies_by_name = { for policy in var.rai_policies : policy.name => policy }
  rai_blocklists_by_name = { for blocklist in var.rai_blocklists : blocklist.name => blocklist }

  customer_managed_key_inline   = var.customer_managed_key != null && !try(var.customer_managed_key.use_separate_resource, false)
  customer_managed_key_resource = var.customer_managed_key != null && try(var.customer_managed_key.use_separate_resource, false)

  identity_type             = try(var.identity.type, null)
  identity_has_user_assigned = var.identity != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], local.identity_type)

  timeouts_enabled = length(compact([
    try(var.timeouts.create, null),
    try(var.timeouts.update, null),
    try(var.timeouts.read, null),
    try(var.timeouts.delete, null)
  ])) > 0
}
