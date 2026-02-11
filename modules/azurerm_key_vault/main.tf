locals {
  secrets_by_name = {
    for secret in var.secrets : secret.name => secret
  }

  certificates_by_name = {
    for cert in var.certificates : cert.name => cert
  }

  certificate_issuers_by_name = {
    for issuer in var.certificate_issuers : issuer.name => issuer
  }

  managed_storage_accounts_by_name = {
    for account in var.managed_storage_accounts : account.name => account
  }

  managed_storage_sas_definitions_by_name = {
    for definition in var.managed_storage_sas_definitions : definition.name => definition
  }
}

resource "azurerm_key_vault" "key_vault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  rbac_authorization_enabled    = var.rbac_authorization_enabled
  public_network_access_enabled = var.public_network_access_enabled
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days

  dynamic "contact" {
    for_each = var.contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = local.secrets_by_name

  name         = each.value.name
  key_vault_id = azurerm_key_vault.key_vault.id

  value            = each.value.value != null ? sensitive(each.value.value) : null
  value_wo         = each.value.value_wo != null ? sensitive(each.value.value_wo) : null
  value_wo_version = each.value.value_wo_version
  content_type     = each.value.content_type
  not_before_date  = each.value.not_before_date
  expiration_date  = each.value.expiration_date

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.access_policies]
}


resource "azurerm_key_vault_key" "keys" {
  for_each = {
    for key in var.keys : key.name => key
  }

  name         = each.value.name
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = each.value.key_type
  key_opts     = each.value.key_opts

  key_size        = each.value.key_size
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  dynamic "rotation_policy" {
    for_each = each.value.rotation_policy == null ? [] : [each.value.rotation_policy]
    content {
      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry

      dynamic "automatic" {
        for_each = rotation_policy.value.automatic == null ? [] : [rotation_policy.value.automatic]
        content {
          time_after_creation = automatic.value.time_after_creation
          time_before_expiry  = automatic.value.time_before_expiry
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.access_policies]
}

resource "azurerm_key_vault_certificate" "certificates" {
  for_each = local.certificates_by_name

  name         = each.value.name
  key_vault_id = azurerm_key_vault.key_vault.id

  dynamic "certificate" {
    for_each = each.value.certificate == null ? [] : [each.value.certificate]
    content {
      contents = certificate.value.contents
      password = certificate.value.password
    }
  }

  dynamic "certificate_policy" {
    for_each = each.value.certificate_policy == null ? [] : [each.value.certificate_policy]
    content {
      issuer_parameters {
        name = certificate_policy.value.issuer_parameters.name
      }

      key_properties {
        exportable = certificate_policy.value.key_properties.exportable
        key_type   = certificate_policy.value.key_properties.key_type
        key_size   = certificate_policy.value.key_properties.key_size
        curve      = certificate_policy.value.key_properties.curve
        reuse_key  = certificate_policy.value.key_properties.reuse_key
      }

      secret_properties {
        content_type = certificate_policy.value.secret_properties.content_type
      }

      dynamic "x509_certificate_properties" {
        for_each = certificate_policy.value.x509_certificate_properties == null ? [] : [certificate_policy.value.x509_certificate_properties]
        content {
          subject            = x509_certificate_properties.value.subject
          validity_in_months = x509_certificate_properties.value.validity_in_months
          key_usage          = x509_certificate_properties.value.key_usage
          extended_key_usage = x509_certificate_properties.value.extended_key_usage

          dynamic "subject_alternative_names" {
            for_each = x509_certificate_properties.value.subject_alternative_names == null ? [] : [x509_certificate_properties.value.subject_alternative_names]
            content {
              dns_names = subject_alternative_names.value.dns_names
              emails    = subject_alternative_names.value.emails
              upns      = subject_alternative_names.value.upns
            }
          }
        }
      }

      dynamic "lifetime_action" {
        for_each = try(certificate_policy.value.lifetime_actions, [])
        content {
          action {
            action_type = lifetime_action.value.action_type
          }

          trigger {
            days_before_expiry  = lifetime_action.value.days_before_expiry
            lifetime_percentage = lifetime_action.value.lifetime_percentage
          }
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.access_policies]
}

resource "azurerm_key_vault_certificate_issuer" "issuers" {
  for_each = local.certificate_issuers_by_name

  name          = each.value.name
  key_vault_id  = azurerm_key_vault.key_vault.id
  provider_name = each.value.provider_name

  account_id = each.value.account_id
  password   = each.value.password != null ? sensitive(each.value.password) : null
  org_id     = each.value.org_id

  dynamic "admin" {
    for_each = try(each.value.administrators, [])
    content {
      email_address = admin.value.email_address
      first_name    = admin.value.first_name
      last_name     = admin.value.last_name
      phone         = admin.value.phone
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [azurerm_key_vault_access_policy.access_policies]
}

resource "azurerm_key_vault_access_policy" "access_policies" {
  for_each = {
    for policy in var.access_policies : policy.name => policy
  }

  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = coalesce(each.value.tenant_id, var.tenant_id)
  object_id    = each.value.object_id

  application_id          = each.value.application_id
  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  storage_permissions     = each.value.storage_permissions

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_key_vault_managed_storage_account" "managed_storage_accounts" {
  for_each = local.managed_storage_accounts_by_name

  name                = each.value.name
  key_vault_id        = azurerm_key_vault.key_vault.id
  storage_account_id  = each.value.storage_account_id
  storage_account_key = sensitive(each.value.storage_account_key)

  regenerate_key_automatically = each.value.regenerate_key_automatically
  regeneration_period          = each.value.regeneration_period

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [azurerm_key_vault_access_policy.access_policies]
}

resource "azurerm_key_vault_managed_storage_account_sas_token_definition" "sas_definitions" {
  for_each = local.managed_storage_sas_definitions_by_name

  name                       = each.value.name
  managed_storage_account_id = each.value.managed_storage_account_id != null ? each.value.managed_storage_account_id : azurerm_key_vault_managed_storage_account.managed_storage_accounts[each.value.managed_storage_account_name].id
  sas_template_uri           = each.value.sas_template_uri
  sas_type                   = each.value.sas_type
  validity_period            = each.value.validity_period

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  depends_on = [
    azurerm_key_vault_access_policy.access_policies,
    azurerm_key_vault_managed_storage_account.managed_storage_accounts
  ]
}
