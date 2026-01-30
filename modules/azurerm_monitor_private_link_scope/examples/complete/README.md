# Complete Azure Monitor Private Link Scope Example

This example demonstrates a complete Azure Monitor Private Link Scope (AMPLS) configuration with scoped services.

## Features

- Creates a resource group
- Creates Log Analytics workspace, Application Insights, and DCE
- Links all three resources as scoped services in AMPLS

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
