# Import

## Key Vault

```hcl
import {
  to = module.key_vault.azurerm_key_vault.key_vault
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/example-kv"
}
```

## Diagnostic Setting

```hcl
import {
  to = module.key_vault.azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/example-kv|diag"
}
```

## Sub-resources

Examples (replace IDs with your real resources):

```hcl
import {
  to = module.key_vault.azurerm_key_vault_access_policy.access_policies["current-user"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/example-kv/objectId/00000000-0000-0000-0000-000000000000"
}

import {
  to = module.key_vault.azurerm_key_vault_key.keys["app-key"]
  id = "https://example-kv.vault.azure.net/keys/app-key/00000000000000000000000000000000"
}

import {
  to = module.key_vault.azurerm_key_vault_secret.secrets["app-secret"]
  id = "https://example-kv.vault.azure.net/secrets/app-secret/00000000000000000000000000000000"
}

import {
  to = module.key_vault.azurerm_key_vault_certificate.certificates["app-cert"]
  id = "https://example-kv.vault.azure.net/certificates/app-cert/00000000000000000000000000000000"
}

import {
  to = module.key_vault.azurerm_key_vault_certificate_issuer.issuers["self"]
  id = "https://example-kv.vault.azure.net/certificates/issuers/self"
}

import {
  to = module.key_vault.azurerm_key_vault_managed_storage_account.managed_storage_accounts["appstorage"]
  id = "https://example-kv.vault.azure.net/storage/appstorage"
}

import {
  to = module.key_vault.azurerm_key_vault_managed_storage_account_sas_token_definition.sas_definitions["appstorage-sas"]
  id = "https://example-kv.vault.azure.net/storage/appstorage/sas/appstorage-sas"
}
```

Other sub-resources can be imported using their Azure resource IDs. Use the Azure
portal or CLI to retrieve exact IDs, then map them to the corresponding module
instances.
