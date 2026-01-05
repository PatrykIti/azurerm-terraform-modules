# Terraform Azure DevOps Project Permissions Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages Azure DevOps project permissions for group principals, with optional lookup by group name.

## Usage

```hcl
terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_project_permissions" {
  source = "path/to/azuredevops_project_permissions"

  project_id = var.project_id

  permissions = [
    {
      key        = "collection-admins"
      group_name = "Project Collection Administrators"
      scope      = "collection"
      permissions = {
        GENERIC_READ = "Allow"
      }
      replace = false
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example assigns a minimal permission set to a collection-level group by name.
- [Complete](examples/complete) - This example demonstrates a full permissions map with mixed scopes and optional principal override.
- [Secure](examples/secure) - This example demonstrates least-privilege permission assignments for project-level groups.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing permissions (limitations)

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_project_permissions.permission](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/project_permissions) | resource |
| [azuredevops_group.permission_group](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of project permission assignments. | <pre>list(object({<br/>    key         = optional(string)<br/>    principal   = optional(string)<br/>    group_name  = optional(string)<br/>    scope       = optional(string)<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_ids"></a> [permission\_ids](#output\_permission\_ids) | Map of permission assignment IDs keyed by permission key. |
| <a name="output_permission_principals"></a> [permission\_principals](#output\_permission\_principals) | Map of resolved principals keyed by permission key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
