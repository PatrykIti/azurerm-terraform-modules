# Secure Azure DevOps Identity Example

This example demonstrates a security-focused identity configuration with explicit memberships and minimal entitlements.

## Features

- Creates restricted groups for security and operations
- Applies explicit group-to-group membership with overwrite mode
- Uses stakeholder entitlements for least-privilege access

## Key Configuration

Use this pattern to keep access tightly controlled and reviewable.

## Security Considerations

- All public access is disabled by default
- Network access is restricted to specific IP ranges
- All data is encrypted at rest and in transit
- Audit logging captures all access and modifications

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
<!-- END_TF_DOCS -->
