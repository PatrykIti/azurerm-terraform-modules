# Azure DevOps Repository Module Documentation

## Overview

This module manages a single Git repository and optional resources scoped to it:
branches, files, permissions, and repository/branch policies. Use a module-level
`for_each` in your environment configuration to manage multiple repositories.

## Managed Resources

- `azuredevops_git_repository`
- `azuredevops_git_repository_branch` (one per `branches` entry)
- `azuredevops_git_repository_file` (one per `files` entry)
- `azuredevops_git_permissions` (one per `git_permissions` entry)
- `azuredevops_branch_policy_*` (per branch, per policy)
- `azuredevops_repository_policy_*` (repository-level policies)

## Usage Notes

- The repository is always managed by this module; import existing repositories.
- `initialization` defaults to `{ init_type = "Uninitialized" }` and must be provided (provider requires the block); changes are ignored after creation (lifecycle ignore_changes).
- For `init_type = "Import"`, set `source_type = "Git"`, `source_url`, and one auth method (service connection or username/password).
- `policies` defaults to `{}` and must not be `null`.
- `branches[*].policies` defaults to `{}` and must not be `null`.
- `files[*].branch` defaults to `default_branch` when omitted.
- Branch policy scope is derived from branch name; no user-provided scope blocks.
- List policy names must be unique across all branches.
- Each branch must set exactly one of `ref_branch`, `ref_tag`, or `ref_commit_id`.
- Address/key rules used by imports and outputs:
  - Branches: `branch.name`
  - Files: `<file_path>:<branch>` (branch key defaults to `default`; apply uses `default_branch`)
  - Permissions: `<branch_name>:<principal>` (branch defaults to `root`)
  - Branch policies (single): `<branch_name>`
  - Branch policies (list): `<policy.name>`
  - Repository policies: `[0]` (count-based)

## Inputs (Grouped)

### Core Repository
- `project_id`, `name`, `default_branch`, `parent_repository_id`, `disabled`, `initialization`

### Branches and Branch Policies
- `branches` (branch refs + nested `policies`)

### Files
- `files`

### Permissions
- `git_permissions`

### Repository Policies
- `policies` (author email pattern, file path pattern, case enforcement, reserved names,
  maximum path length, maximum file size)

## Outputs (Highlights)

- `repository_id`, `repository_url`
- `branch_ids`, `file_ids`, `permission_ids`
- `policy_ids` (keys follow the rules above)

## Import Existing Repository

See [IMPORT.md](./IMPORT.md) for import blocks and Azure CLI commands that help you collect
repository IDs, branch refs, policy configuration IDs, and principal descriptors.

## Troubleshooting

- **Policy not created**: ensure `branches[*].policies` is not `null` and the policy object
  is set for the target branch.
- **Unexpected diffs for policies**: check list policy name uniqueness across branches and
  confirm that branch names match the actual refs.
- **Import fails for repo policies**: use the `[0]` address and a policy configuration ID.
- **Permissions errors**: verify the principal descriptor for the target group/user.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
