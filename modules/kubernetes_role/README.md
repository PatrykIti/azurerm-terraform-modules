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
- [Basic](examples/basic) - This example creates a read-only namespace-scoped role.
- [Complete](examples/complete) - This example creates a namespace role for read access plus `pods/portforward`.
- [Secure](examples/secure) - This example creates a narrowly scoped namespace role using `resource_names`.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_role_v1.role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the Role. | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the Role. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Role name. Must be a valid DNS-1123 label. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the Role is created. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | Namespace-scoped RBAC rules for the Role. | <pre>list(object({<br/>    api_groups     = set(string)<br/>    resources      = set(string)<br/>    verbs          = set(string)<br/>    resource_names = optional(set(string))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The Terraform ID of the Role. |
| <a name="output_name"></a> [name](#output\_name) | The Role name. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The namespace of the Role. |
| <a name="output_rules"></a> [rules](#output\_rules) | The rendered Role rules. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Scope and provider notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing roles
