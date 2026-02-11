output "repository_id" {
  description = "The ID of the repository managed by this module."
  value       = azuredevops_git_repository.git_repository.id
}

output "repository_url" {
  description = "The web URL of the repository managed by this module."
  value       = azuredevops_git_repository.git_repository.web_url
}

output "branch_ids" {
  description = "Map of branch IDs keyed by branch name."
  value       = try({ for key, branch in azuredevops_git_repository_branch.git_repository_branch : key => branch.id }, {})
}

output "file_ids" {
  description = "Map of file IDs keyed by file path and branch."
  value       = try({ for key, file in azuredevops_git_repository_file.git_repository_file : key => file.id }, {})
}

output "permission_ids" {
  description = "Map of permission IDs keyed by branch and principal."
  value       = try({ for key, permission in azuredevops_git_permissions.git_permissions : key => permission.id }, {})
}

output "policy_ids" {
  description = "Map of policy IDs grouped by policy type and keyed by branch name (single policies), policy name (list policies), or policy type name (repository policies)."
  value = {
    branch_auto_reviewers     = try({ for key, policy in azuredevops_branch_policy_auto_reviewers.branch_policy_auto_reviewers : key => policy.id }, {})
    branch_build_validation   = try({ for key, policy in azuredevops_branch_policy_build_validation.branch_policy_build_validation : key => policy.id }, {})
    branch_comment_resolution = try({ for key, policy in azuredevops_branch_policy_comment_resolution.branch_policy_comment_resolution : key => policy.id }, {})
    branch_merge_types        = try({ for key, policy in azuredevops_branch_policy_merge_types.branch_policy_merge_types : key => policy.id }, {})
    branch_min_reviewers      = try({ for key, policy in azuredevops_branch_policy_min_reviewers.branch_policy_min_reviewers : key => policy.id }, {})
    branch_status_check       = try({ for key, policy in azuredevops_branch_policy_status_check.branch_policy_status_check : key => policy.id }, {})
    branch_work_item_linking  = try({ for key, policy in azuredevops_branch_policy_work_item_linking.branch_policy_work_item_linking : key => policy.id }, {})
    repo_author_email_pattern = try({
      author_email_pattern = azuredevops_repository_policy_author_email_pattern.repository_policy_author_email_pattern[0].id
    }, {})
    repo_case_enforcement = try({
      case_enforcement = azuredevops_repository_policy_case_enforcement.repository_policy_case_enforcement[0].id
    }, {})
    repo_file_path_pattern = try({
      file_path_pattern = azuredevops_repository_policy_file_path_pattern.repository_policy_file_path_pattern[0].id
    }, {})
    repo_max_file_size = try({
      max_file_size = azuredevops_repository_policy_max_file_size.repository_policy_max_file_size[0].id
    }, {})
    repo_max_path_length = try({
      max_path_length = azuredevops_repository_policy_max_path_length.repository_policy_max_path_length[0].id
    }, {})
    repo_reserved_names = try({
      reserved_names = azuredevops_repository_policy_reserved_names.repository_policy_reserved_names[0].id
    }, {})
  }
}
