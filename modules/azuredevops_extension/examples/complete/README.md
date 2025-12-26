# Complete Azure DevOps Extension Example

This example demonstrates installing multiple Azure DevOps Marketplace extensions with version pinning.

## Features

- Multiple extensions installed at the organization level
- Optional version pins per extension

## Key Configuration

Update the `extensions` list with your Marketplace publisher and extension IDs.
The module uses `for_each` to install each extension.

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
