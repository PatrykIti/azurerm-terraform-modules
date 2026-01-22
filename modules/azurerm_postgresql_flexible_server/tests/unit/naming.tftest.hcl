# Placeholder naming test for PostgreSQL Flexible Server

variables {
  name                = "example-postgresql_flexible_server"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "naming_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update naming tests for PostgreSQL Flexible Server."
  }
}
