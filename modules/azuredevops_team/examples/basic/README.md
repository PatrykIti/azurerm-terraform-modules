# Basic Azure DevOps Team Example

This example demonstrates a minimal Azure DevOps team configuration.

## Features

- Creates a single Azure DevOps team
- Optionally assigns members if descriptors are provided

## Key Configuration

Provide member descriptors to add initial members.

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_team"></a> [azuredevops\_team](#module\_azuredevops\_team) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_member_descriptors"></a> [member\_descriptors](#input\_member\_descriptors) | Optional member descriptors to add to the team. | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Name of the team. | `string` | `"ado-team-basic-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_team_descriptor"></a> [team\_descriptor](#output\_team\_descriptor) | Descriptor of the Azure DevOps team. |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | ID of the Azure DevOps team. |
<!-- END_TF_DOCS -->
