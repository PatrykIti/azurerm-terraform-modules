# Terraform Azure DevOps Service Endpoints Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps service endpoints module for managing service connections and permissions.

## Notes

- `serviceendpoint_azuredevops` and the deprecated `azuredevops_serviceendpoint_azuredevops` resource have been removed; use `serviceendpoint_runpipeline` instead.
- The module manages a single service endpoint per instance; use module-level `for_each` to create multiple endpoints.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "path/to/azuredevops_serviceendpoint"

  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "example-generic"
    server_url            = "https://example.endpoint.local"
    username              = "example-user"
    password              = "example-password"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a single generic service endpoint.
- [Complete](examples/complete) - This example demonstrates module-level for_each with multiple endpoint types.
- [Secure](examples/secure) - This example demonstrates a service endpoint with explicit permissions.
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
| [azuredevops_serviceendpoint_argocd.argocd](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_argocd) | resource |
| [azuredevops_serviceendpoint_artifactory.artifactory](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_artifactory) | resource |
| [azuredevops_serviceendpoint_aws.aws](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_aws) | resource |
| [azuredevops_serviceendpoint_azure_service_bus.azure_service_bus](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_azure_service_bus) | resource |
| [azuredevops_serviceendpoint_azurecr.azurecr](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_azurecr) | resource |
| [azuredevops_serviceendpoint_azurerm.azurerm](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_azurerm) | resource |
| [azuredevops_serviceendpoint_bitbucket.bitbucket](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_bitbucket) | resource |
| [azuredevops_serviceendpoint_black_duck.black_duck](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_black_duck) | resource |
| [azuredevops_serviceendpoint_checkmarx_one.checkmarx_one](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_checkmarx_one) | resource |
| [azuredevops_serviceendpoint_checkmarx_sast.checkmarx_sast](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_checkmarx_sast) | resource |
| [azuredevops_serviceendpoint_checkmarx_sca.checkmarx_sca](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_checkmarx_sca) | resource |
| [azuredevops_serviceendpoint_dockerregistry.dockerregistry](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_dockerregistry) | resource |
| [azuredevops_serviceendpoint_dynamics_lifecycle_services.dynamics_lifecycle_services](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_dynamics_lifecycle_services) | resource |
| [azuredevops_serviceendpoint_externaltfs.externaltfs](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_externaltfs) | resource |
| [azuredevops_serviceendpoint_gcp_terraform.gcp_terraform](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_gcp_terraform) | resource |
| [azuredevops_serviceendpoint_generic.generic](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_generic) | resource |
| [azuredevops_serviceendpoint_generic_git.generic_git](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_generic_git) | resource |
| [azuredevops_serviceendpoint_generic_v2.generic_v2](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_generic_v2) | resource |
| [azuredevops_serviceendpoint_github.github](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_github) | resource |
| [azuredevops_serviceendpoint_github_enterprise.github_enterprise](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_github_enterprise) | resource |
| [azuredevops_serviceendpoint_gitlab.gitlab](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_gitlab) | resource |
| [azuredevops_serviceendpoint_incomingwebhook.incomingwebhook](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_incomingwebhook) | resource |
| [azuredevops_serviceendpoint_jenkins.jenkins](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_jenkins) | resource |
| [azuredevops_serviceendpoint_jfrog_artifactory_v2.jfrog_artifactory_v2](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_jfrog_artifactory_v2) | resource |
| [azuredevops_serviceendpoint_jfrog_distribution_v2.jfrog_distribution_v2](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_jfrog_distribution_v2) | resource |
| [azuredevops_serviceendpoint_jfrog_platform_v2.jfrog_platform_v2](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_jfrog_platform_v2) | resource |
| [azuredevops_serviceendpoint_jfrog_xray_v2.jfrog_xray_v2](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_jfrog_xray_v2) | resource |
| [azuredevops_serviceendpoint_kubernetes.kubernetes](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_kubernetes) | resource |
| [azuredevops_serviceendpoint_maven.maven](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_maven) | resource |
| [azuredevops_serviceendpoint_nexus.nexus](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_nexus) | resource |
| [azuredevops_serviceendpoint_npm.npm](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_npm) | resource |
| [azuredevops_serviceendpoint_nuget.nuget](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_nuget) | resource |
| [azuredevops_serviceendpoint_octopusdeploy.octopusdeploy](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_octopusdeploy) | resource |
| [azuredevops_serviceendpoint_openshift.openshift](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_openshift) | resource |
| [azuredevops_serviceendpoint_permissions.permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_permissions) | resource |
| [azuredevops_serviceendpoint_runpipeline.runpipeline](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_runpipeline) | resource |
| [azuredevops_serviceendpoint_servicefabric.servicefabric](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_servicefabric) | resource |
| [azuredevops_serviceendpoint_snyk.snyk](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_snyk) | resource |
| [azuredevops_serviceendpoint_sonarcloud.sonarcloud](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_sonarcloud) | resource |
| [azuredevops_serviceendpoint_sonarqube.sonarqube](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_sonarqube) | resource |
| [azuredevops_serviceendpoint_ssh.ssh](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_ssh) | resource |
| [azuredevops_serviceendpoint_visualstudiomarketplace.visualstudiomarketplace](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/serviceendpoint_visualstudiomarketplace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_serviceendpoint_argocd"></a> [serviceendpoint\_argocd](#input\_serviceendpoint\_argocd) | ArgoCD service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_artifactory"></a> [serviceendpoint\_artifactory](#input\_serviceendpoint\_artifactory) | Artifactory service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_aws"></a> [serviceendpoint\_aws](#input\_serviceendpoint\_aws) | AWS service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    access_key_id         = optional(string)<br/>    secret_access_key     = optional(string)<br/>    session_token         = optional(string)<br/>    role_to_assume        = optional(string)<br/>    role_session_name     = optional(string)<br/>    external_id           = optional(string)<br/>    description           = optional(string)<br/>    use_oidc              = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_azure_service_bus"></a> [serviceendpoint\_azure\_service\_bus](#input\_serviceendpoint\_azure\_service\_bus) | Azure Service Bus service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    queue_name            = string<br/>    connection_string     = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_azurecr"></a> [serviceendpoint\_azurecr](#input\_serviceendpoint\_azurecr) | Azure Container Registry service endpoint. | <pre>object({<br/>    service_endpoint_name                  = string<br/>    resource_group                         = string<br/>    azurecr_spn_tenantid                   = string<br/>    azurecr_name                           = string<br/>    azurecr_subscription_id                = string<br/>    azurecr_subscription_name              = string<br/>    service_endpoint_authentication_scheme = optional(string)<br/>    description                            = optional(string)<br/>    credentials = optional(object({<br/>      serviceprincipalid = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_azurerm"></a> [serviceendpoint\_azurerm](#input\_serviceendpoint\_azurerm) | Azure Resource Manager service endpoint. | <pre>object({<br/>    service_endpoint_name                  = string<br/>    azurerm_spn_tenantid                   = string<br/>    serviceprincipalid                     = optional(string)<br/>    serviceprincipalkey                    = optional(string)<br/>    serviceprincipalcertificate            = optional(string)<br/>    service_endpoint_authentication_scheme = optional(string)<br/>    azurerm_management_group_id            = optional(string)<br/>    azurerm_management_group_name          = optional(string)<br/>    azurerm_subscription_id                = optional(string)<br/>    azurerm_subscription_name              = optional(string)<br/>    environment                            = optional(string)<br/>    server_url                             = optional(string)<br/>    resource_group                         = optional(string)<br/>    validate                               = optional(bool)<br/>    description                            = optional(string)<br/>    credentials = optional(object({<br/>      serviceprincipalid          = string<br/>      serviceprincipalkey         = optional(string)<br/>      serviceprincipalcertificate = optional(string)<br/>    }))<br/>    features = optional(object({<br/>      validate = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_bitbucket"></a> [serviceendpoint\_bitbucket](#input\_serviceendpoint\_bitbucket) | Bitbucket service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    username              = string<br/>    password              = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_black_duck"></a> [serviceendpoint\_black\_duck](#input\_serviceendpoint\_black\_duck) | Black Duck service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    server_url            = string<br/>    api_token             = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_checkmarx_one"></a> [serviceendpoint\_checkmarx\_one](#input\_serviceendpoint\_checkmarx\_one) | Checkmarx One service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    server_url            = string<br/>    authorization_url     = optional(string)<br/>    api_key               = optional(string)<br/>    client_id             = optional(string)<br/>    client_secret         = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_checkmarx_sast"></a> [serviceendpoint\_checkmarx\_sast](#input\_serviceendpoint\_checkmarx\_sast) | Checkmarx SAST service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    server_url            = string<br/>    username              = string<br/>    password              = string<br/>    team                  = optional(string)<br/>    preset                = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_checkmarx_sca"></a> [serviceendpoint\_checkmarx\_sca](#input\_serviceendpoint\_checkmarx\_sca) | Checkmarx SCA service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    access_control_url    = string<br/>    server_url            = string<br/>    web_app_url           = string<br/>    account               = string<br/>    username              = string<br/>    password              = string<br/>    team                  = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_dockerregistry"></a> [serviceendpoint\_dockerregistry](#input\_serviceendpoint\_dockerregistry) | Docker registry service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    description           = optional(string)<br/>    docker_registry       = optional(string)<br/>    docker_username       = optional(string)<br/>    docker_email          = optional(string)<br/>    docker_password       = optional(string)<br/>    registry_type         = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_dynamics_lifecycle_services"></a> [serviceendpoint\_dynamics\_lifecycle\_services](#input\_serviceendpoint\_dynamics\_lifecycle\_services) | Dynamics Lifecycle Services service endpoint. | <pre>object({<br/>    service_endpoint_name           = string<br/>    authorization_endpoint          = string<br/>    lifecycle_services_api_endpoint = string<br/>    client_id                       = string<br/>    username                        = string<br/>    password                        = string<br/>    description                     = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_externaltfs"></a> [serviceendpoint\_externaltfs](#input\_serviceendpoint\_externaltfs) | External TFS service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    connection_url        = string<br/>    description           = optional(string)<br/>    auth_personal = object({<br/>      personal_access_token = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_gcp_terraform"></a> [serviceendpoint\_gcp\_terraform](#input\_serviceendpoint\_gcp\_terraform) | GCP Terraform service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    private_key           = string<br/>    token_uri             = string<br/>    gcp_project_id        = string<br/>    client_email          = optional(string)<br/>    scope                 = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_generic"></a> [serviceendpoint\_generic](#input\_serviceendpoint\_generic) | Generic service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    server_url            = string<br/>    username              = optional(string)<br/>    password              = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_generic_git"></a> [serviceendpoint\_generic\_git](#input\_serviceendpoint\_generic\_git) | Generic Git service endpoint. | <pre>object({<br/>    service_endpoint_name   = string<br/>    repository_url          = string<br/>    username                = optional(string)<br/>    password                = optional(string)<br/>    enable_pipelines_access = optional(bool)<br/>    description             = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_generic_v2"></a> [serviceendpoint\_generic\_v2](#input\_serviceendpoint\_generic\_v2) | Generic v2 service endpoint. | <pre>object({<br/>    name                     = string<br/>    type                     = string<br/>    server_url               = string<br/>    authorization_scheme     = string<br/>    shared_project_ids       = optional(list(string))<br/>    description              = optional(string)<br/>    authorization_parameters = optional(map(string))<br/>    parameters               = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_github"></a> [serviceendpoint\_github](#input\_serviceendpoint\_github) | GitHub service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    description           = optional(string)<br/>    auth_oauth = optional(object({<br/>      oauth_configuration_id = string<br/>    }))<br/>    auth_personal = optional(object({<br/>      personal_access_token = string<br/>    }))<br/>    personal_access_token  = optional(string)<br/>    oauth_configuration_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_github_enterprise"></a> [serviceendpoint\_github\_enterprise](#input\_serviceendpoint\_github\_enterprise) | GitHub Enterprise service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    description           = optional(string)<br/>    url                   = optional(string)<br/>    auth_personal = optional(object({<br/>      personal_access_token = string<br/>    }))<br/>    auth_oauth = optional(object({<br/>      oauth_configuration_id = string<br/>    }))<br/>    personal_access_token  = optional(string)<br/>    oauth_configuration_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_gitlab"></a> [serviceendpoint\_gitlab](#input\_serviceendpoint\_gitlab) | GitLab service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    username              = string<br/>    api_token             = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_incomingwebhook"></a> [serviceendpoint\_incomingwebhook](#input\_serviceendpoint\_incomingwebhook) | Incoming webhook service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    webhook_name          = string<br/>    description           = optional(string)<br/>    http_header           = optional(string)<br/>    secret                = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_jenkins"></a> [serviceendpoint\_jenkins](#input\_serviceendpoint\_jenkins) | Jenkins service endpoint. | <pre>object({<br/>    service_endpoint_name  = string<br/>    url                    = string<br/>    username               = string<br/>    password               = string<br/>    accept_untrusted_certs = optional(bool)<br/>    description            = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_jfrog_artifactory_v2"></a> [serviceendpoint\_jfrog\_artifactory\_v2](#input\_serviceendpoint\_jfrog\_artifactory\_v2) | JFrog Artifactory v2 service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_jfrog_distribution_v2"></a> [serviceendpoint\_jfrog\_distribution\_v2](#input\_serviceendpoint\_jfrog\_distribution\_v2) | JFrog Distribution v2 service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_jfrog_platform_v2"></a> [serviceendpoint\_jfrog\_platform\_v2](#input\_serviceendpoint\_jfrog\_platform\_v2) | JFrog Platform v2 service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_jfrog_xray_v2"></a> [serviceendpoint\_jfrog\_xray\_v2](#input\_serviceendpoint\_jfrog\_xray\_v2) | JFrog Xray v2 service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_kubernetes"></a> [serviceendpoint\_kubernetes](#input\_serviceendpoint\_kubernetes) | Kubernetes service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    apiserver_url         = string<br/>    authorization_type    = string<br/>    description           = optional(string)<br/>    azure_subscription = optional(object({<br/>      azure_environment = optional(string)<br/>      cluster_name      = string<br/>      subscription_id   = string<br/>      subscription_name = string<br/>      tenant_id         = string<br/>      resourcegroup_id  = string<br/>      namespace         = optional(string)<br/>      cluster_admin     = optional(bool)<br/>    }))<br/>    kubeconfig = optional(object({<br/>      kube_config            = string<br/>      accept_untrusted_certs = optional(bool)<br/>      cluster_context        = optional(string)<br/>    }))<br/>    service_account = optional(object({<br/>      token                  = string<br/>      ca_cert                = string<br/>      accept_untrusted_certs = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_maven"></a> [serviceendpoint\_maven](#input\_serviceendpoint\_maven) | Maven service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    repository_id         = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_nexus"></a> [serviceendpoint\_nexus](#input\_serviceendpoint\_nexus) | Nexus service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    username              = string<br/>    password              = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_npm"></a> [serviceendpoint\_npm](#input\_serviceendpoint\_npm) | NPM service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    access_token          = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_nuget"></a> [serviceendpoint\_nuget](#input\_serviceendpoint\_nuget) | NuGet service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    feed_url              = string<br/>    api_key               = optional(string)<br/>    personal_access_token = optional(string)<br/>    username              = optional(string)<br/>    password              = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_octopusdeploy"></a> [serviceendpoint\_octopusdeploy](#input\_serviceendpoint\_octopusdeploy) | Octopus Deploy service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    api_key               = string<br/>    ignore_ssl_error      = optional(bool)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_openshift"></a> [serviceendpoint\_openshift](#input\_serviceendpoint\_openshift) | OpenShift service endpoint. | <pre>object({<br/>    service_endpoint_name      = string<br/>    server_url                 = optional(string)<br/>    accept_untrusted_certs     = optional(bool)<br/>    certificate_authority_file = optional(string)<br/>    description                = optional(string)<br/>    auth_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>    auth_token = optional(object({<br/>      token = string<br/>    }))<br/>    auth_none = optional(object({<br/>      kube_config = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_permissions"></a> [serviceendpoint\_permissions](#input\_serviceendpoint\_permissions) | List of service endpoint permissions to assign. | <pre>list(object({<br/>    key                = optional(string)<br/>    serviceendpoint_id = optional(string)<br/>    principal          = string<br/>    permissions        = map(string)<br/>    replace            = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_serviceendpoint_runpipeline"></a> [serviceendpoint\_runpipeline](#input\_serviceendpoint\_runpipeline) | Run pipeline service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    organization_name     = string<br/>    description           = optional(string)<br/>    auth_personal = object({<br/>      personal_access_token = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_servicefabric"></a> [serviceendpoint\_servicefabric](#input\_serviceendpoint\_servicefabric) | Service Fabric service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    cluster_endpoint      = string<br/>    description           = optional(string)<br/>    certificate = optional(object({<br/>      server_certificate_lookup      = string<br/>      server_certificate_thumbprint  = optional(string)<br/>      server_certificate_common_name = optional(string)<br/>      client_certificate             = string<br/>      client_certificate_password    = optional(string)<br/>    }))<br/>    azure_active_directory = optional(object({<br/>      server_certificate_lookup      = string<br/>      server_certificate_thumbprint  = optional(string)<br/>      server_certificate_common_name = optional(string)<br/>      username                       = string<br/>      password                       = string<br/>    }))<br/>    none = optional(object({<br/>      unsecured   = optional(bool)<br/>      cluster_spn = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_snyk"></a> [serviceendpoint\_snyk](#input\_serviceendpoint\_snyk) | Snyk service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    server_url            = string<br/>    api_token             = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_sonarcloud"></a> [serviceendpoint\_sonarcloud](#input\_serviceendpoint\_sonarcloud) | SonarCloud service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    token                 = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_sonarqube"></a> [serviceendpoint\_sonarqube](#input\_serviceendpoint\_sonarqube) | SonarQube service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    token                 = string<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_ssh"></a> [serviceendpoint\_ssh](#input\_serviceendpoint\_ssh) | SSH service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    host                  = string<br/>    username              = string<br/>    port                  = optional(number)<br/>    password              = optional(string)<br/>    private_key           = optional(string)<br/>    description           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_serviceendpoint_visualstudiomarketplace"></a> [serviceendpoint\_visualstudiomarketplace](#input\_serviceendpoint\_visualstudiomarketplace) | Visual Studio Marketplace service endpoint. | <pre>object({<br/>    service_endpoint_name = string<br/>    url                   = string<br/>    description           = optional(string)<br/>    authentication_token = optional(object({<br/>      token = string<br/>    }))<br/>    authentication_basic = optional(object({<br/>      username = string<br/>      password = string<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permissions"></a> [permissions](#output\_permissions) | Map of service endpoint permission IDs keyed by permission key. |
| <a name="output_serviceendpoint_id"></a> [serviceendpoint\_id](#output\_serviceendpoint\_id) | Service endpoint ID created by the module. |
| <a name="output_serviceendpoint_name"></a> [serviceendpoint\_name](#output\_serviceendpoint\_name) | Service endpoint name created by the module. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/IMPORT.md](docs/IMPORT.md) - Import existing service endpoints into the module
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
