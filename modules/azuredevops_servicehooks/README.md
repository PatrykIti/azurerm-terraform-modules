# Terraform Azure DevOps Service Hooks Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps service hooks module for managing a single webhook subscription.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "path/to/azuredevops_servicehooks"

  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }
}
```

For multiple webhooks, use module-level `for_each` in your configuration.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a simple webhook service hook.
- [Complete](examples/complete) - This example demonstrates module-level for_each for multiple webhook subscriptions.
- [Secure](examples/secure) - This example demonstrates a filtered webhook configuration for work item updates.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing webhook service hooks into the module

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
| [azuredevops_servicehook_webhook_tfs.webhook](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/servicehook_webhook_tfs) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_webhook"></a> [webhook](#input\_webhook) | Webhook service hook configuration. Includes sensitive fields like basic\_auth\_password. | <pre>object({<br/>    url                       = string<br/>    accept_untrusted_certs    = optional(bool)<br/>    basic_auth_username       = optional(string)<br/>    basic_auth_password       = optional(string)<br/>    http_headers              = optional(map(string))<br/>    resource_details_to_send  = optional(string)<br/>    messages_to_send          = optional(string)<br/>    detailed_messages_to_send = optional(string)<br/><br/>    build_completed = optional(object({<br/>      definition_name = optional(string)<br/>      build_status    = optional(string)<br/>    }))<br/>    git_pull_request_commented = optional(object({<br/>      repository_id = optional(string)<br/>      branch        = optional(string)<br/>    }))<br/>    git_pull_request_created = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>    }))<br/>    git_pull_request_merge_attempted = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>      merge_result                    = optional(string)<br/>    }))<br/>    git_pull_request_updated = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>      notification_type               = optional(string)<br/>    }))<br/>    git_push = optional(object({<br/>      repository_id = optional(string)<br/>      branch        = optional(string)<br/>      pushed_by     = optional(string)<br/>    }))<br/>    repository_created = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    repository_deleted = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_forked = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_renamed = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_status_changed = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    service_connection_created = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    service_connection_updated = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    tfvc_checkin = optional(object({<br/>      path = string<br/>    }))<br/>    work_item_commented = optional(object({<br/>      work_item_type  = optional(string)<br/>      area_path       = optional(string)<br/>      tag             = optional(string)<br/>      comment_pattern = optional(string)<br/>    }))<br/>    work_item_created = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_deleted = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_restored = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_updated = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>      changed_fields = optional(string)<br/>      links_changed  = optional(bool)<br/>    }))<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_webhook_id"></a> [webhook\_id](#output\_webhook\_id) | ID of the webhook service hook. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
