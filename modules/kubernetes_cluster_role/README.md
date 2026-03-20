# Terraform Kubernetes Cluster Role Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Kubernetes ClusterRole Terraform module for managing a single cluster-scoped
RBAC role in an existing cluster.

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

module "kubernetes_cluster_role" {
  source = "path/to/kubernetes_cluster_role"

  name = "namespace-reader"

  rules = [
    {
      api_groups = [""]
      resources  = ["namespaces"]
      verbs      = ["get", "list", "watch"]
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a cluster-wide read role for namespaces.
- [Complete](examples/complete) - This example creates a ClusterRole for namespace and pod discovery plus non-resource API paths.
- [Secure](examples/secure) - This example creates a narrowly scoped ClusterRole using `resource_names`.
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
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing cluster roles
