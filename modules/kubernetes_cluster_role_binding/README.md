# Terraform Kubernetes Cluster Role Binding Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Kubernetes ClusterRoleBinding Terraform module for binding a cluster role to
subjects in an existing cluster.

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

module "kubernetes_cluster_role_binding" {
  source = "path/to/kubernetes_cluster_role_binding"

  name = "namespace-reader-users"

  role_ref = {
    name = "namespace-reader"
  }

  subjects = [
    {
      kind = "User"
      name = "00000000-0000-0000-0000-000000000000"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example binds a ClusterRole to a single user.
- [Complete](examples/complete) - This example binds a ClusterRole to multiple users.
- [Secure](examples/secure) - This example binds a ClusterRole to a service account.
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
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing cluster role bindings
