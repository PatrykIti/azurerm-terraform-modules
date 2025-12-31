# Complete Azure DevOps Project Example

This example demonstrates a complete Azure DevOps project configuration with features, pipeline settings, tags, and dashboards.

## Features

- Project features management (boards, repos, pipelines, artifacts)
- Pipeline security settings enabled
- Project tags and dashboards

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
| <a name="module_azuredevops_project"></a> [azuredevops\_project](#module\_azuredevops\_project) | github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project | ADOPv1.1.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the Azure DevOps project. | `string` | `"ado-project-complete-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the Azure DevOps project. |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the Azure DevOps project. |
<!-- END_TF_DOCS -->
