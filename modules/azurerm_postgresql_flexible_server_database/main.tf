resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = var.name
  server_id = var.server_id

  charset   = var.charset
  collation = var.collation

}
