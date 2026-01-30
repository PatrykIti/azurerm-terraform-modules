# Secure Role Definition Example

This example demonstrates a least-privilege role definition scoped to a single resource group.

## Features

- Scope restricted to a dedicated resource group
- Minimal `actions` list
- No data actions or broad permissions

## Key Configuration

This example implements least-privilege by limiting assignable scopes and keeping permissions minimal.

## Security Considerations

- Keep the role scope limited to the smallest required resource group
- Avoid broad actions such as `*` or management group scopes unless necessary

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
