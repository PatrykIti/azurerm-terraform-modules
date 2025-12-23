# Negative test case - should fail validation

module "kubernetes_secrets" {
  source = "../../../"

  strategy  = "manual"
  namespace = "app"
  name      = "INVALID-NAME-WITH-UPPERCASE"

  manual = {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
    secrets = [
      {
        name                  = "db-password"
        key_vault_secret_name = "db-password"
        kubernetes_secret_key = "DB_PASSWORD"
      }
    ]
  }
}
