# Terraform Azure DevOps Artifacts Feed Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps artifacts feed module for managing feeds, retention policies, and permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "path/to/azuredevops_artifacts_feed"

  name       = "example-feed"
  project_id = "00000000-0000-0000-0000-000000000000"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a project-scoped feed.
- [Complete](examples/complete) - This example demonstrates a project feed with permissions and retention policies.
- [Secure](examples/secure) - This example demonstrates a restricted feed with reader permissions and retention controls.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps feeds into the module


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
| [azuredevops_feed.feed](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/feed) | resource |
| [azuredevops_feed_permission.feed_permission](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/feed_permission) | resource |
| [azuredevops_feed_retention_policy.feed_retention_policy](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/feed_retention_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_features"></a> [features](#input\_features) | Feed feature flags for azuredevops\_feed.features. Set to null to leave unmanaged. | <pre>object({<br/>    permanent_delete = optional(bool)<br/>    restore          = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_feed_permissions"></a> [feed\_permissions](#input\_feed\_permissions) | List of feed permissions to assign. | <pre>list(object({<br/>    key                 = optional(string)<br/>    identity_descriptor = string<br/>    role                = string<br/>    display_name        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_feed_retention_policies"></a> [feed\_retention\_policies](#input\_feed\_retention\_policies) | List of feed retention policies to manage. | <pre>list(object({<br/>    key                                       = optional(string)<br/>    count_limit                               = number<br/>    days_to_keep_recently_downloaded_packages = number<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure DevOps feed. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Azure DevOps project ID to scope the feed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_feed_id"></a> [feed\_id](#output\_feed\_id) | The ID of the Azure DevOps feed. |
| <a name="output_feed_name"></a> [feed\_name](#output\_feed\_name) | The name of the Azure DevOps feed. |
| <a name="output_feed_permission_ids"></a> [feed\_permission\_ids](#output\_feed\_permission\_ids) | Map of feed permission IDs keyed by permission key. |
| <a name="output_feed_project_id"></a> [feed\_project\_id](#output\_feed\_project\_id) | The project ID associated with the Azure DevOps feed. |
| <a name="output_feed_retention_policy_ids"></a> [feed\_retention\_policy\_ids](#output\_feed\_retention\_policy\_ids) | Map of feed retention policy IDs keyed by retention policy key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
