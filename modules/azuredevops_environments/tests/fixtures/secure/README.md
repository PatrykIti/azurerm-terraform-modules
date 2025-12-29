# Secure Azure DevOps Environments Example

This example demonstrates a security-focused Azure DevOps environment with approvals and locks.

## Features

- Environment approvals for controlled deployments
- Exclusive lock to prevent concurrent releases
- Minimal environment surface area

## Key Configuration

This example focuses on approval workflows and exclusive locks for critical environments.

## Security Considerations

- Require approvals for deployments
- Prevent concurrent deployment stages with locks

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
