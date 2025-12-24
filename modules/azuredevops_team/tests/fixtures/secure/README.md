# Secure Azure DevOps Team Example

This fixture demonstrates a security-focused team configuration for tests.

## Features

- Creates a security team with strict admin assignment
- Uses overwrite mode for administrators

## Key Configuration

Use this fixture to validate strict admin assignment behavior.

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
