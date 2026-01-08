# Negative Azure DevOps User Entitlement Fixture

This fixture is intentionally invalid and should fail validation.

## Scenario

- Sets both `principal_name` and `origin` + `origin_id`, which violates the selector rules.

## Usage

```bash
terraform init
terraform plan
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
