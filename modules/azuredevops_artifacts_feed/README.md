# Terraform Azure DevOps Artifacts Feed Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps artifacts feed module for managing feeds, retention policies, and permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "path/to/azuredevops_artifacts_feed"

  feeds = {
    project = {
      name       = "example-feed"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a project-scoped feed.
- [Complete](examples/complete) - This example demonstrates a project feed with permissions and retention policies.
- [Secure](examples/secure) - This example demonstrates a restricted feed with reader permissions and retention controls.
<!-- END_EXAMPLES -->

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
| <a name="input_feed_permissions"></a> [feed\_permissions](#input\_feed\_permissions) | List of feed permissions to assign. | <pre>list(object({<br/>    key                 = optional(string)<br/>    feed_id             = optional(string)<br/>    feed_key            = optional(string)<br/>    identity_descriptor = string<br/>    role                = string<br/>    project_id          = optional(string)<br/>    display_name        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_feed_retention_policies"></a> [feed\_retention\_policies](#input\_feed\_retention\_policies) | List of feed retention policies to manage. | <pre>list(object({<br/>    key                                       = optional(string)<br/>    feed_id                                   = optional(string)<br/>    feed_key                                  = optional(string)<br/>    count_limit                               = number<br/>    days_to_keep_recently_downloaded_packages = number<br/>    project_id                                = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_feeds"></a> [feeds](#input\_feeds) | Map of feeds to manage. | <pre>map(object({<br/>    name        = optional(string)<br/>    project_id  = optional(string)<br/>    description = optional(string)<br/>    features = optional(object({<br/>      permanent_delete = optional(bool)<br/>      restore          = optional(bool)<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_feed_ids"></a> [feed\_ids](#output\_feed\_ids) | Map of feed IDs keyed by feed key. |
| <a name="output_feed_names"></a> [feed\_names](#output\_feed\_names) | Map of feed names keyed by feed key. |
| <a name="output_feed_project_ids"></a> [feed\_project\_ids](#output\_feed\_project\_ids) | Map of feed project IDs keyed by feed key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
