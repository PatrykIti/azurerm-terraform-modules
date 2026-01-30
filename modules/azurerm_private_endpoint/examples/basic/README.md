# Basic Private Endpoint Example

This example provisions a Private Endpoint that connects to a Storage Account (blob subresource). It also creates a VNet and subnet with private endpoint network policies disabled.

## Highlights

- Private Endpoint with a single service connection
- Storage Account target
- VNet + subnet configured for private endpoints

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
