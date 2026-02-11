# Complete Private DNS Zone Example

This example shows a Private DNS Zone with a custom SOA record and additional tags.

## Features

- Creates a Private DNS Zone for a common Azure Private Link domain
- Configures `soa_record` with TTL and timing values
- Applies production-grade tagging

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
