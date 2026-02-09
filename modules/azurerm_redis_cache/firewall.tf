resource "azurerm_redis_firewall_rule" "redis_firewall_rule" {
  for_each = var.public_network_access_enabled ? {
    for rule in var.firewall_rules : rule.name => rule
  } : {}

  name                = each.value.name
  redis_cache_name    = azurerm_redis_cache.redis_cache.name
  resource_group_name = azurerm_redis_cache.redis_cache.resource_group_name
  start_ip            = each.value.start_ip_address
  end_ip              = each.value.end_ip_address
}
