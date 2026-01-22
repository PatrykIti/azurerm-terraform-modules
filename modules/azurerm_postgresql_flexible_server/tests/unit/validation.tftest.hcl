# Placeholder validation test for PostgreSQL Flexible Server

variables {
  name                = "example-postgresql_flexible_server"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "validation_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update validation tests for PostgreSQL Flexible Server."
  }
}
