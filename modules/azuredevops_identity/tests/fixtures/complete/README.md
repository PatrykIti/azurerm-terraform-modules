# Complete Azure DevOps Identity Fixture

This fixture demonstrates a primary group with membership and optional entitlements for test coverage.

## Features

- Creates a module-managed Azure DevOps group
- Creates a secondary group used as a membership source
- Adds group-to-group membership with a stable key
- Supports optional user entitlements

## Key Configuration

Use this fixture to validate membership handling and entitlement outputs in tests.

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
