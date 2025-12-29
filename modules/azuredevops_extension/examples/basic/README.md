# Basic Azure DevOps Extension Example

This example demonstrates installing a single Azure DevOps Marketplace extension.

## Features

- Installs one extension at the organization level
- Optional version pinning

## Key Configuration

Provide the Marketplace `publisher_id` and `extension_id` (and optionally `extension_version`).

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
