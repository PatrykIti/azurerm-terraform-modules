# Azure DevOps Service Endpoints Module Documentation

## Overview

This module manages Azure DevOps azure devops service endpoints resources and related configuration.

## Managed Resources

- `azuredevops_serviceendpoint_argocd`
- `azuredevops_serviceendpoint_artifactory`
- `azuredevops_serviceendpoint_aws`
- `azuredevops_serviceendpoint_azure_service_bus`
- `azuredevops_serviceendpoint_azurecr`
- `azuredevops_serviceendpoint_azurerm`
- `azuredevops_serviceendpoint_bitbucket`
- `azuredevops_serviceendpoint_black_duck`
- `azuredevops_serviceendpoint_checkmarx_one`
- `azuredevops_serviceendpoint_checkmarx_sast`
- `azuredevops_serviceendpoint_checkmarx_sca`
- `azuredevops_serviceendpoint_dockerregistry`
- `azuredevops_serviceendpoint_dynamics_lifecycle_services`
- `azuredevops_serviceendpoint_externaltfs`
- `azuredevops_serviceendpoint_gcp_terraform`
- `azuredevops_serviceendpoint_generic`
- `azuredevops_serviceendpoint_generic_git`
- `azuredevops_serviceendpoint_generic_v2`
- `azuredevops_serviceendpoint_github`
- `azuredevops_serviceendpoint_github_enterprise`
- `azuredevops_serviceendpoint_gitlab`
- `azuredevops_serviceendpoint_incomingwebhook`
- `azuredevops_serviceendpoint_jenkins`
- `azuredevops_serviceendpoint_jfrog_artifactory_v2`
- `azuredevops_serviceendpoint_jfrog_distribution_v2`
- `azuredevops_serviceendpoint_jfrog_platform_v2`
- `azuredevops_serviceendpoint_jfrog_xray_v2`
- `azuredevops_serviceendpoint_kubernetes`
- `azuredevops_serviceendpoint_maven`
- `azuredevops_serviceendpoint_nexus`
- `azuredevops_serviceendpoint_npm`
- `azuredevops_serviceendpoint_nuget`
- `azuredevops_serviceendpoint_octopusdeploy`
- `azuredevops_serviceendpoint_openshift`
- `azuredevops_serviceendpoint_permissions`
- `azuredevops_serviceendpoint_runpipeline`
- `azuredevops_serviceendpoint_servicefabric`
- `azuredevops_serviceendpoint_snyk`
- `azuredevops_serviceendpoint_sonarcloud`
- `azuredevops_serviceendpoint_sonarqube`
- `azuredevops_serviceendpoint_ssh`
- `azuredevops_serviceendpoint_visualstudiomarketplace`

## Usage Notes

- Requires `project_id` for project scoping.
- Use `git::https://...//modules/azuredevops_serviceendpoint?ref=ADOSEvX.Y.Z` for module source.
- Optional child resources are created only when corresponding inputs are set.
- Use stable keys and unique names for list/object inputs to avoid address churn.

## Inputs (Highlights)

- Required: `project_id`
- Optional: see `../README.md` and `../variables.tf`.

## Outputs (Highlights)

- `permissions`
- `serviceendpoint_id`
- `serviceendpoint_name`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.

## Troubleshooting

- **Permission errors**: ensure the PAT has rights for the target resource scope.
- **Plan drift**: align inputs with existing state or leave optional inputs unset.
- **Duplicate keys**: ensure list/object inputs use unique keys or names.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
