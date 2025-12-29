# Complete Azure DevOps Project Permissions Example

This example demonstrates a full permissions map with mixed scopes and optional principal override.

## Features

- Assigns permissions at both project and collection scopes.
- Demonstrates `principal` override for a known descriptor.
- Shows multiple permission entries in a single module call.

## Prerequisites

- An existing Azure DevOps project ID (`project_id`).
- Group names or descriptors required by the fixture inputs.

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
