# Secure Azure DevOps Identity Example

This fixture demonstrates security-focused identity configuration for tests.

## Features

- Creates restricted groups
- Applies explicit group membership with overwrite mode

## Key Configuration

Use this fixture to validate overwrite membership behavior.

## Security Considerations

- All public access is disabled by default
- Network access is restricted to specific IP ranges
- All data is encrypted at rest and in transit
- Audit logging captures all access and modifications

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
