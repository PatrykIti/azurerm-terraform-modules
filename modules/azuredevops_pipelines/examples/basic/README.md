# Basic Azure DevOps Pipelines Example

This example demonstrates creating a basic YAML pipeline backed by a Git repository.

## Features

- Single Git repository with clean initialization
- Single build definition using `azure-pipelines.yml`

## Usage

```bash
terraform init
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

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_pipelines"></a> [azuredevops\_pipelines](#module\_azuredevops\_pipelines) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_git_repository.example](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/git_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pipeline_name"></a> [pipeline\_name](#input\_pipeline\_name) | Name of the pipeline. | `string` | `"ado-pipelines-basic-example"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the repository. | `string` | `"ado-pipelines-repo-basic-example"` | no |
| <a name="input_yaml_path"></a> [yaml\_path](#input\_yaml\_path) | Path to the pipeline YAML file. | `string` | `"azure-pipelines.yml"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_build_definition_id"></a> [build\_definition\_id](#output\_build\_definition\_id) | Build definition ID created by the module. |
<!-- END_TF_DOCS -->
