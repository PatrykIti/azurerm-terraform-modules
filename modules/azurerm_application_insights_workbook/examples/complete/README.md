# Complete Application Insights Workbook Example

This example demonstrates a full Application Insights Workbook configuration.

## Features

- Workbook with category, description, and source ID
- System-assigned identity
- Log Analytics workspace as the source resource

## Key Configuration

This example showcases:
- `source_id` wiring to a Log Analytics workspace
- Managed identity configuration
- Tags and metadata fields

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
