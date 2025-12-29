# Terraform Azure DevOps Service Hooks Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps service hooks module for managing webhook and storage queue subscriptions with permissions.

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

For multiple hooks, use module-level `for_each` in your configuration.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a simple webhook service hook.
- [Complete](examples/complete) - This example demonstrates module-level for_each for webhook and storage queue hooks with pipeline filters.
- [Secure](examples/secure) - This example demonstrates a filtered webhook with restricted permissions and stable keys.
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
| [azuredevops_servicehook_permissions.servicehook_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/servicehook_permissions) | resource |
| [azuredevops_servicehook_storage_queue_pipelines.storage_queue](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/servicehook_storage_queue_pipelines) | resource |
| [azuredevops_servicehook_webhook_tfs.webhook](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/servicehook_webhook_tfs) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_servicehook_permissions"></a> [servicehook\_permissions](#input\_servicehook\_permissions) | List of service hook permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>    project_id  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_queue_hook"></a> [storage\_queue\_hook](#input\_storage\_queue\_hook) | Storage queue pipeline hook configuration. Includes sensitive fields like account\_key. | <pre>object({<br/>    account_name = string<br/>    account_key  = string<br/>    queue_name   = string<br/>    ttl          = optional(number)<br/>    visi_timeout = optional(number)<br/>    run_state_changed_event = optional(object({<br/>      pipeline_id       = optional(string)<br/>      run_result_filter = optional(string)<br/>      run_state_filter  = optional(string)<br/>    }))<br/>    stage_state_changed_event = optional(object({<br/>      pipeline_id         = optional(string)<br/>      stage_name          = optional(string)<br/>      stage_result_filter = optional(string)<br/>      stage_state_filter  = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_webhook"></a> [webhook](#input\_webhook) | Webhook service hook configuration. Includes sensitive fields like basic\_auth\_password. | <pre>object({<br/>    url                       = string<br/>    accept_untrusted_certs    = optional(bool)<br/>    basic_auth_username       = optional(string)<br/>    basic_auth_password       = optional(string)<br/>    http_headers              = optional(map(string))<br/>    resource_details_to_send  = optional(string)<br/>    messages_to_send          = optional(string)<br/>    detailed_messages_to_send = optional(string)<br/><br/>    build_completed = optional(object({<br/>      definition_name = optional(string)<br/>      build_status    = optional(string)<br/>    }))<br/>    git_pull_request_commented = optional(object({<br/>      repository_id = optional(string)<br/>      branch        = optional(string)<br/>    }))<br/>    git_pull_request_created = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>    }))<br/>    git_pull_request_merge_attempted = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>      merge_result                    = optional(string)<br/>    }))<br/>    git_pull_request_updated = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>      notification_type               = optional(string)<br/>    }))<br/>    git_push = optional(object({<br/>      repository_id = optional(string)<br/>      branch        = optional(string)<br/>      pushed_by     = optional(string)<br/>    }))<br/>    repository_created = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    repository_deleted = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_forked = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_renamed = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_status_changed = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    service_connection_created = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    service_connection_updated = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    tfvc_checkin = optional(object({<br/>      path = string<br/>    }))<br/>    work_item_commented = optional(object({<br/>      work_item_type  = optional(string)<br/>      area_path       = optional(string)<br/>      tag             = optional(string)<br/>      comment_pattern = optional(string)<br/>    }))<br/>    work_item_created = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_deleted = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_restored = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_updated = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>      changed_fields = optional(string)<br/>      links_changed  = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_servicehook_permission_ids"></a> [servicehook\_permission\_ids](#output\_servicehook\_permission\_ids) | Map of service hook permission IDs keyed by permission key. |
| <a name="output_storage_queue_hook_id"></a> [storage\_queue\_hook\_id](#output\_storage\_queue\_hook\_id) | ID of the storage queue service hook when configured. |
| <a name="output_webhook_id"></a> [webhook\_id](#output\_webhook\_id) | ID of the webhook service hook when configured. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing service hooks into the module
