# Basic Service Principal Entitlement Example

This example assigns a single entitlement to an Azure DevOps user.

## Usage

```bash
terraform init
terraform apply
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
| <a name="module_azuredevops_user_entitlement"></a> [azuredevops\_user\_entitlement](#module\_azuredevops\_user\_entitlement) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_user_principal_name"></a> [user\_principal\_name](#input\_user\_principal\_name) | User principal name for entitlement assignment. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_entitlement_ids"></a> [user\_entitlement\_ids](#output\_user\_entitlement\_ids) | Map of user entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->
