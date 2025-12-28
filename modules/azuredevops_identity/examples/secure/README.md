# Secure Azure DevOps Identity Example

This example demonstrates a security-focused identity configuration with explicit memberships and minimal entitlements.

## Features

- Creates a restricted Azure DevOps group
- Adds explicit group membership with overwrite mode
- Uses stakeholder entitlements for least-privilege access (optional)

## Key Configuration

Use this pattern to keep access tightly controlled and reviewable.

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
