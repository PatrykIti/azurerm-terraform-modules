# Terraform Azure Application Insights Workbook Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Application Insights Workbooks.

## Usage

```hcl
module "application_insights_workbook" {
  source = "path/to/azurerm_application_insights_workbook"

  name                = "2f9c2f59-3f8b-4d8b-8a2c-1d9b3b2a0f01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "Workbook - Example"
  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "text-1"
        content = {
          json = "## Example Workbook"
        }
      }
    ]
    fallbackResourceIds = []
  })

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - Minimal workbook with required inputs only.
- [Complete](examples/complete) - Workbook with category, description, source ID, identity, and tags.
- [Secure](examples/secure) - Workbook with user-assigned identity and RBAC to a source resource.
- [Workbook Identity](examples/workbook-identity) - Identity-focused workbook example.
- [Workbook Source ID](examples/workbook-source-id) - Workbook referencing a source resource ID.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights_workbook.application_insights_workbook](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_workbook) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the workbook. Must be a UUID (GUID). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource_group_name](#input\_resource\_group\_name) | The name of the resource group in which to create the workbook. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the workbook should exist. | `string` | n/a | yes |
| <a name="input_display_name"></a> [display_name](#input\_display\_name) | The display name of the workbook. | `string` | n/a | yes |
| <a name="input_data_json"></a> [data_json](#input\_data\_json) | The workbook content as a JSON string. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Optional description of the workbook. | `string` | `null` | no |
| <a name="input_category"></a> [category](#input\_category) | Optional workbook category (for example: workbook, tsg, usage, Azure Monitor). | `string` | `null` | no |
| <a name="input_source_id"></a> [source_id](#input\_source\_id) | Optional source resource ID used by the workbook. | `string` | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the workbook. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for the workbook. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Application Insights Workbook. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity information for the workbook. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Application Insights Workbook. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Application Insights Workbook. |
| <a name="output_resource_group_name"></a> [resource_group_name](#output\_resource\_group\_name) | The resource group name of the Application Insights Workbook. |
<!-- END_TF_DOCS -->

## Security Considerations

- Treat `data_json` as configuration code: it can embed queries and resource references.
- Use managed identities and least-privilege RBAC on `source_id` targets.
- Keep `source_id` scoped to the intended subscription/resource group when possible.

## Module Documentation

- [docs/README.md](docs/README.md) - Extended documentation and scope notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing resources

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
