# Secure Azure DevOps Identity Fixture

This fixture demonstrates a security-focused identity configuration with explicit memberships.

## Features

- Creates a module-managed Azure DevOps group
- Creates a secondary group used as a membership source
- Adds membership with overwrite mode

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
