locals {
  access_policies_by_name = {
    for policy in var.access_policies : policy.name => policy
  }

  keys_by_name = {
    for key in var.keys : key.name => key
  }

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
