# Secure Azure DevOps Repository Example

This example exercises secure repository policies and stricter review requirements for Azure DevOps Git repositories.

## Features

- Minimum reviewers policy with blocking enabled
- Dedicated branch used for policy scope (develop)
- Reserved names policy enabled

## Key Configuration

This fixture focuses on repository-level guardrails and review requirements that reduce the risk of unsafe changes.

## Security Considerations

- Review policies may block merges without approvals
- Reserved names are enforced for the repository

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
