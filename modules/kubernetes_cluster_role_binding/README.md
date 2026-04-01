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
- [Basic](examples/basic) - This example binds a cluster-scoped read role to a single user.
- [Complete](examples/complete) - This example binds a cluster discovery role to two users.
- [Secure](examples/secure) - This example binds a cluster-scoped read role to a single service account.
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
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role_binding_v1.cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the ClusterRoleBinding. | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the ClusterRoleBinding. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | ClusterRoleBinding name. Must be a valid DNS-1123 label. | `string` | n/a | yes |
| <a name="input_role_ref"></a> [role\_ref](#input\_role\_ref) | Reference to the ClusterRole bound by this ClusterRoleBinding. | <pre>object({<br/>    api_group = optional(string, "rbac.authorization.k8s.io")<br/>    kind      = optional(string, "ClusterRole")<br/>    name      = string<br/>  })</pre> | n/a | yes |
| <a name="input_subjects"></a> [subjects](#input\_subjects) | Subjects bound by the ClusterRoleBinding. | <pre>list(object({<br/>    kind      = string<br/>    name      = string<br/>    namespace = optional(string)<br/>    api_group = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The Terraform ID of the ClusterRoleBinding. |
| <a name="output_name"></a> [name](#output\_name) | The ClusterRoleBinding name. |
| <a name="output_role_ref"></a> [role\_ref](#output\_role\_ref) | The referenced cluster role. |
| <a name="output_subjects"></a> [subjects](#output\_subjects) | The subjects bound by the ClusterRoleBinding. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Scope and provider notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing cluster role bindings
