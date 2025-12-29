# Terraform Azure DevOps Repository Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps repository module for managing a Git repository, branches, permissions, and policies.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_repository" {
  source = "path/to/azuredevops_repository"

  project_id = "00000000-0000-0000-0000-000000000000"

  name = "example-repo"

  initialization = {
    init_type = "Clean"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a Git repository with an initial README file.
- [Complete](examples/complete) - This example demonstrates managing multiple repositories (via module-level for_each) with branches, permissions, and a selection of branch/repository policies.
- [Secure](examples/secure) - This example demonstrates a repository with stricter review and status policies.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps repositories into the module


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
| [azuredevops_branch_policy_auto_reviewers.branch_policy_auto_reviewers](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_auto_reviewers) | resource |
| [azuredevops_branch_policy_build_validation.branch_policy_build_validation](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_build_validation) | resource |
| [azuredevops_branch_policy_comment_resolution.branch_policy_comment_resolution](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_comment_resolution) | resource |
| [azuredevops_branch_policy_merge_types.branch_policy_merge_types](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_merge_types) | resource |
| [azuredevops_branch_policy_min_reviewers.branch_policy_min_reviewers](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_min_reviewers) | resource |
| [azuredevops_branch_policy_status_check.branch_policy_status_check](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_status_check) | resource |
| [azuredevops_branch_policy_work_item_linking.branch_policy_work_item_linking](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/branch_policy_work_item_linking) | resource |
| [azuredevops_git_permissions.git_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/git_permissions) | resource |
| [azuredevops_git_repository.git_repository](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/git_repository) | resource |
| [azuredevops_git_repository_branch.git_repository_branch](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/git_repository_branch) | resource |
| [azuredevops_git_repository_file.git_repository_file](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/git_repository_file) | resource |
| [azuredevops_repository_policy_author_email_pattern.repository_policy_author_email_pattern](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/repository_policy_author_email_pattern) | resource |
| [azuredevops_repository_policy_case_enforcement.repository_policy_case_enforcement](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/repository_policy_case_enforcement) | resource |
| [azuredevops_repository_policy_file_path_pattern.repository_policy_file_path_pattern](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/repository_policy_file_path_pattern) | resource |
| [azuredevops_repository_policy_max_file_size.repository_policy_max_file_size](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/repository_policy_max_file_size) | resource |
| [azuredevops_repository_policy_max_path_length.repository_policy_max_path_length](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/repository_policy_max_path_length) | resource |
| [azuredevops_repository_policy_reserved_names.repository_policy_reserved_names](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/repository_policy_reserved_names) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_branch_policy_auto_reviewers"></a> [branch\_policy\_auto\_reviewers](#input\_branch\_policy\_auto\_reviewers) | List of auto reviewer branch policies. | <pre>list(object({<br/>    key                         = optional(string)<br/>    enabled                     = optional(bool)<br/>    blocking                    = optional(bool)<br/>    auto_reviewer_ids           = list(string)<br/>    path_filters                = optional(list(string))<br/>    submitter_can_vote          = optional(bool)<br/>    message                     = optional(string)<br/>    minimum_number_of_reviewers = optional(number)<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branch_policy_build_validation"></a> [branch\_policy\_build\_validation](#input\_branch\_policy\_build\_validation) | List of build validation branch policies. | <pre>list(object({<br/>    key                         = optional(string)<br/>    enabled                     = optional(bool)<br/>    blocking                    = optional(bool)<br/>    build_definition_id         = string<br/>    display_name                = string<br/>    manual_queue_only           = optional(bool)<br/>    queue_on_source_update_only = optional(bool)<br/>    valid_duration              = optional(number)<br/>    filename_patterns           = optional(list(string))<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branch_policy_comment_resolution"></a> [branch\_policy\_comment\_resolution](#input\_branch\_policy\_comment\_resolution) | List of comment resolution branch policies. | <pre>list(object({<br/>    key      = optional(string)<br/>    enabled  = optional(bool)<br/>    blocking = optional(bool)<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branch_policy_merge_types"></a> [branch\_policy\_merge\_types](#input\_branch\_policy\_merge\_types) | List of merge types branch policies. | <pre>list(object({<br/>    key                           = optional(string)<br/>    enabled                       = optional(bool)<br/>    blocking                      = optional(bool)<br/>    allow_squash                  = optional(bool)<br/>    allow_rebase_and_fast_forward = optional(bool)<br/>    allow_basic_no_fast_forward   = optional(bool)<br/>    allow_rebase_with_merge       = optional(bool)<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branch_policy_min_reviewers"></a> [branch\_policy\_min\_reviewers](#input\_branch\_policy\_min\_reviewers) | List of minimum reviewers branch policies. | <pre>list(object({<br/>    key                                    = optional(string)<br/>    enabled                                = optional(bool)<br/>    blocking                               = optional(bool)<br/>    reviewer_count                         = number<br/>    submitter_can_vote                     = optional(bool)<br/>    last_pusher_cannot_approve             = optional(bool)<br/>    allow_completion_with_rejects_or_waits = optional(bool)<br/>    on_push_reset_approved_votes           = optional(bool)<br/>    on_push_reset_all_votes                = optional(bool)<br/>    on_last_iteration_require_vote         = optional(bool)<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branch_policy_status_check"></a> [branch\_policy\_status\_check](#input\_branch\_policy\_status\_check) | List of status check branch policies. | <pre>list(object({<br/>    key                  = optional(string)<br/>    enabled              = optional(bool)<br/>    blocking             = optional(bool)<br/>    name                 = string<br/>    genre                = optional(string)<br/>    author_id            = optional(string)<br/>    invalidate_on_update = optional(bool)<br/>    applicability        = optional(string)<br/>    filename_patterns    = optional(list(string))<br/>    display_name         = optional(string)<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branch_policy_work_item_linking"></a> [branch\_policy\_work\_item\_linking](#input\_branch\_policy\_work\_item\_linking) | List of work item linking branch policies. | <pre>list(object({<br/>    key      = optional(string)<br/>    enabled  = optional(bool)<br/>    blocking = optional(bool)<br/>    scope = list(object({<br/>      repository_id  = optional(string)<br/>      repository_ref = optional(string)<br/>      match_type     = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_branches"></a> [branches](#input\_branches) | List of Git repository branches to manage. | <pre>list(object({<br/>    key           = optional(string)<br/>    repository_id = optional(string)<br/>    name          = string<br/>    ref_branch    = optional(string)<br/>    ref_tag       = optional(string)<br/>    ref_commit_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Default branch ref for the repository (for example, refs/heads/main). | `string` | `null` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether the repository is disabled. | `bool` | `null` | no |
| <a name="input_files"></a> [files](#input\_files) | List of Git repository files to manage. | <pre>list(object({<br/>    key                 = optional(string)<br/>    repository_id       = optional(string)<br/>    file                = string<br/>    content             = string<br/>    branch              = optional(string)<br/>    commit_message      = optional(string)<br/>    overwrite_on_create = optional(bool)<br/>    author_name         = optional(string)<br/>    author_email        = optional(string)<br/>    committer_name      = optional(string)<br/>    committer_email     = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_git_permissions"></a> [git\_permissions](#input\_git\_permissions) | List of Git permissions to assign. | <pre>list(object({<br/>    key           = optional(string)<br/>    repository_id = optional(string)<br/>    branch_name   = optional(string)<br/>    principal     = string<br/>    permissions   = map(string)<br/>    replace       = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_initialization"></a> [initialization](#input\_initialization) | Repository initialization settings.<br/>- init\_type: Uninitialized, Clean, Import<br/>- source\_type: Git (required when init\_type is Import)<br/>- source\_url: required when init\_type is Import<br/>- service\_connection\_id or username/password for Import auth | <pre>object({<br/>    init_type             = optional(string, "Uninitialized")<br/>    source_type           = optional(string)<br/>    source_url            = optional(string)<br/>    service_connection_id = optional(string)<br/>    username              = optional(string)<br/>    password              = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the repository to create. When null, the module will not create a repository. | `string` | `null` | no |
| <a name="input_parent_repository_id"></a> [parent\_repository\_id](#input\_parent\_repository\_id) | Parent repository ID for forks. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_repository_policy_author_email_pattern"></a> [repository\_policy\_author\_email\_pattern](#input\_repository\_policy\_author\_email\_pattern) | List of author email pattern repository policies. | <pre>list(object({<br/>    key                   = optional(string)<br/>    enabled               = optional(bool)<br/>    blocking              = optional(bool)<br/>    author_email_patterns = list(string)<br/>    repository_ids        = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_repository_policy_case_enforcement"></a> [repository\_policy\_case\_enforcement](#input\_repository\_policy\_case\_enforcement) | List of case enforcement repository policies. | <pre>list(object({<br/>    key                     = optional(string)<br/>    enabled                 = optional(bool)<br/>    blocking                = optional(bool)<br/>    enforce_consistent_case = bool<br/>    repository_ids          = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_repository_policy_file_path_pattern"></a> [repository\_policy\_file\_path\_pattern](#input\_repository\_policy\_file\_path\_pattern) | List of file path pattern repository policies. | <pre>list(object({<br/>    key               = optional(string)<br/>    enabled           = optional(bool)<br/>    blocking          = optional(bool)<br/>    filepath_patterns = list(string)<br/>    repository_ids    = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_repository_policy_max_file_size"></a> [repository\_policy\_max\_file\_size](#input\_repository\_policy\_max\_file\_size) | List of max file size repository policies. | <pre>list(object({<br/>    key            = optional(string)<br/>    enabled        = optional(bool)<br/>    blocking       = optional(bool)<br/>    max_file_size  = number<br/>    repository_ids = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_repository_policy_max_path_length"></a> [repository\_policy\_max\_path\_length](#input\_repository\_policy\_max\_path\_length) | List of max path length repository policies. | <pre>list(object({<br/>    key             = optional(string)<br/>    enabled         = optional(bool)<br/>    blocking        = optional(bool)<br/>    max_path_length = number<br/>    repository_ids  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_repository_policy_reserved_names"></a> [repository\_policy\_reserved\_names](#input\_repository\_policy\_reserved\_names) | List of reserved names repository policies. | <pre>list(object({<br/>    key            = optional(string)<br/>    enabled        = optional(bool)<br/>    blocking       = optional(bool)<br/>    repository_ids = optional(list(string))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_ids"></a> [branch\_ids](#output\_branch\_ids) | Map of branch IDs keyed by branch key. |
| <a name="output_file_ids"></a> [file\_ids](#output\_file\_ids) | Map of file IDs keyed by file key. |
| <a name="output_permission_ids"></a> [permission\_ids](#output\_permission\_ids) | Map of permission IDs keyed by permission key. |
| <a name="output_policy_ids"></a> [policy\_ids](#output\_policy\_ids) | Map of policy IDs grouped by policy type and keyed by policy key. |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | The ID of the repository managed by this module. |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The web URL of the repository managed by this module. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
