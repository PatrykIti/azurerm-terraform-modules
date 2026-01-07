# Secure Service Principal Entitlement Example

This example assigns a stakeholder license to a service principal.

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
| <a name="module_azuredevops_service_principal_entitlement"></a> [azuredevops\_service\_principal\_entitlement](#module\_azuredevops\_service\_principal\_entitlement) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_service_principal_origin_id"></a> [service\_principal\_origin\_id](#input\_service\_principal\_origin\_id) | Service principal object ID for entitlement assignment. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_principal_entitlement_ids"></a> [service\_principal\_entitlement\_ids](#output\_service\_principal\_entitlement\_ids) | Map of service principal entitlement IDs keyed by entitlement key. |
<!-- END_TF_DOCS -->
