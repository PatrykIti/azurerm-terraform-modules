# Basic Azure DevOps Agent Pools Example

This example demonstrates a basic Azure DevOps Agent Pools configuration with one pool and one queue.

## Features

- Single agent pool with a generated name
- Single queue attached to a project, using the module pool
- Random suffix to avoid naming conflicts

## Key Configuration

Provide `project_id` and optionally change the name prefixes to fit your naming conventions.

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
