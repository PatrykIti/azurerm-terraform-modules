# Basic Application Insights Workbook Example

This example demonstrates a minimal Application Insights Workbook configuration.

## Features

- Creates a workbook with required inputs only
- Uses `jsonencode()` for `data_json`
- Creates a dedicated resource group

## Key Configuration

This example focuses on:
- Required workbook inputs (`name`, `display_name`, `data_json`)
- A minimal `data_json` payload

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
