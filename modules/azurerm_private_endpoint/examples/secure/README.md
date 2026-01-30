# Secure Private Endpoint Example

This example provisions a Private Endpoint with a private DNS zone group and a Storage Account with public network access disabled.

## Highlights

- Storage Account with `public_network_access_enabled = false`
- Private DNS zone + VNet link
- Private Endpoint with DNS zone group

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
