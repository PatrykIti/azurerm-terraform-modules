# Negative test case - should fail validation

module "kubernetes_secrets" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  strategy  = "manual"
  namespace = "app"
  name      = "INVALID-NAME-WITH-UPPERCASE"

  manual = {
    secrets = [
      {
        name                  = "db-password"
        kubernetes_secret_key = "DB_PASSWORD"
        value                 = "mock-secret"
      }
    ]
  }
}
