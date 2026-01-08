# Complete Azure DevOps User Entitlement Fixture

This fixture demonstrates a complete user entitlement configuration, including origin selectors.

## Features

- Assigns an entitlement using `origin` + `origin_id`
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
