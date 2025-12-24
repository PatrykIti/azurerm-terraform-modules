output "repository_ids" {
  description = "Map of repository IDs keyed by repository key."
  value       = { for key, repo in azuredevops_git_repository.repo : key => repo.id }
}

output "repository_urls" {
  description = "Map of repository web URLs keyed by repository key."
  value       = { for key, repo in azuredevops_git_repository.repo : key => repo.web_url }
}

output "branch_ids" {
  description = "Map of branch IDs keyed by index."
  value       = { for key, branch in azuredevops_git_repository_branch.branch : key => branch.id }
}

output "policy_ids" {
  description = "Map of policy IDs grouped by policy type."
  value = {
    branch_auto_reviewers     = { for key, policy in azuredevops_branch_policy_auto_reviewers.policy : key => policy.id }
    branch_build_validation   = { for key, policy in azuredevops_branch_policy_build_validation.policy : key => policy.id }
    branch_comment_resolution = { for key, policy in azuredevops_branch_policy_comment_resolution.policy : key => policy.id }
    branch_merge_types        = { for key, policy in azuredevops_branch_policy_merge_types.policy : key => policy.id }
    branch_min_reviewers      = { for key, policy in azuredevops_branch_policy_min_reviewers.policy : key => policy.id }
    branch_status_check       = { for key, policy in azuredevops_branch_policy_status_check.policy : key => policy.id }
    branch_work_item_linking  = { for key, policy in azuredevops_branch_policy_work_item_linking.policy : key => policy.id }
    repo_author_email_pattern = { for key, policy in azuredevops_environments_policy_author_email_pattern.policy : key => policy.id }
    repo_case_enforcement     = { for key, policy in azuredevops_environments_policy_case_enforcement.policy : key => policy.id }
    repo_check_credentials    = { for key, policy in azuredevops_environments_policy_check_credentials.policy : key => policy.id }
    repo_file_path_pattern    = { for key, policy in azuredevops_environments_policy_file_path_pattern.policy : key => policy.id }
    repo_max_file_size        = { for key, policy in azuredevops_environments_policy_max_file_size.policy : key => policy.id }
    repo_max_path_length      = { for key, policy in azuredevops_environments_policy_max_path_length.policy : key => policy.id }
    repo_reserved_names       = { for key, policy in azuredevops_environments_policy_reserved_names.policy : key => policy.id }
  }
}
