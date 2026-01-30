resource "azurerm_cognitive_account" "cognitive_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = local.kind_normalized
  sku_name            = var.sku_name

  custom_subdomain_name           = var.custom_subdomain_name
  public_network_access_enabled   = var.public_network_access_enabled
  local_auth_enabled              = var.local_auth_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted
  fqdns                           = var.fqdns

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      default_action = network_acls.value.default_action
      bypass         = try(network_acls.value.bypass, null)
      ip_rules       = try(network_acls.value.ip_rules, null)

      dynamic "virtual_network_rules" {
        for_each = try(network_acls.value.virtual_network_rules, [])
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, false)
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "customer_managed_key" {
    for_each = local.customer_managed_key_inline ? [var.customer_managed_key] : []
    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = try(customer_managed_key.value.identity_client_id, null)
    }
  }

  dynamic "storage" {
    for_each = var.storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = try(storage.value.identity_client_id, null)
    }
  }

  dynamic "timeouts" {
    for_each = local.timeouts_enabled ? [var.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.network_acls == null || (var.custom_subdomain_name != null && var.custom_subdomain_name != "")
      error_message = "custom_subdomain_name is required when network_acls is set."
    }

    precondition {
      condition     = var.network_acls == null || var.network_acls.bypass == null || contains(["OpenAI", "TextAnalytics"], local.kind_normalized)
      error_message = "network_acls.bypass is only supported for kind OpenAI or TextAnalytics."
    }

    precondition {
      condition     = var.customer_managed_key == null || local.identity_has_user_assigned
      error_message = "customer_managed_key requires identity.type to include UserAssigned."
    }

    precondition {
      condition     = local.kind_normalized != "OpenAI" || length(var.storage) == 0
      error_message = "storage is not supported for kind OpenAI."
    }

    precondition {
      condition     = local.openai_enabled || (length(var.deployments) == 0 && length(var.rai_policies) == 0 && length(var.rai_blocklists) == 0)
      error_message = "OpenAI sub-resources (deployments, rai_policies, rai_blocklists) require kind = OpenAI."
    }
  }
}

resource "azurerm_cognitive_deployment" "cognitive_deployment" {
  for_each = local.openai_enabled ? local.deployments_by_name : {}

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id

  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = try(each.value.model.version, null)
  }

  sku {
    name     = each.value.sku.name
    tier     = try(each.value.sku.tier, null)
    size     = try(each.value.sku.size, null)
    family   = try(each.value.sku.family, null)
    capacity = try(each.value.sku.capacity, null)
  }

  dynamic_throttling_enabled = try(each.value.dynamic_throttling_enabled, null)
  rai_policy_name            = try(each.value.rai_policy_name, null)
  version_upgrade_option     = try(each.value.version_upgrade_option, null)
}

resource "azurerm_cognitive_account_rai_policy" "rai_policy" {
  for_each = local.openai_enabled ? local.rai_policies_by_name : {}

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id
  base_policy_name     = each.value.base_policy_name
  mode                 = try(each.value.mode, null)
  tags                 = try(each.value.tags, null)

  dynamic "content_filter" {
    for_each = each.value.content_filters
    content {
      name               = content_filter.value.name
      filter_enabled     = content_filter.value.filter_enabled
      block_enabled      = content_filter.value.block_enabled
      severity_threshold = content_filter.value.severity_threshold
      source             = content_filter.value.source
    }
  }
}

resource "azurerm_cognitive_account_rai_blocklist" "rai_blocklist" {
  for_each = local.openai_enabled ? local.rai_blocklists_by_name : {}

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id
  description          = try(each.value.description, null)
}

resource "azurerm_cognitive_account_customer_managed_key" "customer_managed_key" {
  count = local.customer_managed_key_resource ? 1 : 0

  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id
  key_vault_key_id     = var.customer_managed_key.key_vault_key_id
  identity_client_id   = try(var.customer_managed_key.identity_client_id, null)
}
