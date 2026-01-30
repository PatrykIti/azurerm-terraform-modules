# Importing Application Insights Workbooks

Use this guide to import an existing Application Insights Workbook into module
state.

## Prerequisites

- Terraform >= 1.12.2
- Access to the target subscription and resource group
- Workbook name (UUID)

## Minimal Module Configuration

```hcl
module "application_insights_workbook" {
  source = "github.com/<org>/<repo>//modules/azurerm_application_insights_workbook?ref=AIWBv1.0.0"

  name                = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
  resource_group_name = "rg-example"
  location            = "westeurope"
  display_name        = "Imported Workbook"
  data_json           = jsonencode({ version = "Notebook/1.0", items = [] })
}
```

## Import Block

```hcl
import {
  to = module.application_insights_workbook.azurerm_application_insights_workbook.application_insights_workbook
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Insights/workbooks/2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
}
```

## Verification

After running `terraform plan`, verify that:

- No changes are proposed for the imported workbook.
- `display_name` and `data_json` match the workbook definition.

## Common Errors

- **Invalid ID format**: ensure the resource ID ends with `/workbooks/<UUID>`.
- **UUID mismatch**: the module `name` must match the workbook UUID in the ID.
