# Secure Azure DevOps Pipelines Example

This example demonstrates a security-focused Azure DevOps pipeline configuration with restricted permissions.

## Features

- Build definition permissions scoped to administrators
- Explicit pipeline authorization for service connections
- Minimal build definition configuration

## Key Configuration

This example focuses on access control and explicit authorization boundaries for pipelines.

## Security Considerations

- Restrict build definition permissions to approved groups
- Avoid broad pipeline authorizations

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
