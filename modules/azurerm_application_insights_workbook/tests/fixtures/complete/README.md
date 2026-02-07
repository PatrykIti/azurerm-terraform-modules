# Complete Application Insights Workbook Example

This fixture demonstrates a full Application Insights Workbook configuration.

## Features

- Workbook with category, description, source ID, and storage container ID
- System-assigned identity
- Log Analytics workspace as the source resource
- Storage account + blob container wired through `storage_container_id`

## Key Configuration

This fixture exercises identity, source linkage, and storage container wiring for integration testing.

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
