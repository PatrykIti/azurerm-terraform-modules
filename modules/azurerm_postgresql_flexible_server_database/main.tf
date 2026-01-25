resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = var.database.name
  server_id = var.server.id

  charset   = var.database.charset
  collation = var.database.collation

}
