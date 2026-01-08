# Terraform Azure DevOps Security Role Assignment Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **0.1.0**
<!-- END_VERSION -->

## Description

Manages Azure DevOps security role assignments for groups, users, or service principals.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_securityrole_assignment" {
  source = "path/to/azuredevops_securityrole_assignment"

  scope       = "<scope_id>"
  resource_id = "<resource_id>"
  role_name   = "Reader"
  identity_id = "11111111-1111-1111-1111-111111111111"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example assigns a Reader role to a provided identity within a project scope.
- [Complete](examples/complete) - This example assigns a role within a project scope with explicit input values.
- [Secure](examples/secure) - This example assigns a minimal Reader role to a specified identity.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps security role assignments into the module

## Scope IDs

Azure DevOps does not provide a public API to list all valid `scope` values for security roles. Known working scope IDs observed in the UI include:

- `distributedtask.globalagentpoolrole` (Organization Settings -> Agent Pools -> Security)
- `distributedtask.variablegroup` (Pipelines -> Library -> Variable groups -> Security)
- `distributedtask.machinegrouprole` (Pipelines -> Deployment groups -> Security)
- `distributedtask.library` (Pipelines -> Library -> Security)
- `distributedtask.environmentreferencerole` (Pipelines -> Environments -> Security)
- `distributedtask.securefile` (Pipelines -> Library -> Secure files -> Security)

Resource ID formats observed in the UI:

| Scope ID | UI location | `resource_id` format | Example |
| --- | --- | --- | --- |
| `distributedtask.globalagentpoolrole` | Organization Settings -> Agent Pools -> Security | `<agent_pool_id>` | `54` |
| `distributedtask.environmentreferencerole` | Pipelines -> Environments -> Security | `<project_id>_<environment_id>` | `95ebdf96-3573-4514-8f03-1f25a57735f2_23` |
| `distributedtask.variablegroup` | Pipelines -> Library -> Variable groups -> Security | `<project_id>$<variable_group_id>` | `95ebdf96-3573-4514-8f03-1f25a57735f2$2` |
| `distributedtask.machinegrouprole` | Pipelines -> Deployment groups -> Security | `<project_id>_<deployment_group_id>` | `95ebdf96-3573-4514-8f03-1f25a57735f2_492` |
| `distributedtask.library` | Pipelines -> Library -> Security | `<project_id>$0` | `95ebdf96-3573-4514-8f03-1f25a57735f2$0` |
| `distributedtask.securefile` | Pipelines -> Library -> Secure files -> Security | `<project_id>$<secure_file_id>` | `95ebdf96-3573-4514-8f03-1f25a57735f2$1ea53828-cb7a-41bc-ab24-0c8b6a3dd3e9` |

Note: the Azure DevOps UI encodes `$` as `%24` in URLs (for example, `95eb...%242` means `95eb...$2`).

For each scope, `resource_id` must be the ID of the target resource. If you see `SecurityRoleScope ... does not exist`, the `scope` value is invalid for the API call you are making.

Example role definition queries:

```bash
curl -s -u :$AZDO_PERSONAL_ACCESS_TOKEN \
  "https://dev.azure.com/<org>/_apis/securityroles/scopes/distributedtask.globalagentpoolrole/roledefinitions?api-version=7.1-preview.1"

curl -s -u :$AZDO_PERSONAL_ACCESS_TOKEN \
  "https://dev.azure.com/<org>/_apis/securityroles/scopes/distributedtask.variablegroup/roledefinitions?api-version=7.1-preview.1"

curl -s -u :$AZDO_PERSONAL_ACCESS_TOKEN \
  "https://dev.azure.com/<org>/_apis/securityroles/scopes/distributedtask.machinegrouprole/roledefinitions?api-version=7.1-preview.1"
```

If you need other scopes, inspect the Azure DevOps UI network calls:

1) Open Developer Tools (F12) in your browser.
2) Navigate to Organization Settings > Security (or another permissions area).
3) Look for requests to `_apis/securityroles/scopes/{scopeId}` and reuse those `scopeId` values.

Reference: https://learn.microsoft.com/en-us/answers/questions/2259153/where-can-i-find-the-applicable-scopeids-for-list

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
| [azuredevops_securityrole_assignment.securityrole_assignment](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/securityrole_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity_id"></a> [identity\_id](#input\_identity\_id) | Identity descriptor/ID to assign the role to. | `string` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | Target resource ID for the security role assignment (e.g., project ID). | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Role name to assign. Allowed values: Administrator, Reader, User; for scope distributedtask.library, Creator is also allowed. | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | Security role scope ID (for project scope, use the project GUID). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityrole_assignment_id"></a> [securityrole\_assignment\_id](#output\_securityrole\_assignment\_id) | The security role assignment ID. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
