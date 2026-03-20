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
- [Basic](examples/basic) - This example creates a cluster-scoped read role for namespaces.
- [Complete](examples/complete) - This example creates a ClusterRole for namespace and pod discovery plus
- [Secure](examples/secure) - This example creates a narrowly scoped ClusterRole using `resource_names`.
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
| [kubernetes_cluster_role_v1.cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aggregation_rule"></a> [aggregation\_rule](#input\_aggregation\_rule) | Optional aggregation rule used to compose this ClusterRole from labels on other ClusterRoles. | <pre>object({<br/>    cluster_role_selectors = list(object({<br/>      match_labels = optional(map(string))<br/>      match_expressions = optional(list(object({<br/>        key      = optional(string)<br/>        operator = optional(string)<br/>        values   = optional(set(string))<br/>      })), [])<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the ClusterRole. | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the ClusterRole. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | ClusterRole name. Must be a valid DNS-1123 label. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | Policy rules for the ClusterRole. | <pre>list(object({<br/>    api_groups        = optional(list(string))<br/>    resources         = optional(list(string))<br/>    verbs             = list(string)<br/>    resource_names    = optional(list(string))<br/>    non_resource_urls = optional(list(string))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aggregation_rule"></a> [aggregation\_rule](#output\_aggregation\_rule) | The rendered aggregation rule. |
| <a name="output_id"></a> [id](#output\_id) | The Terraform ID of the ClusterRole. |
| <a name="output_name"></a> [name](#output\_name) | The ClusterRole name. |
| <a name="output_rules"></a> [rules](#output\_rules) | The rendered ClusterRole rules. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Scope and provider notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing cluster roles
