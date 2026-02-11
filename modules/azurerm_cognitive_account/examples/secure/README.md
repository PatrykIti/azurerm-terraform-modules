# Secure Cognitive Account Example (OpenAI)

This example provisions an OpenAI account with public access disabled, local auth disabled, customer-managed keys, and a private endpoint created outside the module.

## Features

- Public network access disabled
- Local authentication disabled
- Customer-managed key with user-assigned identity
- Private endpoint and private DNS zone

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
