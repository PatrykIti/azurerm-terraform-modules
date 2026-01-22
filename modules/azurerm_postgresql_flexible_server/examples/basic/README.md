# Basic PostgreSQL Flexible Server Example

This example demonstrates a minimal PostgreSQL Flexible Server deployment using
password authentication and public network access.

## Features

- Creates a PostgreSQL Flexible Server with a standard SKU and version.
- Uses a generated administrator password.
- Creates a dedicated resource group.
- Uses secure defaults provided by the module.

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
