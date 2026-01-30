# Basic Role Definition Example

This example creates a minimal custom role definition scoped to the current subscription.

## Features

- Defines a custom role with a single `actions` entry
- Uses subscription scope and assigns the role at that scope
- Uses a fixed name via variables for easy customization

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
