# Azure DevOps Service Endpoints

locals {
  serviceendpoint_argocd = {
    for endpoint in var.serviceendpoint_argocd :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_artifactory = {
    for endpoint in var.serviceendpoint_artifactory :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_aws = {
    for endpoint in var.serviceendpoint_aws :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_azure_service_bus = {
    for endpoint in var.serviceendpoint_azure_service_bus :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_azurecr = {
    for endpoint in var.serviceendpoint_azurecr :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_azuredevops = {
    for endpoint in var.serviceendpoint_azuredevops :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_azurerm = {
    for endpoint in var.serviceendpoint_azurerm :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_bitbucket = {
    for endpoint in var.serviceendpoint_bitbucket :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_black_duck = {
    for endpoint in var.serviceendpoint_black_duck :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_checkmarx_one = {
    for endpoint in var.serviceendpoint_checkmarx_one :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_checkmarx_sast = {
    for endpoint in var.serviceendpoint_checkmarx_sast :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_checkmarx_sca = {
    for endpoint in var.serviceendpoint_checkmarx_sca :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_dockerregistry = {
    for endpoint in var.serviceendpoint_dockerregistry :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_dynamics_lifecycle_services = {
    for endpoint in var.serviceendpoint_dynamics_lifecycle_services :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_externaltfs = {
    for endpoint in var.serviceendpoint_externaltfs :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_gcp_terraform = {
    for endpoint in var.serviceendpoint_gcp_terraform :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_generic = {
    for endpoint in var.serviceendpoint_generic :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_generic_git = {
    for endpoint in var.serviceendpoint_generic_git :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_generic_v2 = {
    for endpoint in var.serviceendpoint_generic_v2 :
    coalesce(endpoint.key, endpoint.name) => endpoint
  }
  serviceendpoint_github = {
    for endpoint in var.serviceendpoint_github :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_github_enterprise = {
    for endpoint in var.serviceendpoint_github_enterprise :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_gitlab = {
    for endpoint in var.serviceendpoint_gitlab :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_incomingwebhook = {
    for endpoint in var.serviceendpoint_incomingwebhook :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_jenkins = {
    for endpoint in var.serviceendpoint_jenkins :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_jfrog_artifactory_v2 = {
    for endpoint in var.serviceendpoint_jfrog_artifactory_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_jfrog_distribution_v2 = {
    for endpoint in var.serviceendpoint_jfrog_distribution_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_jfrog_platform_v2 = {
    for endpoint in var.serviceendpoint_jfrog_platform_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_jfrog_xray_v2 = {
    for endpoint in var.serviceendpoint_jfrog_xray_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_kubernetes = {
    for endpoint in var.serviceendpoint_kubernetes :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_maven = {
    for endpoint in var.serviceendpoint_maven :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_nexus = {
    for endpoint in var.serviceendpoint_nexus :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_npm = {
    for endpoint in var.serviceendpoint_npm :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_nuget = {
    for endpoint in var.serviceendpoint_nuget :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_octopusdeploy = {
    for endpoint in var.serviceendpoint_octopusdeploy :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_openshift = {
    for endpoint in var.serviceendpoint_openshift :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_runpipeline = {
    for endpoint in var.serviceendpoint_runpipeline :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_servicefabric = {
    for endpoint in var.serviceendpoint_servicefabric :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_snyk = {
    for endpoint in var.serviceendpoint_snyk :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_sonarcloud = {
    for endpoint in var.serviceendpoint_sonarcloud :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_sonarqube = {
    for endpoint in var.serviceendpoint_sonarqube :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_ssh = {
    for endpoint in var.serviceendpoint_ssh :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_visualstudiomarketplace = {
    for endpoint in var.serviceendpoint_visualstudiomarketplace :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => endpoint
  }
  serviceendpoint_permissions = {
    for permission in var.serviceendpoint_permissions :
    try(
      coalesce(
        permission.key,
        format(
          "%s:%s",
          coalesce(permission.serviceendpoint_type, permission.serviceendpoint_id),
          permission.principal
        )
      ),
      permission.principal
    ) => permission
  }
}

resource "azuredevops_serviceendpoint_argocd" "argocd" {
  for_each = local.serviceendpoint_argocd

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_argocd requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_artifactory" "artifactory" {
  for_each = local.serviceendpoint_artifactory

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_artifactory requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_aws" "aws" {
  for_each = local.serviceendpoint_aws

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  access_key_id         = each.value.access_key_id
  secret_access_key     = each.value.secret_access_key
  session_token         = each.value.session_token
  role_to_assume        = each.value.role_to_assume
  role_session_name     = each.value.role_session_name
  external_id           = each.value.external_id
  description           = each.value.description
  use_oidc              = each.value.use_oidc

  lifecycle {
    precondition {
      condition = (
        each.value.use_oidc == true
        ? (
          each.value.access_key_id == null &&
          each.value.secret_access_key == null &&
          length(trimspace(coalesce(each.value.role_to_assume, ""))) > 0 &&
          length(trimspace(coalesce(each.value.role_session_name, ""))) > 0
        )
        : (
          length(trimspace(coalesce(each.value.access_key_id, ""))) > 0 &&
          length(trimspace(coalesce(each.value.secret_access_key, ""))) > 0
        )
      )
      error_message = "serviceendpoint_aws requires access_key_id/secret_access_key or OIDC with role_to_assume and role_session_name, but not both."
    }
  }
}

resource "azuredevops_serviceendpoint_azure_service_bus" "azure_service_bus" {
  for_each = local.serviceendpoint_azure_service_bus

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  queue_name            = each.value.queue_name
  connection_string     = each.value.connection_string
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
  for_each = local.serviceendpoint_azurecr

  project_id                             = var.project_id
  service_endpoint_name                  = each.value.service_endpoint_name
  resource_group                         = each.value.resource_group
  azurecr_spn_tenantid                   = each.value.azurecr_spn_tenantid
  azurecr_name                           = each.value.azurecr_name
  azurecr_subscription_id                = each.value.azurecr_subscription_id
  azurecr_subscription_name              = each.value.azurecr_subscription_name
  service_endpoint_authentication_scheme = each.value.service_endpoint_authentication_scheme
  description                            = each.value.description

  dynamic "credentials" {
    for_each = each.value.credentials == null ? [] : [each.value.credentials]
    content {
      serviceprincipalid = credentials.value.serviceprincipalid
    }
  }
}

resource "azuredevops_serviceendpoint_azuredevops" "azuredevops" {
  for_each = local.serviceendpoint_azuredevops

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  org_url               = each.value.org_url
  release_api_url       = each.value.release_api_url
  personal_access_token = each.value.personal_access_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_azurerm" "azurerm" {
  for_each = local.serviceendpoint_azurerm

  project_id                             = var.project_id
  service_endpoint_name                  = each.value.service_endpoint_name
  azurerm_spn_tenantid                   = each.value.azurerm_spn_tenantid
  serviceprincipalid                     = each.value.serviceprincipalid
  serviceprincipalkey                    = each.value.serviceprincipalkey
  serviceprincipalcertificate            = each.value.serviceprincipalcertificate
  service_endpoint_authentication_scheme = each.value.service_endpoint_authentication_scheme
  azurerm_management_group_id            = each.value.azurerm_management_group_id
  azurerm_management_group_name          = each.value.azurerm_management_group_name
  azurerm_subscription_id                = each.value.azurerm_subscription_id
  azurerm_subscription_name              = each.value.azurerm_subscription_name
  environment                            = each.value.environment
  server_url                             = each.value.server_url
  resource_group                         = each.value.resource_group
  validate                               = each.value.validate
  description                            = each.value.description

  dynamic "credentials" {
    for_each = each.value.credentials == null ? [] : [each.value.credentials]
    content {
      serviceprincipalid          = credentials.value.serviceprincipalid
      serviceprincipalkey         = credentials.value.serviceprincipalkey
      serviceprincipalcertificate = credentials.value.serviceprincipalcertificate
    }
  }

  dynamic "features" {
    for_each = each.value.features == null ? [] : [each.value.features]
    content {
      validate = features.value.validate
    }
  }

  lifecycle {
    precondition {
      condition = !(
        coalesce(each.value.serviceprincipalkey, try(each.value.credentials.serviceprincipalkey, null)) != null &&
        coalesce(each.value.serviceprincipalcertificate, try(each.value.credentials.serviceprincipalcertificate, null)) != null
      )
      error_message = "serviceendpoint_azurerm cannot set both serviceprincipalkey and serviceprincipalcertificate."
    }
    precondition {
      condition = (
        each.value.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
        ? (
          coalesce(each.value.serviceprincipalkey, try(each.value.credentials.serviceprincipalkey, null)) == null &&
          coalesce(each.value.serviceprincipalcertificate, try(each.value.credentials.serviceprincipalcertificate, null)) == null
        )
        : true
      )
      error_message = "serviceendpoint_azurerm workload identity requires omitting service principal secrets/certificates."
    }
    precondition {
      condition = (
        each.value.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
        ? true
        : (
          coalesce(each.value.serviceprincipalkey, try(each.value.credentials.serviceprincipalkey, null)) != null ||
          coalesce(each.value.serviceprincipalcertificate, try(each.value.credentials.serviceprincipalcertificate, null)) != null
        )
      )
      error_message = "serviceendpoint_azurerm requires a service principal key or certificate unless workload identity is selected."
    }
  }
}

resource "azuredevops_serviceendpoint_bitbucket" "bitbucket" {
  for_each = local.serviceendpoint_bitbucket

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_black_duck" "black_duck" {
  for_each = local.serviceendpoint_black_duck

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  api_token             = each.value.api_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_checkmarx_one" "checkmarx_one" {
  for_each = local.serviceendpoint_checkmarx_one

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  authorization_url     = each.value.authorization_url
  api_key               = each.value.api_key
  client_id             = each.value.client_id
  client_secret         = each.value.client_secret
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_checkmarx_sast" "checkmarx_sast" {
  for_each = local.serviceendpoint_checkmarx_sast

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  username              = each.value.username
  password              = each.value.password
  team                  = each.value.team
  preset                = each.value.preset
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_checkmarx_sca" "checkmarx_sca" {
  for_each = local.serviceendpoint_checkmarx_sca

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  access_control_url    = each.value.access_control_url
  server_url            = each.value.server_url
  web_app_url           = each.value.web_app_url
  account               = each.value.account
  username              = each.value.username
  password              = each.value.password
  team                  = each.value.team
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_dockerregistry" "dockerregistry" {
  for_each = local.serviceendpoint_dockerregistry

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  description           = each.value.description
  docker_registry       = each.value.docker_registry
  docker_username       = each.value.docker_username
  docker_email          = each.value.docker_email
  docker_password       = each.value.docker_password
  registry_type         = each.value.registry_type
}

resource "azuredevops_serviceendpoint_dynamics_lifecycle_services" "dynamics_lifecycle_services" {
  for_each = local.serviceendpoint_dynamics_lifecycle_services

  project_id                      = var.project_id
  service_endpoint_name           = each.value.service_endpoint_name
  authorization_endpoint          = each.value.authorization_endpoint
  lifecycle_services_api_endpoint = each.value.lifecycle_services_api_endpoint
  client_id                       = each.value.client_id
  username                        = each.value.username
  password                        = each.value.password
  description                     = each.value.description
}

resource "azuredevops_serviceendpoint_externaltfs" "externaltfs" {
  for_each = local.serviceendpoint_externaltfs

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  connection_url        = each.value.connection_url
  description           = each.value.description

  auth_personal {
    personal_access_token = each.value.auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_gcp_terraform" "gcp_terraform" {
  for_each = local.serviceendpoint_gcp_terraform

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  private_key           = each.value.private_key
  token_uri             = each.value.token_uri
  gcp_project_id        = each.value.gcp_project_id
  client_email          = each.value.client_email
  scope                 = each.value.scope
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_generic" "generic" {
  for_each = local.serviceendpoint_generic

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_generic_git" "generic_git" {
  for_each = local.serviceendpoint_generic_git

  project_id              = var.project_id
  service_endpoint_name   = each.value.service_endpoint_name
  repository_url          = each.value.repository_url
  username                = each.value.username
  password                = each.value.password
  enable_pipelines_access = each.value.enable_pipelines_access
  description             = each.value.description
}

resource "azuredevops_serviceendpoint_generic_v2" "generic_v2" {
  for_each = local.serviceendpoint_generic_v2

  project_id               = var.project_id
  name                     = each.value.name
  type                     = each.value.type
  server_url               = each.value.server_url
  authorization_scheme     = each.value.authorization_scheme
  shared_project_ids       = each.value.shared_project_ids
  description              = each.value.description
  authorization_parameters = each.value.authorization_parameters
  parameters               = each.value.parameters
}

resource "azuredevops_serviceendpoint_github" "github" {
  for_each = local.serviceendpoint_github

  project_id             = var.project_id
  service_endpoint_name  = each.value.service_endpoint_name
  description            = each.value.description
  personal_access_token  = each.value.personal_access_token
  oauth_configuration_id = each.value.oauth_configuration_id

  dynamic "auth_oauth" {
    for_each = each.value.auth_oauth == null ? [] : [each.value.auth_oauth]
    content {
      oauth_configuration_id = auth_oauth.value.oauth_configuration_id
    }
  }

  dynamic "auth_personal" {
    for_each = each.value.auth_personal == null ? [] : [each.value.auth_personal]
    content {
      personal_access_token = auth_personal.value.personal_access_token
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.auth_personal != null || each.value.personal_access_token != null) !=
        (each.value.auth_oauth != null || each.value.oauth_configuration_id != null)
      )
      error_message = "serviceendpoint_github requires exactly one of personal access token or OAuth configuration."
    }
  }
}

resource "azuredevops_serviceendpoint_github_enterprise" "github_enterprise" {
  for_each = local.serviceendpoint_github_enterprise

  project_id             = var.project_id
  service_endpoint_name  = each.value.service_endpoint_name
  description            = each.value.description
  url                    = each.value.url
  personal_access_token  = each.value.personal_access_token
  oauth_configuration_id = each.value.oauth_configuration_id

  dynamic "auth_personal" {
    for_each = each.value.auth_personal == null ? [] : [each.value.auth_personal]
    content {
      personal_access_token = auth_personal.value.personal_access_token
    }
  }

  dynamic "auth_oauth" {
    for_each = each.value.auth_oauth == null ? [] : [each.value.auth_oauth]
    content {
      oauth_configuration_id = auth_oauth.value.oauth_configuration_id
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.auth_personal != null || each.value.personal_access_token != null) !=
        (each.value.auth_oauth != null || each.value.oauth_configuration_id != null)
      )
      error_message = "serviceendpoint_github_enterprise requires exactly one of personal access token or OAuth configuration."
    }
  }
}

resource "azuredevops_serviceendpoint_gitlab" "gitlab" {
  for_each = local.serviceendpoint_gitlab

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  username              = each.value.username
  api_token             = each.value.api_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_incomingwebhook" "incomingwebhook" {
  for_each = local.serviceendpoint_incomingwebhook

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  webhook_name          = each.value.webhook_name
  description           = each.value.description
  http_header           = each.value.http_header
  secret                = each.value.secret
}

resource "azuredevops_serviceendpoint_jenkins" "jenkins" {
  for_each = local.serviceendpoint_jenkins

  project_id             = var.project_id
  service_endpoint_name  = each.value.service_endpoint_name
  url                    = each.value.url
  username               = each.value.username
  password               = each.value.password
  accept_untrusted_certs = each.value.accept_untrusted_certs
  description            = each.value.description
}

resource "azuredevops_serviceendpoint_jfrog_artifactory_v2" "jfrog_artifactory_v2" {
  for_each = local.serviceendpoint_jfrog_artifactory_v2

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_artifactory_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_distribution_v2" "jfrog_distribution_v2" {
  for_each = local.serviceendpoint_jfrog_distribution_v2

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_distribution_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_platform_v2" "jfrog_platform_v2" {
  for_each = local.serviceendpoint_jfrog_platform_v2

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_platform_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_xray_v2" "jfrog_xray_v2" {
  for_each = local.serviceendpoint_jfrog_xray_v2

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_xray_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_kubernetes" "kubernetes" {
  for_each = local.serviceendpoint_kubernetes

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  apiserver_url         = each.value.apiserver_url
  authorization_type    = each.value.authorization_type
  description           = each.value.description

  dynamic "azure_subscription" {
    for_each = each.value.azure_subscription == null ? [] : [each.value.azure_subscription]
    content {
      azure_environment = azure_subscription.value.azure_environment
      cluster_name      = azure_subscription.value.cluster_name
      subscription_id   = azure_subscription.value.subscription_id
      subscription_name = azure_subscription.value.subscription_name
      tenant_id         = azure_subscription.value.tenant_id
      resourcegroup_id  = azure_subscription.value.resourcegroup_id
      namespace         = azure_subscription.value.namespace
      cluster_admin     = azure_subscription.value.cluster_admin
    }
  }

  dynamic "kubeconfig" {
    for_each = each.value.kubeconfig == null ? [] : [each.value.kubeconfig]
    content {
      kube_config            = kubeconfig.value.kube_config
      accept_untrusted_certs = kubeconfig.value.accept_untrusted_certs
      cluster_context        = kubeconfig.value.cluster_context
    }
  }

  dynamic "service_account" {
    for_each = each.value.service_account == null ? [] : [each.value.service_account]
    content {
      token                  = service_account.value.token
      ca_cert                = service_account.value.ca_cert
      accept_untrusted_certs = service_account.value.accept_untrusted_certs
    }
  }

  lifecycle {
    precondition {
      condition = contains(["AzureSubscription", "Kubeconfig", "ServiceAccount"], each.value.authorization_type)
      error_message = "serviceendpoint_kubernetes.authorization_type must be AzureSubscription, Kubeconfig, or ServiceAccount."
    }
    precondition {
      condition = (
        each.value.authorization_type == "AzureSubscription"
        ? (each.value.azure_subscription != null && each.value.kubeconfig == null && each.value.service_account == null)
        : each.value.authorization_type == "Kubeconfig"
        ? (each.value.kubeconfig != null && each.value.azure_subscription == null && each.value.service_account == null)
        : each.value.authorization_type == "ServiceAccount"
        ? (each.value.service_account != null && each.value.azure_subscription == null && each.value.kubeconfig == null)
        : false
      )
      error_message = "serviceendpoint_kubernetes requires the authorization_type-specific block and no other auth blocks."
    }
  }
}

resource "azuredevops_serviceendpoint_maven" "maven" {
  for_each = local.serviceendpoint_maven

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  repository_id         = each.value.repository_id
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_maven requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_nexus" "nexus" {
  for_each = local.serviceendpoint_nexus

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_npm" "npm" {
  for_each = local.serviceendpoint_npm

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  access_token          = each.value.access_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_nuget" "nuget" {
  for_each = local.serviceendpoint_nuget

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  feed_url              = each.value.feed_url
  api_key               = each.value.api_key
  personal_access_token = each.value.personal_access_token
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description

  lifecycle {
    precondition {
      condition = (
        (each.value.username == null && each.value.password == null) ||
        (each.value.username != null && each.value.password != null)
      )
      error_message = "serviceendpoint_nuget requires both username and password when using basic auth."
    }
    precondition {
      condition = length(compact([
        each.value.api_key != null ? "api_key" : "",
        each.value.personal_access_token != null ? "pat" : "",
        (each.value.username != null || each.value.password != null) ? "basic" : "",
      ])) <= 1
      error_message = "serviceendpoint_nuget allows only one authentication method (api_key, personal_access_token, or username/password)."
    }
  }
}

resource "azuredevops_serviceendpoint_octopusdeploy" "octopusdeploy" {
  for_each = local.serviceendpoint_octopusdeploy

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  api_key               = each.value.api_key
  ignore_ssl_error      = each.value.ignore_ssl_error
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_openshift" "openshift" {
  for_each = local.serviceendpoint_openshift

  project_id                 = var.project_id
  service_endpoint_name      = each.value.service_endpoint_name
  server_url                 = each.value.server_url
  accept_untrusted_certs     = each.value.accept_untrusted_certs
  certificate_authority_file = each.value.certificate_authority_file
  description                = each.value.description

  dynamic "auth_basic" {
    for_each = each.value.auth_basic == null ? [] : [each.value.auth_basic]
    content {
      username = auth_basic.value.username
      password = auth_basic.value.password
    }
  }

  dynamic "auth_token" {
    for_each = each.value.auth_token == null ? [] : [each.value.auth_token]
    content {
      token = auth_token.value.token
    }
  }

  dynamic "auth_none" {
    for_each = each.value.auth_none == null ? [] : [each.value.auth_none]
    content {
      kube_config = auth_none.value.kube_config
    }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        each.value.auth_basic != null ? "basic" : "",
        each.value.auth_token != null ? "token" : "",
        each.value.auth_none != null ? "none" : "",
      ])) == 1
      error_message = "serviceendpoint_openshift requires exactly one of auth_basic, auth_token, or auth_none."
    }
  }
}

locals {
  serviceendpoint_ids = {
    argocd                      = { for key, endpoint in azuredevops_serviceendpoint_argocd.argocd : key => endpoint.id }
    artifactory                 = { for key, endpoint in azuredevops_serviceendpoint_artifactory.artifactory : key => endpoint.id }
    aws                         = { for key, endpoint in azuredevops_serviceendpoint_aws.aws : key => endpoint.id }
    azure_service_bus           = { for key, endpoint in azuredevops_serviceendpoint_azure_service_bus.azure_service_bus : key => endpoint.id }
    azurecr                     = { for key, endpoint in azuredevops_serviceendpoint_azurecr.azurecr : key => endpoint.id }
    azuredevops                 = { for key, endpoint in azuredevops_serviceendpoint_azuredevops.azuredevops : key => endpoint.id }
    azurerm                     = { for key, endpoint in azuredevops_serviceendpoint_azurerm.azurerm : key => endpoint.id }
    bitbucket                   = { for key, endpoint in azuredevops_serviceendpoint_bitbucket.bitbucket : key => endpoint.id }
    black_duck                  = { for key, endpoint in azuredevops_serviceendpoint_black_duck.black_duck : key => endpoint.id }
    checkmarx_one               = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_one.checkmarx_one : key => endpoint.id }
    checkmarx_sast              = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_sast.checkmarx_sast : key => endpoint.id }
    checkmarx_sca               = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_sca.checkmarx_sca : key => endpoint.id }
    dockerregistry              = { for key, endpoint in azuredevops_serviceendpoint_dockerregistry.dockerregistry : key => endpoint.id }
    dynamics_lifecycle_services = { for key, endpoint in azuredevops_serviceendpoint_dynamics_lifecycle_services.dynamics_lifecycle_services : key => endpoint.id }
    externaltfs                 = { for key, endpoint in azuredevops_serviceendpoint_externaltfs.externaltfs : key => endpoint.id }
    gcp_terraform               = { for key, endpoint in azuredevops_serviceendpoint_gcp_terraform.gcp_terraform : key => endpoint.id }
    generic                     = { for key, endpoint in azuredevops_serviceendpoint_generic.generic : key => endpoint.id }
    generic_git                 = { for key, endpoint in azuredevops_serviceendpoint_generic_git.generic_git : key => endpoint.id }
    generic_v2                  = { for key, endpoint in azuredevops_serviceendpoint_generic_v2.generic_v2 : key => endpoint.id }
    github                      = { for key, endpoint in azuredevops_serviceendpoint_github.github : key => endpoint.id }
    github_enterprise           = { for key, endpoint in azuredevops_serviceendpoint_github_enterprise.github_enterprise : key => endpoint.id }
    gitlab                      = { for key, endpoint in azuredevops_serviceendpoint_gitlab.gitlab : key => endpoint.id }
    incomingwebhook             = { for key, endpoint in azuredevops_serviceendpoint_incomingwebhook.incomingwebhook : key => endpoint.id }
    jenkins                     = { for key, endpoint in azuredevops_serviceendpoint_jenkins.jenkins : key => endpoint.id }
    jfrog_artifactory_v2        = { for key, endpoint in azuredevops_serviceendpoint_jfrog_artifactory_v2.jfrog_artifactory_v2 : key => endpoint.id }
    jfrog_distribution_v2       = { for key, endpoint in azuredevops_serviceendpoint_jfrog_distribution_v2.jfrog_distribution_v2 : key => endpoint.id }
    jfrog_platform_v2           = { for key, endpoint in azuredevops_serviceendpoint_jfrog_platform_v2.jfrog_platform_v2 : key => endpoint.id }
    jfrog_xray_v2               = { for key, endpoint in azuredevops_serviceendpoint_jfrog_xray_v2.jfrog_xray_v2 : key => endpoint.id }
    kubernetes                  = { for key, endpoint in azuredevops_serviceendpoint_kubernetes.kubernetes : key => endpoint.id }
    maven                       = { for key, endpoint in azuredevops_serviceendpoint_maven.maven : key => endpoint.id }
    nexus                       = { for key, endpoint in azuredevops_serviceendpoint_nexus.nexus : key => endpoint.id }
    npm                         = { for key, endpoint in azuredevops_serviceendpoint_npm.npm : key => endpoint.id }
    nuget                       = { for key, endpoint in azuredevops_serviceendpoint_nuget.nuget : key => endpoint.id }
    octopusdeploy               = { for key, endpoint in azuredevops_serviceendpoint_octopusdeploy.octopusdeploy : key => endpoint.id }
    openshift                   = { for key, endpoint in azuredevops_serviceendpoint_openshift.openshift : key => endpoint.id }
    runpipeline                 = { for key, endpoint in azuredevops_serviceendpoint_runpipeline.runpipeline : key => endpoint.id }
    servicefabric               = { for key, endpoint in azuredevops_serviceendpoint_servicefabric.servicefabric : key => endpoint.id }
    snyk                        = { for key, endpoint in azuredevops_serviceendpoint_snyk.snyk : key => endpoint.id }
    sonarcloud                  = { for key, endpoint in azuredevops_serviceendpoint_sonarcloud.sonarcloud : key => endpoint.id }
    sonarqube                   = { for key, endpoint in azuredevops_serviceendpoint_sonarqube.sonarqube : key => endpoint.id }
    ssh                         = { for key, endpoint in azuredevops_serviceendpoint_ssh.ssh : key => endpoint.id }
    visualstudiomarketplace     = { for key, endpoint in azuredevops_serviceendpoint_visualstudiomarketplace.visualstudiomarketplace : key => endpoint.id }
  }
}

resource "azuredevops_serviceendpoint_permissions" "permissions" {
  for_each = local.serviceendpoint_permissions

  project_id         = var.project_id
  principal          = each.value.principal
  permissions        = each.value.permissions
  serviceendpoint_id = coalesce(
    each.value.serviceendpoint_id,
    try(local.serviceendpoint_ids[each.value.serviceendpoint_type][each.value.serviceendpoint_key], null)
  )
  replace            = each.value.replace

  lifecycle {
    precondition {
      condition = coalesce(
        each.value.serviceendpoint_id,
        try(local.serviceendpoint_ids[each.value.serviceendpoint_type][each.value.serviceendpoint_key], null)
      ) != null
      error_message = "serviceendpoint_permissions requires a valid serviceendpoint_id or serviceendpoint_type + serviceendpoint_key reference."
    }
  }
}

resource "azuredevops_serviceendpoint_runpipeline" "runpipeline" {
  for_each = local.serviceendpoint_runpipeline

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  organization_name     = each.value.organization_name
  description           = each.value.description

  auth_personal {
    personal_access_token = each.value.auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_servicefabric" "servicefabric" {
  for_each = local.serviceendpoint_servicefabric

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  cluster_endpoint      = each.value.cluster_endpoint
  description           = each.value.description

  dynamic "certificate" {
    for_each = each.value.certificate == null ? [] : [each.value.certificate]
    content {
      server_certificate_lookup      = certificate.value.server_certificate_lookup
      server_certificate_thumbprint  = certificate.value.server_certificate_thumbprint
      server_certificate_common_name = certificate.value.server_certificate_common_name
      client_certificate             = certificate.value.client_certificate
      client_certificate_password    = certificate.value.client_certificate_password
    }
  }

  dynamic "azure_active_directory" {
    for_each = each.value.azure_active_directory == null ? [] : [each.value.azure_active_directory]
    content {
      server_certificate_lookup      = azure_active_directory.value.server_certificate_lookup
      server_certificate_thumbprint  = azure_active_directory.value.server_certificate_thumbprint
      server_certificate_common_name = azure_active_directory.value.server_certificate_common_name
      username                       = azure_active_directory.value.username
      password                       = azure_active_directory.value.password
    }
  }

  dynamic "none" {
    for_each = each.value.none == null ? [] : [each.value.none]
    content {
      unsecured   = none.value.unsecured
      cluster_spn = none.value.cluster_spn
    }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        each.value.certificate != null ? "certificate" : "",
        each.value.azure_active_directory != null ? "aad" : "",
        each.value.none != null ? "none" : "",
      ])) == 1
      error_message = "serviceendpoint_servicefabric requires exactly one of certificate, azure_active_directory, or none."
    }
  }
}

resource "azuredevops_serviceendpoint_snyk" "snyk" {
  for_each = local.serviceendpoint_snyk

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  api_token             = each.value.api_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_sonarcloud" "sonarcloud" {
  for_each = local.serviceendpoint_sonarcloud

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  token                 = each.value.token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_sonarqube" "sonarqube" {
  for_each = local.serviceendpoint_sonarqube

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  token                 = each.value.token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_ssh" "ssh" {
  for_each = local.serviceendpoint_ssh

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  host                  = each.value.host
  username              = each.value.username
  port                  = each.value.port
  password              = each.value.password
  private_key           = each.value.private_key
  description           = each.value.description

  lifecycle {
    precondition {
      condition     = (each.value.password != null) != (each.value.private_key != null)
      error_message = "serviceendpoint_ssh requires exactly one of password or private_key."
    }
  }
}

resource "azuredevops_serviceendpoint_visualstudiomarketplace" "visualstudiomarketplace" {
  for_each = local.serviceendpoint_visualstudiomarketplace

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  description           = each.value.description

  dynamic "authentication_token" {
    for_each = each.value.authentication_token == null ? [] : [each.value.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = each.value.authentication_basic == null ? [] : [each.value.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (each.value.authentication_token != null) != (each.value.authentication_basic != null)
      ) && (
        each.value.authentication_token == null || length(trimspace(each.value.authentication_token.token)) > 0
      ) && (
        each.value.authentication_basic == null || (
          length(trimspace(each.value.authentication_basic.username)) > 0 &&
          length(trimspace(each.value.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_visualstudiomarketplace requires exactly one authentication method with non-empty credentials."
    }
  }
}
