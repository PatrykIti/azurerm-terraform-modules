# Secure Azure DevOps Extension Example

This example demonstrates installing only approved Azure DevOps Marketplace extensions using an allowlist.

## Features

- Explicit allowlist of extensions
- Optional version pinning for approved extensions

## Key Configuration

Maintain `approved_extensions` as your vetted list of Marketplace extensions.
The module uses `for_each` to install only approved entries.

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
