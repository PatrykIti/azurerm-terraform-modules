# Import

## Cognitive Account

```hcl
import {
  to = azurerm_cognitive_account.cognitive_account
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.CognitiveServices/accounts/example-account"
}
```

## OpenAI Deployment

```hcl
import {
  to = azurerm_cognitive_deployment.cognitive_deployment["deployment-name"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.CognitiveServices/accounts/example-account/deployments/deployment-name"
}
```

## RAI Policy

```hcl
import {
  to = azurerm_cognitive_account_rai_policy.rai_policy["policy-name"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.CognitiveServices/accounts/example-account/raiPolicies/policy-name"
}
```

## RAI Blocklist

```hcl
import {
  to = azurerm_cognitive_account_rai_blocklist.rai_blocklist["blocklist-name"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.CognitiveServices/accounts/example-account/raiBlocklists/blocklist-name"
}
```

## Customer Managed Key (Separate Resource)

```hcl
import {
  to = azurerm_cognitive_account_customer_managed_key.customer_managed_key[0]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.CognitiveServices/accounts/example-account"
}
```

## Diagnostic Setting

```hcl
import {
  to = azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.CognitiveServices/accounts/example-account|diag"
}
```
