# Terraform Azure DevOps Team Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps team module for managing a team, members, and administrators.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_team" {
  source = "path/to/azuredevops_team"

  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "ado-core-team"
  description = "Core delivery team"

  team_members = [
    {
      key                = "core-members"
      member_descriptors = ["vssgp.Uy0xLTktMTIzNDU2"]
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure DevOps team configuration.
- [Complete](examples/complete) - This example demonstrates module-level for_each with memberships and administrators.
- [Secure](examples/secure) - This example demonstrates a security-focused team configuration.
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
| [azuredevops_team.team](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/team) | resource |
| [azuredevops_team_administrators.team_administrators](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/team_administrators) | resource |
| [azuredevops_team_members.team_members](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/team_members) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID where the team will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure DevOps team. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the Azure DevOps team. | `string` | `null` | no |
| <a name="input_team_administrators"></a> [team\_administrators](#input\_team\_administrators) | List of team administrator assignments. | <pre>list(object({<br/>    key               = optional(string)<br/>    team_id           = optional(string)<br/>    admin_descriptors = list(string)<br/>    mode              = optional(string, "add")<br/>  }))</pre> | `[]` | no |
| <a name="input_team_members"></a> [team\_members](#input\_team\_members) | List of team membership assignments. | <pre>list(object({<br/>    key                = optional(string)<br/>    team_id            = optional(string)<br/>    member_descriptors = list(string)<br/>    mode               = optional(string, "add")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_team_administrator_ids"></a> [team\_administrator\_ids](#output\_team\_administrator\_ids) | Map of team administrator assignment IDs keyed by admin key. |
| <a name="output_team_descriptor"></a> [team\_descriptor](#output\_team\_descriptor) | The descriptor of the Azure DevOps team. |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | The ID of the Azure DevOps team. |
| <a name="output_team_member_ids"></a> [team\_member\_ids](#output\_team\_member\_ids) | Map of team membership IDs keyed by membership key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps teams into the module
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
