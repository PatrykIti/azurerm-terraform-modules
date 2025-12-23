# Basic Azure DevOps Identity Example

This fixture demonstrates a minimal Azure DevOps identity configuration for tests.

## Features

- Creates a single Azure DevOps group
- Uses a randomized suffix to avoid name collisions

## Key Configuration

This fixture keeps the configuration small to reduce test runtime.

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
