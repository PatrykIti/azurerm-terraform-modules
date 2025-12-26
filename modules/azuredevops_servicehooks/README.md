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

  webhooks = [
    {
      key = "git-push"
      url = "https://example.com/webhook"
      git_push = {}
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a simple webhook service hook with a stable key.
- [Complete](examples/complete) - This example demonstrates webhooks and storage queue hooks with pipeline filters and stable keys.
- [Secure](examples/secure) - This example demonstrates a filtered webhook with restricted permissions and a stable key.
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
| <a name="input_servicehook_permissions"></a> [servicehook\_permissions](#input\_servicehook\_permissions) | List of service hook permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool)<br/>    project_id  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_queue_hooks"></a> [storage\_queue\_hooks](#input\_storage\_queue\_hooks) | List of storage queue pipeline hooks to manage. Includes sensitive fields like account\_key. | <pre>list(object({<br/>    key          = optional(string)<br/>    account_name = string<br/>    account_key  = string<br/>    queue_name   = string<br/>    ttl          = optional(number)<br/>    visi_timeout = optional(number)<br/>    run_state_changed_event = optional(object({<br/>      pipeline_id       = optional(string)<br/>      run_result_filter = optional(string)<br/>      run_state_filter  = optional(string)<br/>    }))<br/>    stage_state_changed_event = optional(object({<br/>      pipeline_id         = optional(string)<br/>      stage_name          = optional(string)<br/>      stage_result_filter = optional(string)<br/>      stage_state_filter  = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | List of webhook service hooks to manage. Includes sensitive fields like basic\_auth\_password. | <pre>list(object({<br/>    key                       = optional(string)<br/>    url                       = string<br/>    accept_untrusted_certs    = optional(bool)<br/>    basic_auth_username       = optional(string)<br/>    basic_auth_password       = optional(string)<br/>    http_headers              = optional(map(string))<br/>    resource_details_to_send  = optional(string)<br/>    messages_to_send          = optional(string)<br/>    detailed_messages_to_send = optional(string)<br/><br/>    build_completed = optional(object({<br/>      definition_name = optional(string)<br/>      build_status    = optional(string)<br/>    }))<br/>    git_pull_request_commented = optional(object({<br/>      repository_id = optional(string)<br/>      branch        = optional(string)<br/>    }))<br/>    git_pull_request_created = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>    }))<br/>    git_pull_request_merge_attempted = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>      merge_result                    = optional(string)<br/>    }))<br/>    git_pull_request_updated = optional(object({<br/>      repository_id                   = optional(string)<br/>      branch                          = optional(string)<br/>      pull_request_created_by         = optional(string)<br/>      pull_request_reviewers_contains = optional(string)<br/>      notification_type               = optional(string)<br/>    }))<br/>    git_push = optional(object({<br/>      repository_id = optional(string)<br/>      branch        = optional(string)<br/>      pushed_by     = optional(string)<br/>    }))<br/>    repository_created = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    repository_deleted = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_forked = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_renamed = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    repository_status_changed = optional(object({<br/>      repository_id = optional(string)<br/>    }))<br/>    service_connection_created = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    service_connection_updated = optional(object({<br/>      project_id = optional(string)<br/>    }))<br/>    tfvc_checkin = optional(object({<br/>      path = string<br/>    }))<br/>    work_item_commented = optional(object({<br/>      work_item_type  = optional(string)<br/>      area_path       = optional(string)<br/>      tag             = optional(string)<br/>      comment_pattern = optional(string)<br/>    }))<br/>    work_item_created = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_deleted = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_restored = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>    }))<br/>    work_item_updated = optional(object({<br/>      work_item_type = optional(string)<br/>      area_path      = optional(string)<br/>      tag            = optional(string)<br/>      changed_fields = optional(string)<br/>      links_changed  = optional(bool)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_servicehook_ids"></a> [servicehook\_ids](#output\_servicehook\_ids) | Map of service hook IDs grouped by type. |
| <a name="output_servicehook_permission_ids"></a> [servicehook\_permission\_ids](#output\_servicehook\_permission\_ids) | Map of service hook permission IDs keyed by permission key. |
| <a name="output_storage_queue_hook_ids"></a> [storage\_queue\_hook\_ids](#output\_storage\_queue\_hook\_ids) | Map of storage queue service hook IDs keyed by hook key. |
| <a name="output_webhook_ids"></a> [webhook\_ids](#output\_webhook\_ids) | Map of webhook service hook IDs keyed by webhook key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing service hooks into the module
