# Importing Event Hub Namespaces

Use this guide to import existing Event Hub Namespaces and related sub-resources
into the module state using Terraform import blocks.

## Minimal Module Configuration

```hcl
module "eventhub_namespace" {
  source = "github.com/<org>/<repo>//modules/azurerm_eventhub_namespace?ref=EHNSvX.Y.Z"

  name                = "example-ehns"
  resource_group_name = "rg-example"
  location            = "westeurope"
  sku                 = "Standard"
}
```

## Import Blocks

```hcl
# Namespace
import {
  to = module.eventhub_namespace.azurerm_eventhub_namespace.namespace
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns"
}

# Namespace authorization rule
import {
  to = module.eventhub_namespace.azurerm_eventhub_namespace_authorization_rule.authorization_rules["send-only"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns/authorizationRules/send-only"
}

# Disaster recovery config
import {
  to = module.eventhub_namespace.azurerm_eventhub_namespace_disaster_recovery_config.disaster_recovery["ehns-dr"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns/disasterRecoveryConfigs/ehns-dr"
}

# Customer managed key association
import {
  to = module.eventhub_namespace.azurerm_eventhub_namespace_customer_managed_key.customer_managed_key
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns"
}

# Diagnostic settings
import {
  to = module.eventhub_namespace.azurerm_monitor_diagnostic_setting.diagnostic_settings["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns|diag"
}
```

## Notes

- Network rule set is managed inline in `azurerm_eventhub_namespace` and does not
  require a separate import.
- Ensure `customer_managed_key` identity settings match the existing namespace.
