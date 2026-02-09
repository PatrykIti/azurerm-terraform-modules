resource "azurerm_redis_linked_server" "redis_linked_server" {
  for_each = var.sku_name == "Premium" ? {
    for ls in var.linked_servers : ls.name => ls
  } : {}

  resource_group_name         = azurerm_redis_cache.redis_cache.resource_group_name
  target_redis_cache_name     = azurerm_redis_cache.redis_cache.name
  linked_redis_cache_id       = each.value.linked_redis_cache_id
  linked_redis_cache_location = each.value.linked_redis_cache_location
  server_role                 = each.value.server_role
}
