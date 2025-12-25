# Terraform Azure DevOps Agent Pools Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps agent pools module for managing pools, queues, and elastic pools.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_agent_pools" {
  source = "path/to/azuredevops_agent_pools"

  name = "ado-agent-pool"

  agent_queues = [
    {
      key        = "default"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  ]

  # Optional: elastic_pool = { ... }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure DevOps Agent Pools configuration with one pool and one queue.
- [Complete](examples/complete) - This example demonstrates a fuller Azure DevOps Agent Pools configuration with queues and an optional elastic pool.
- [Secure](examples/secure) - This example demonstrates a security-focused Azure DevOps Agent Pools configuration with minimal automation.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
