# Event Hub Security Guidance

## Security posture

- **Namespace isolation**: Use private endpoints and namespace-level firewall rules for network isolation.
- **Authorization rules**: Grant only the minimum required permissions (listen/send/manage).
- **Capture**: Store captured data in a private storage account with restricted access.

## Secure configuration example

```hcl
module "eventhub" {
  source = ".../modules/azurerm_eventhub"

  name            = "eh-secure"
  namespace_id    = azurerm_eventhub_namespace.example.id
  partition_count = 2

  authorization_rules = [
    {
      name = "send-only"
      send = true
    }
  ]
}
```

## Checklist

- [ ] Namespace access restricted (network rules/private endpoints).
- [ ] Authorization rules follow least privilege.
- [ ] Capture destinations secured and monitored.

## Common pitfalls

- **Over-permissioned rules**: Avoid `manage = true` unless required.
- **Public capture storage**: Capture data should reside in private storage.
