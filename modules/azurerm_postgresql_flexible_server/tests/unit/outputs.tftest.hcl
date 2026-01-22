# Placeholder outputs test for PostgreSQL Flexible Server

variables {
  name                = "example-postgresql_flexible_server"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = true
    error_message = "Update outputs tests for PostgreSQL Flexible Server."
  }
}
