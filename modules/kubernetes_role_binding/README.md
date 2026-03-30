# Terraform Kubernetes Role Binding Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Kubernetes RoleBinding Terraform module for binding a namespace-scoped role to
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

module "kubernetes_role_binding" {
  source = "path/to/kubernetes_role_binding"

  name      = "intent-resolver-read-users"
  namespace = "intent-resolver"

  role_ref = {
    kind = "Role"
    name = "intent-resolver-read"
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
- [Basic](examples/basic) - This example binds a namespace role to a single user.
- [Complete](examples/complete) - This example binds a namespace role to two users.
- [Secure](examples/secure) - This example binds a namespace role to a service account.
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
| [kubernetes_role_binding_v1.role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the RoleBinding. | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the RoleBinding. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | RoleBinding name. Must be a valid DNS-1123 label. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the RoleBinding is created. | `string` | n/a | yes |
| <a name="input_role_ref"></a> [role\_ref](#input\_role\_ref) | Reference to the Role or ClusterRole bound by this RoleBinding. | <pre>object({<br/>    api_group = optional(string, "rbac.authorization.k8s.io")<br/>    kind      = optional(string, "Role")<br/>    name      = string<br/>  })</pre> | n/a | yes |
| <a name="input_subjects"></a> [subjects](#input\_subjects) | Subjects bound by the RoleBinding. | <pre>list(object({<br/>    kind      = string<br/>    name      = string<br/>    namespace = optional(string)<br/>    api_group = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The Terraform ID of the RoleBinding. |
| <a name="output_name"></a> [name](#output\_name) | The RoleBinding name. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The namespace of the RoleBinding. |
| <a name="output_role_ref"></a> [role\_ref](#output\_role\_ref) | The referenced role. |
| <a name="output_subjects"></a> [subjects](#output\_subjects) | The subjects bound by the RoleBinding. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Scope and provider notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing role bindings
