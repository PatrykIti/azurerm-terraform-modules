# Negative test case - should fail validation

module "kubernetes_secrets" {
  source = "../../../"

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
