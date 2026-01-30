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

  lifecycle {
    precondition {
      condition     = each.value.certificate != null || each.value.certificate_policy != null
      error_message = "Certificates require either certificate or certificate_policy."
    }

    precondition {
      condition     = each.value.certificate_policy == null || !contains(["RSA", "RSA-HSM"], each.value.certificate_policy.key_properties.key_type) || (each.value.certificate_policy.key_properties.key_size != null && contains([2048, 3072, 4096], each.value.certificate_policy.key_properties.key_size))
      error_message = "RSA and RSA-HSM certificate key types require key_size of 2048, 3072, or 4096."
    }

    precondition {
      condition     = each.value.certificate_policy == null || !contains(["EC", "EC-HSM"], each.value.certificate_policy.key_properties.key_type) || (each.value.certificate_policy.key_properties.curve != null && contains(["P-256", "P-384", "P-521", "P-256K"], each.value.certificate_policy.key_properties.curve))
      error_message = "EC and EC-HSM certificate key types require curve set to P-256, P-384, P-521, or P-256K."
    }
  }
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
