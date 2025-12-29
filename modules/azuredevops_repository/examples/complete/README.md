# Complete Azure DevOps Repository Example

This example demonstrates managing multiple repositories (via module-level for_each) with branches, permissions, and a selection of branch/repository policies.

## Features

- Two repositories with clean initialization (module-level for_each)
- Additional branch created from default branch
- Git permissions for a group principal
- Branch policies (minimum reviewers, build validation)
- Repository policies (author email pattern, reserved names)

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
