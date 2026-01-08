# Secure Azure DevOps User Entitlement Fixture

This fixture demonstrates a minimal entitlements setup using a stakeholder license.

## Features

- Assigns a stakeholder entitlement using `principal_name`
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
