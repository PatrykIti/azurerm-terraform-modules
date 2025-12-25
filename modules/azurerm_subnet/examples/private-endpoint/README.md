# Private Endpoint Subnet Example

This example configures a subnet for private endpoints and creates a private endpoint to a storage account.

## Features

- Subnet with private endpoint network policies disabled (required for private endpoints).
- Storage account used for a private endpoint demo.
- Private endpoint targeting the storage account (blob).

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

## Notes

- Private endpoint policies must be disabled on the subnet.
- The storage account name must be globally unique; override `storage_account_name` if needed.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
