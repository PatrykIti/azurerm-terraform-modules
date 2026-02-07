# azurerm_application_insights_workbook Module Security

## Overview

This module provisions an Application Insights Workbook and focuses on secure
defaults. The most sensitive inputs are `data_json` (workbook content) and
`source_id` (resource reference). These control what data the workbook can
render and which resources it can reference.

## Security Features

### Managed Identity

- Supports `UserAssigned` identity.
- Use least-privilege RBAC on the resource referenced by `source_id`.
- Prefer `UserAssigned` when you need tighter lifecycle control.

### Data Configuration

- `data_json` is treated as configuration code; validate its content and avoid
  embedding secrets or sensitive values.
- When referencing external resources, use explicit `source_id` values and keep
  them scoped to the intended subscription/resource group.

## Secure Example

```hcl
resource "azurerm_user_assigned_identity" "workbook" {
  name                = "uai-aiwb-secure"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_role_assignment" "workbook_reader" {
  scope                = azurerm_log_analytics_workspace.example.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.workbook.principal_id
}

module "application_insights_workbook" {
  source = "../.."

  name                = "c0b9d8e6-7a21-4f0b-9d42-6c9b1e4f0b03"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Secure Workbook"
  data_json           = jsonencode({ version = "Notebook/1.0", items = [] })
  source_id           = azurerm_log_analytics_workspace.example.id

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.workbook.id]
  }
}
```

## Security Hardening Checklist

- [ ] Validate `data_json` content and avoid secrets in workbook queries.
- [ ] Use managed identities and least-privilege RBAC on `source_id` targets.
- [ ] Prefer `UserAssigned` identity for long-lived access controls.
- [ ] Keep `source_id` scoped to the minimum necessary resources.

## Common Mistakes

1. **Omitting RBAC for source resources**
   ```hcl
   # ❌ AVOID: identity configured without access to source_id
   source_id = azurerm_log_analytics_workspace.example.id
   ```

2. **Embedding sensitive values in data_json**
   ```hcl
   # ❌ AVOID
   data_json = jsonencode({ query = "print secret=..." })
   ```

## Additional Resources

- Azure Workbooks documentation
- Azure RBAC best practices

---

**Last Updated**: 2026-01-30
