# Importing Event Hubs

Use this guide to import existing Event Hubs and related sub-resources into the
module state using Terraform import blocks.

## Minimal Module Configuration

```hcl
module "eventhub" {
  source = "github.com/<org>/<repo>//modules/azurerm_eventhub?ref=EHvX.Y.Z"

  name            = "example-eh"
  namespace_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns"
  partition_count = 2
}
```

## Import Blocks

```hcl
# Event Hub
import {
  to = module.eventhub.azurerm_eventhub.eventhub
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns/eventhubs/example-eh"
}

# Event Hub authorization rule
import {
  to = module.eventhub.azurerm_eventhub_authorization_rule.authorization_rules["send-only"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns/eventhubs/example-eh/authorizationRules/send-only"
}

# Event Hub consumer group
import {
  to = module.eventhub.azurerm_eventhub_consumer_group.consumer_groups["cg-ingest"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.EventHub/namespaces/example-ehns/eventhubs/example-eh/consumerGroups/cg-ingest"
}
```
