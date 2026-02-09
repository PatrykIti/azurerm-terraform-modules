# Import

## Redis Cache

```hcl
import {
  to = azurerm_redis_cache.redis_cache
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Cache/Redis/example-redis"
}
```

## Firewall Rule

```hcl
import {
  to = azurerm_redis_firewall_rule.redis_firewall_rule["office"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Cache/Redis/example-redis/firewallRules/office"
}
```

## Linked Server

```hcl
import {
  to = azurerm_redis_linked_server.redis_linked_server["geo-secondary"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Cache/Redis/example-redis/linkedServers/geo-secondary"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Cache/Redis/example-redis|diag"
}
```

## Patch Schedule

Patch schedules are configured inline on `azurerm_redis_cache` and do not have a
separate importable resource in AzureRM 4.57.0.
