resource "azurerm_redis_linked_server" "linked_server" {
  for_each = local.sku_is_premium ? {
    for ls in var.linked_servers : ls.name => ls
  } : {}

  resource_group_name         = azurerm_redis_cache.redis_cache.resource_group_name
  target_redis_cache_name     = azurerm_redis_cache.redis_cache.name
  linked_redis_cache_id       = each.value.linked_redis_cache_id
  linked_redis_cache_location = each.value.linked_redis_cache_location
  server_role                 = each.value.server_role
}
