# Basic Azure DevOps User Entitlement Fixture

This fixture demonstrates a minimal Azure DevOps user entitlement configuration for tests.

## Features

- Assigns a single entitlement using `principal_name`
- Uses a deterministic key to avoid address churn

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
