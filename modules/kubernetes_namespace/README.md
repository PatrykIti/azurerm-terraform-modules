# Terraform Kubernetes Namespace Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Kubernetes namespace Terraform module for managing a single namespace in an
existing cluster.

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

module "kubernetes_namespace" {
  source = "path/to/kubernetes_namespace"

  name = "intent-resolver"

  labels = {
    "app.kubernetes.io/part-of" = "genai"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a minimal namespace in an existing Kubernetes cluster.
- [Complete](examples/complete) - This example creates a namespace with labels, annotations, and waiting for the
- [Secure](examples/secure) - This example creates a namespace with security and ownership annotations.
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
| [kubernetes_namespace_v1.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the namespace. | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the namespace. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Namespace name. Must be a valid DNS-1123 label. | `string` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for the namespace resource. | <pre>object({<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_wait_for_default_service_account"></a> [wait\_for\_default\_service\_account](#input\_wait\_for\_default\_service\_account) | If true, Terraform waits for the default service account to be created in the namespace. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_annotations"></a> [annotations](#output\_annotations) | Annotations assigned to the namespace. |
| <a name="output_generation"></a> [generation](#output\_generation) | The generation of the namespace resource. |
| <a name="output_id"></a> [id](#output\_id) | The Terraform ID of the namespace. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels assigned to the namespace. |
| <a name="output_name"></a> [name](#output\_name) | The namespace name. |
| <a name="output_resource_version"></a> [resource\_version](#output\_resource\_version) | The resource version of the namespace. |
| <a name="output_uid"></a> [uid](#output\_uid) | The UID of the namespace. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Scope and provider notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing namespaces
