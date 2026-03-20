# Terraform Kubernetes Role Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Kubernetes Role Terraform module for managing a single namespace-scoped RBAC
role in an existing cluster.

## Usage

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "kubernetes" {}

module "kubernetes_role" {
  source = "path/to/kubernetes_role"

  name      = "intent-resolver-read"
  namespace = "intent-resolver"

  rules = [
    {
      api_groups = [""]
      resources  = ["pods", "services", "endpoints"]
      verbs      = ["get", "list", "watch"]
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a read-only namespace-scoped role for pods, services, and endpoints.
- [Complete](examples/complete) - This example creates a role that combines namespace read access with `pods/portforward`.
- [Secure](examples/secure) - This example creates a least-privilege namespace role with narrow resource names.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Scope and provider notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing roles
