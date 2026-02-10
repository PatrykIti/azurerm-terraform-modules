# Complete Application Insights Workbook Example

This example demonstrates a full Application Insights Workbook configuration.

## Features

- Workbook with category, description, source ID, and storage container ID
- User-assigned identity
- Log Analytics workspace as the source resource
- Storage account + blob container as workbook storage target
- Role assignments required for workbook identity access

## Key Configuration

This example showcases:
- `source_id` wiring to a Log Analytics workspace
- `storage_container_id` wiring to a Storage container resource ID
- User-assigned managed identity configuration
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
