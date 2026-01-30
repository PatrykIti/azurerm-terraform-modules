# Terraform Azure Key Vault Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages an Azure Key Vault and optional data-plane resources (access policies, keys, secrets,
certificates, certificate issuers, managed storage accounts, SAS definitions), plus diagnostic settings.

## Usage

```hcl
data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "path/to/azurerm_key_vault"

  name                = "example-kv"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled   = false
  public_network_access_enabled = true

  access_policies = [
    {
      name        = "current-user"
      object_id   = data.azurerm_client_config.current.object_id
      tenant_id   = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "Set", "List", "Delete"]
    }
  ]

  secrets = [
    {
      name  = "app-secret"
      value = "example-secret"
    }
  ]

  tags = {
    Environment = "Development"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Access Policies](examples/access-policies) - This example shows Key Vault access policies with multiple principals.
- [Basic](examples/basic) - This example deploys a Key Vault with public access enabled and a single secret
- [Certificate Issuer](examples/certificate-issuer) - This example registers a certificate issuer in Key Vault.
- [Certificates](examples/certificates) - This example provisions a self-signed certificate policy.
- [Complete](examples/complete) - This example enables network ACLs, keys, secrets, certificates, and diagnostic settings.
- [Diagnostic Settings](examples/diagnostic-settings) - This example configures diagnostic settings for Key Vault.
- [Keys](examples/keys) - This example provisions RSA and EC keys using access policies.
- [Managed Storage Account](examples/managed-storage-account) - This example registers a managed storage account and SAS definition in Key Vault.
- [Rbac](examples/rbac) - This example enables RBAC authorization and assigns the Key Vault Secrets Officer role
- [Rotation Policy](examples/rotation-policy) - This example configures a key rotation policy.
- [Secrets](examples/secrets) - This example provisions standard and write-only secrets.
- [Secure](examples/secure) - This example disables public access, enables RBAC, and connects a private endpoint
<!-- END_EXAMPLES -->

## Security Considerations

- Prefer RBAC (`rbac_authorization_enabled = true`) and manage role assignments externally.
- Disable public access and use private endpoints for production workloads.
- Keep purge protection enabled and use a retention window aligned with governance.
- Treat secret, key, and storage account inputs as sensitive.

See [SECURITY.md](SECURITY.md) for detailed guidance.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.access_policies](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_certificate.certificates](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_certificate) | resource |
| [azurerm_key_vault_certificate_issuer.issuers](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_certificate_issuer) | resource |
| [azurerm_key_vault_key.keys](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_managed_storage_account.managed_storage_accounts](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_managed_storage_account) | resource |
| [azurerm_key_vault_managed_storage_account_sas_token_definition.sas_definitions](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_managed_storage_account_sas_token_definition) | resource |
| [azurerm_key_vault_secret.secrets](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_categories.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/monitor_diagnostic_categories) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Access policies applied when RBAC authorization is disabled.<br/><br/>Each entry must have a unique name. | <pre>list(object({<br/>    name                    = string<br/>    tenant_id               = optional(string)<br/>    object_id               = string<br/>    application_id          = optional(string)<br/>    certificate_permissions = optional(list(string), [])<br/>    key_permissions         = optional(list(string), [])<br/>    secret_permissions      = optional(list(string), [])<br/>    storage_permissions     = optional(list(string), [])<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_certificate_issuers"></a> [certificate\_issuers](#input\_certificate\_issuers) | Certificate issuers registered in the Key Vault. Each entry must have a unique name. | <pre>list(object({<br/>    name          = string<br/>    provider_name = string<br/>    account_id    = optional(string)<br/>    password      = optional(string)<br/>    org_id        = optional(string)<br/>    administrators = optional(list(object({<br/>      email_address = string<br/>      first_name    = optional(string)<br/>      last_name     = optional(string)<br/>      phone         = optional(string)<br/>    })), [])<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_certificates"></a> [certificates](#input\_certificates) | Key Vault certificates to create. Each entry must have a unique name. | <pre>list(object({<br/>    name = string<br/>    certificate = optional(object({<br/>      contents = string<br/>      password = optional(string)<br/>    }))<br/>    certificate_policy = optional(object({<br/>      issuer_parameters = object({<br/>        name = string<br/>      })<br/>      key_properties = object({<br/>        exportable = bool<br/>        key_type   = string<br/>        key_size   = optional(number)<br/>        curve      = optional(string)<br/>        reuse_key  = bool<br/>      })<br/>      secret_properties = object({<br/>        content_type = string<br/>      })<br/>      x509_certificate_properties = optional(object({<br/>        subject            = string<br/>        validity_in_months = number<br/>        key_usage          = set(string)<br/>        extended_key_usage = optional(list(string))<br/>        subject_alternative_names = optional(object({<br/>          dns_names = optional(set(string))<br/>          emails    = optional(set(string))<br/>          upns      = optional(set(string))<br/>        }))<br/>      }))<br/>      lifetime_actions = optional(list(object({<br/>        action_type         = string<br/>        days_before_expiry  = optional(number)<br/>        lifetime_percentage = optional(number)<br/>      })), [])<br/>    }))<br/>    tags = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_contacts"></a> [contacts](#input\_contacts) | Key Vault contacts for certificate notifications. | <pre>list(object({<br/>    email = string<br/>    name  = optional(string)<br/>    phone = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the Key Vault.<br/><br/>areas: optional shorthand mapping to log/metric categories (all, logs, metrics, audit). | <pre>list(object({<br/>    name                           = string<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    partner_solution_id            = optional(string)<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_category_groups            = optional(list(string))<br/>    areas                          = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether Azure Disk Encryption is permitted to retrieve secrets from the Key Vault and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault. | `bool` | `false` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | Key Vault keys to create. Each entry must have a unique name. | <pre>list(object({<br/>    name            = string<br/>    key_type        = string<br/>    key_opts        = list(string)<br/>    key_size        = optional(number)<br/>    curve           = optional(string)<br/>    not_before_date = optional(string)<br/>    expiration_date = optional(string)<br/>    tags            = optional(map(string), {})<br/>    rotation_policy = optional(object({<br/>      expire_after         = optional(string)<br/>      notify_before_expiry = optional(string)<br/>      automatic = optional(object({<br/>        time_after_creation = optional(string)<br/>        time_before_expiry  = optional(string)<br/>      }))<br/>    }))<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Key Vault should exist. | `string` | n/a | yes |
| <a name="input_managed_storage_accounts"></a> [managed\_storage\_accounts](#input\_managed\_storage\_accounts) | Managed storage accounts registered in the Key Vault. Each entry must have a unique name. | <pre>list(object({<br/>    name                         = string<br/>    storage_account_id           = string<br/>    storage_account_key          = string<br/>    regenerate_key_automatically = optional(bool, false)<br/>    regeneration_period          = optional(string)<br/>    tags                         = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_managed_storage_sas_definitions"></a> [managed\_storage\_sas\_definitions](#input\_managed\_storage\_sas\_definitions) | Managed storage SAS token definitions. Each entry must have a unique name. | <pre>list(object({<br/>    name                         = string<br/>    managed_storage_account_name = optional(string)<br/>    managed_storage_account_id   = optional(string)<br/>    sas_template_uri             = string<br/>    sas_type                     = string<br/>    validity_period              = string<br/>    tags                         = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Key Vault. Must be globally unique. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACLs for the Key Vault.<br/><br/>bypass: Which traffic can bypass the network rules (AzureServices or None).<br/>default\_action: Default action when no rules match (Allow or Deny).<br/>ip\_rules: List of IPv4 addresses or CIDR ranges.<br/>virtual\_network\_subnet\_ids: List of subnet IDs to allow. | <pre>object({<br/>    bypass                     = optional(string, "AzureServices")<br/>    default_action             = optional(string, "Deny")<br/>    ip_rules                   = optional(list(string), [])<br/>    virtual_network_subnet_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is allowed for this Key Vault. | `bool` | `false` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether purge protection is enabled for this Key Vault. | `bool` | `true` | no |
| <a name="input_rbac_authorization_enabled"></a> [rbac\_authorization\_enabled](#input\_rbac\_authorization\_enabled) | Whether RBAC authorization is enabled for Key Vault data-plane operations. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Key Vault. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Key Vault secrets to create. Each entry must have a unique name. | <pre>list(object({<br/>    name             = string<br/>    value            = optional(string)<br/>    value_wo         = optional(string)<br/>    value_wo_version = optional(number)<br/>    content_type     = optional(string)<br/>    not_before_date  = optional(string)<br/>    expiration_date  = optional(string)<br/>    tags             = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The Key Vault SKU. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that items should be retained for once soft-deleted. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Key Vault and related resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Entra ID tenant ID used for Key Vault access policies and RBAC. | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeouts for Key Vault operations. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_policies"></a> [access\_policies](#output\_access\_policies) | Access policies managed by the module. |
| <a name="output_certificate_issuers"></a> [certificate\_issuers](#output\_certificate\_issuers) | Key Vault certificate issuers managed by the module. |
| <a name="output_certificates"></a> [certificates](#output\_certificates) | Key Vault certificates managed by the module. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Key Vault. |
| <a name="output_keys"></a> [keys](#output\_keys) | Key Vault keys managed by the module. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Key Vault is deployed. |
| <a name="output_managed_storage_accounts"></a> [managed\_storage\_accounts](#output\_managed\_storage\_accounts) | Managed storage accounts registered in the Key Vault. |
| <a name="output_managed_storage_sas_definitions"></a> [managed\_storage\_sas\_definitions](#output\_managed\_storage\_sas\_definitions) | Managed storage SAS token definitions. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Key Vault. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name containing the Key Vault. |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Key Vault secrets managed by the module (metadata only). |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU of the Key Vault. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Key Vault. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID associated with the Key Vault. |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | The URI of the Key Vault. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
