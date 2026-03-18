# Secure Azure DevOps Pipelines Example

This example demonstrates a pipeline with strict-child permissions and explicit resource authorizations.

## Features

- Build definition permissions scoped to administrators
- Explicit service endpoint authorization

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
| [azuredevops_serviceendpoint_generic.example](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_generic) | resource |
| [azuredevops_group.project_collection_admins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pipeline_name"></a> [pipeline\_name](#input\_pipeline\_name) | Name of the pipeline. | `string` | `"ado-pipelines-secure-example"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the repository. | `string` | `"ado-pipelines-repo-secure-example"` | no |
| <a name="input_service_endpoint_name"></a> [service\_endpoint\_name](#input\_service\_endpoint\_name) | Name of the service endpoint. | `string` | `"ado-pipelines-endpoint-secure-example"` | no |
| <a name="input_service_endpoint_password"></a> [service\_endpoint\_password](#input\_service\_endpoint\_password) | Service endpoint password. | `string` | n/a | yes |
| <a name="input_service_endpoint_url"></a> [service\_endpoint\_url](#input\_service\_endpoint\_url) | Service endpoint URL. | `string` | `"https://example.endpoint.local"` | no |
| <a name="input_service_endpoint_username"></a> [service\_endpoint\_username](#input\_service\_endpoint\_username) | Service endpoint username. | `string` | `"example-user"` | no |
| <a name="input_yaml_path"></a> [yaml\_path](#input\_yaml\_path) | Path to the pipeline YAML file. | `string` | `"azure-pipelines.yml"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_build_definition_id"></a> [build\_definition\_id](#output\_build\_definition\_id) | Build definition ID created by the module. |
<!-- END_TF_DOCS -->
