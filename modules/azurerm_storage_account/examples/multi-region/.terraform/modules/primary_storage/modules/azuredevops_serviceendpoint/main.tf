# Azure DevOps Service Endpoints

locals {
  serviceendpoint_azurerm_credentials = var.serviceendpoint_azurerm == null ? null : {
    serviceprincipalid = coalesce(
      try(var.serviceendpoint_azurerm.credentials.serviceprincipalid, null),
      var.serviceendpoint_azurerm.serviceprincipalid,
      null
    )
    serviceprincipalkey = coalesce(
      try(var.serviceendpoint_azurerm.credentials.serviceprincipalkey, null),
      var.serviceendpoint_azurerm.serviceprincipalkey,
      null
    )
    serviceprincipalcertificate = coalesce(
      try(var.serviceendpoint_azurerm.credentials.serviceprincipalcertificate, null),
      var.serviceendpoint_azurerm.serviceprincipalcertificate,
      null
    )
  }

  serviceendpoint_azurerm_features = var.serviceendpoint_azurerm == null ? null : {
    validate = coalesce(
      try(var.serviceendpoint_azurerm.features.validate, null),
      var.serviceendpoint_azurerm.validate,
      null
    )
  }

  serviceendpoint_github_auth_personal = var.serviceendpoint_github == null ? null : (
    var.serviceendpoint_github.auth_personal != null ? var.serviceendpoint_github.auth_personal :
    var.serviceendpoint_github.personal_access_token != null ? { personal_access_token = var.serviceendpoint_github.personal_access_token } :
    null
  )
  serviceendpoint_github_auth_oauth = var.serviceendpoint_github == null ? null : (
    var.serviceendpoint_github.auth_oauth != null ? var.serviceendpoint_github.auth_oauth :
    var.serviceendpoint_github.oauth_configuration_id != null ? { oauth_configuration_id = var.serviceendpoint_github.oauth_configuration_id } :
    null
  )
  serviceendpoint_github_enterprise_auth_personal = var.serviceendpoint_github_enterprise == null ? null : (
    var.serviceendpoint_github_enterprise.auth_personal != null ? var.serviceendpoint_github_enterprise.auth_personal :
    var.serviceendpoint_github_enterprise.personal_access_token != null ? { personal_access_token = var.serviceendpoint_github_enterprise.personal_access_token } :
    null
  )
  serviceendpoint_github_enterprise_auth_oauth = var.serviceendpoint_github_enterprise == null ? null : (
    var.serviceendpoint_github_enterprise.auth_oauth != null ? var.serviceendpoint_github_enterprise.auth_oauth :
    var.serviceendpoint_github_enterprise.oauth_configuration_id != null ? { oauth_configuration_id = var.serviceendpoint_github_enterprise.oauth_configuration_id } :
    null
  )

  serviceendpoint_permissions = {
    for permission in var.serviceendpoint_permissions : coalesce(permission.key, permission.principal) => permission
  }
}

resource "azuredevops_serviceendpoint_argocd" "argocd" {
  count = var.serviceendpoint_argocd == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_argocd.service_endpoint_name
  url                   = var.serviceendpoint_argocd.url
  description           = var.serviceendpoint_argocd.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_argocd.authentication_token == null ? [] : [var.serviceendpoint_argocd.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_argocd.authentication_basic == null ? [] : [var.serviceendpoint_argocd.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_argocd.authentication_token != null) != (var.serviceendpoint_argocd.authentication_basic != null)
        ) && (
        var.serviceendpoint_argocd.authentication_token == null || length(trimspace(var.serviceendpoint_argocd.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_argocd.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_argocd.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_argocd.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_argocd requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_artifactory" "artifactory" {
  count = var.serviceendpoint_artifactory == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_artifactory.service_endpoint_name
  url                   = var.serviceendpoint_artifactory.url
  description           = var.serviceendpoint_artifactory.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_artifactory.authentication_token == null ? [] : [var.serviceendpoint_artifactory.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_artifactory.authentication_basic == null ? [] : [var.serviceendpoint_artifactory.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_artifactory.authentication_token != null) != (var.serviceendpoint_artifactory.authentication_basic != null)
        ) && (
        var.serviceendpoint_artifactory.authentication_token == null || length(trimspace(var.serviceendpoint_artifactory.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_artifactory.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_artifactory.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_artifactory.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_artifactory requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_aws" "aws" {
  count = var.serviceendpoint_aws == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_aws.service_endpoint_name
  access_key_id         = var.serviceendpoint_aws.access_key_id
  secret_access_key     = var.serviceendpoint_aws.secret_access_key
  session_token         = var.serviceendpoint_aws.session_token
  role_to_assume        = var.serviceendpoint_aws.role_to_assume
  role_session_name     = var.serviceendpoint_aws.role_session_name
  external_id           = var.serviceendpoint_aws.external_id
  description           = var.serviceendpoint_aws.description
  use_oidc              = var.serviceendpoint_aws.use_oidc

  lifecycle {
    precondition {
      condition = (
        var.serviceendpoint_aws.use_oidc == true
        ? (
          var.serviceendpoint_aws.access_key_id == null &&
          var.serviceendpoint_aws.secret_access_key == null &&
          length(trimspace(coalesce(var.serviceendpoint_aws.role_to_assume, ""))) > 0 &&
          length(trimspace(coalesce(var.serviceendpoint_aws.role_session_name, ""))) > 0
        )
        : (
          length(trimspace(coalesce(var.serviceendpoint_aws.access_key_id, ""))) > 0 &&
          length(trimspace(coalesce(var.serviceendpoint_aws.secret_access_key, ""))) > 0
        )
      )
      error_message = "serviceendpoint_aws requires access_key_id/secret_access_key or OIDC with role_to_assume and role_session_name, but not both."
    }
  }
}

resource "azuredevops_serviceendpoint_azure_service_bus" "azure_service_bus" {
  count = var.serviceendpoint_azure_service_bus == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_azure_service_bus.service_endpoint_name
  queue_name            = var.serviceendpoint_azure_service_bus.queue_name
  connection_string     = var.serviceendpoint_azure_service_bus.connection_string
  description           = var.serviceendpoint_azure_service_bus.description
}

resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
  count = var.serviceendpoint_azurecr == null ? 0 : 1

  project_id                             = var.project_id
  service_endpoint_name                  = var.serviceendpoint_azurecr.service_endpoint_name
  resource_group                         = var.serviceendpoint_azurecr.resource_group
  azurecr_spn_tenantid                   = var.serviceendpoint_azurecr.azurecr_spn_tenantid
  azurecr_name                           = var.serviceendpoint_azurecr.azurecr_name
  azurecr_subscription_id                = var.serviceendpoint_azurecr.azurecr_subscription_id
  azurecr_subscription_name              = var.serviceendpoint_azurecr.azurecr_subscription_name
  service_endpoint_authentication_scheme = var.serviceendpoint_azurecr.service_endpoint_authentication_scheme
  description                            = var.serviceendpoint_azurecr.description

  dynamic "credentials" {
    for_each = var.serviceendpoint_azurecr.credentials == null ? [] : [var.serviceendpoint_azurecr.credentials]
    content {
      serviceprincipalid = credentials.value.serviceprincipalid
    }
  }
}

resource "azuredevops_serviceendpoint_azurerm" "azurerm" {
  count = var.serviceendpoint_azurerm == null ? 0 : 1

  project_id                             = var.project_id
  service_endpoint_name                  = var.serviceendpoint_azurerm.service_endpoint_name
  azurerm_spn_tenantid                   = var.serviceendpoint_azurerm.azurerm_spn_tenantid
  service_endpoint_authentication_scheme = var.serviceendpoint_azurerm.service_endpoint_authentication_scheme
  azurerm_management_group_id            = var.serviceendpoint_azurerm.azurerm_management_group_id
  azurerm_management_group_name          = var.serviceendpoint_azurerm.azurerm_management_group_name
  azurerm_subscription_id                = var.serviceendpoint_azurerm.azurerm_subscription_id
  azurerm_subscription_name              = var.serviceendpoint_azurerm.azurerm_subscription_name
  environment                            = var.serviceendpoint_azurerm.environment
  server_url                             = var.serviceendpoint_azurerm.server_url
  resource_group                         = var.serviceendpoint_azurerm.resource_group
  description                            = var.serviceendpoint_azurerm.description

  dynamic "credentials" {
    for_each = (
      local.serviceendpoint_azurerm_credentials.serviceprincipalid == null &&
      local.serviceendpoint_azurerm_credentials.serviceprincipalkey == null &&
      local.serviceendpoint_azurerm_credentials.serviceprincipalcertificate == null
    ) ? [] : [local.serviceendpoint_azurerm_credentials]
    content {
      serviceprincipalid          = credentials.value.serviceprincipalid
      serviceprincipalkey         = credentials.value.serviceprincipalkey
      serviceprincipalcertificate = credentials.value.serviceprincipalcertificate
    }
  }

  dynamic "features" {
    for_each = local.serviceendpoint_azurerm_features.validate == null ? [] : [local.serviceendpoint_azurerm_features]
    content {
      validate = features.value.validate
    }
  }

  lifecycle {
    precondition {
      condition     = length(trimspace(coalesce(local.serviceendpoint_azurerm_credentials.serviceprincipalid, ""))) > 0
      error_message = "serviceendpoint_azurerm requires a non-empty service principal ID."
    }
    precondition {
      condition = !(
        local.serviceendpoint_azurerm_credentials.serviceprincipalkey != null &&
        local.serviceendpoint_azurerm_credentials.serviceprincipalcertificate != null
      )
      error_message = "serviceendpoint_azurerm cannot set both serviceprincipalkey and serviceprincipalcertificate."
    }
    precondition {
      condition = (
        var.serviceendpoint_azurerm.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
        ? (
          local.serviceendpoint_azurerm_credentials.serviceprincipalkey == null &&
          local.serviceendpoint_azurerm_credentials.serviceprincipalcertificate == null
        )
        : true
      )
      error_message = "serviceendpoint_azurerm workload identity requires omitting service principal secrets/certificates."
    }
    precondition {
      condition = (
        var.serviceendpoint_azurerm.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
        ? true
        : (
          local.serviceendpoint_azurerm_credentials.serviceprincipalkey != null ||
          local.serviceendpoint_azurerm_credentials.serviceprincipalcertificate != null
        )
      )
      error_message = "serviceendpoint_azurerm requires a service principal key or certificate unless workload identity is selected."
    }
  }
}

resource "azuredevops_serviceendpoint_bitbucket" "bitbucket" {
  count = var.serviceendpoint_bitbucket == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_bitbucket.service_endpoint_name
  username              = var.serviceendpoint_bitbucket.username
  password              = var.serviceendpoint_bitbucket.password
  description           = var.serviceendpoint_bitbucket.description
}

resource "azuredevops_serviceendpoint_black_duck" "black_duck" {
  count = var.serviceendpoint_black_duck == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_black_duck.service_endpoint_name
  server_url            = var.serviceendpoint_black_duck.server_url
  api_token             = var.serviceendpoint_black_duck.api_token
  description           = var.serviceendpoint_black_duck.description
}

resource "azuredevops_serviceendpoint_checkmarx_one" "checkmarx_one" {
  count = var.serviceendpoint_checkmarx_one == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_checkmarx_one.service_endpoint_name
  server_url            = var.serviceendpoint_checkmarx_one.server_url
  authorization_url     = var.serviceendpoint_checkmarx_one.authorization_url
  api_key               = var.serviceendpoint_checkmarx_one.api_key
  client_id             = var.serviceendpoint_checkmarx_one.client_id
  client_secret         = var.serviceendpoint_checkmarx_one.client_secret
  description           = var.serviceendpoint_checkmarx_one.description
}

resource "azuredevops_serviceendpoint_checkmarx_sast" "checkmarx_sast" {
  count = var.serviceendpoint_checkmarx_sast == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_checkmarx_sast.service_endpoint_name
  server_url            = var.serviceendpoint_checkmarx_sast.server_url
  username              = var.serviceendpoint_checkmarx_sast.username
  password              = var.serviceendpoint_checkmarx_sast.password
  team                  = var.serviceendpoint_checkmarx_sast.team
  preset                = var.serviceendpoint_checkmarx_sast.preset
  description           = var.serviceendpoint_checkmarx_sast.description
}

resource "azuredevops_serviceendpoint_checkmarx_sca" "checkmarx_sca" {
  count = var.serviceendpoint_checkmarx_sca == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_checkmarx_sca.service_endpoint_name
  access_control_url    = var.serviceendpoint_checkmarx_sca.access_control_url
  server_url            = var.serviceendpoint_checkmarx_sca.server_url
  web_app_url           = var.serviceendpoint_checkmarx_sca.web_app_url
  account               = var.serviceendpoint_checkmarx_sca.account
  username              = var.serviceendpoint_checkmarx_sca.username
  password              = var.serviceendpoint_checkmarx_sca.password
  team                  = var.serviceendpoint_checkmarx_sca.team
  description           = var.serviceendpoint_checkmarx_sca.description
}

resource "azuredevops_serviceendpoint_dockerregistry" "dockerregistry" {
  count = var.serviceendpoint_dockerregistry == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_dockerregistry.service_endpoint_name
  description           = var.serviceendpoint_dockerregistry.description
  docker_registry       = var.serviceendpoint_dockerregistry.docker_registry
  docker_username       = var.serviceendpoint_dockerregistry.docker_username
  docker_email          = var.serviceendpoint_dockerregistry.docker_email
  docker_password       = var.serviceendpoint_dockerregistry.docker_password
  registry_type         = var.serviceendpoint_dockerregistry.registry_type
}

resource "azuredevops_serviceendpoint_dynamics_lifecycle_services" "dynamics_lifecycle_services" {
  count = var.serviceendpoint_dynamics_lifecycle_services == null ? 0 : 1

  project_id                      = var.project_id
  service_endpoint_name           = var.serviceendpoint_dynamics_lifecycle_services.service_endpoint_name
  authorization_endpoint          = var.serviceendpoint_dynamics_lifecycle_services.authorization_endpoint
  lifecycle_services_api_endpoint = var.serviceendpoint_dynamics_lifecycle_services.lifecycle_services_api_endpoint
  client_id                       = var.serviceendpoint_dynamics_lifecycle_services.client_id
  username                        = var.serviceendpoint_dynamics_lifecycle_services.username
  password                        = var.serviceendpoint_dynamics_lifecycle_services.password
  description                     = var.serviceendpoint_dynamics_lifecycle_services.description
}

resource "azuredevops_serviceendpoint_externaltfs" "externaltfs" {
  count = var.serviceendpoint_externaltfs == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_externaltfs.service_endpoint_name
  connection_url        = var.serviceendpoint_externaltfs.connection_url
  description           = var.serviceendpoint_externaltfs.description

  auth_personal {
    personal_access_token = var.serviceendpoint_externaltfs.auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_gcp_terraform" "gcp_terraform" {
  count = var.serviceendpoint_gcp_terraform == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_gcp_terraform.service_endpoint_name
  private_key           = var.serviceendpoint_gcp_terraform.private_key
  token_uri             = var.serviceendpoint_gcp_terraform.token_uri
  gcp_project_id        = var.serviceendpoint_gcp_terraform.gcp_project_id
  client_email          = var.serviceendpoint_gcp_terraform.client_email
  scope                 = var.serviceendpoint_gcp_terraform.scope
  description           = var.serviceendpoint_gcp_terraform.description
}

resource "azuredevops_serviceendpoint_generic" "generic" {
  count = var.serviceendpoint_generic == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_generic.service_endpoint_name
  server_url            = var.serviceendpoint_generic.server_url
  username              = var.serviceendpoint_generic.username
  password              = var.serviceendpoint_generic.password
  description           = var.serviceendpoint_generic.description
}

resource "azuredevops_serviceendpoint_generic_git" "generic_git" {
  count = var.serviceendpoint_generic_git == null ? 0 : 1

  project_id              = var.project_id
  service_endpoint_name   = var.serviceendpoint_generic_git.service_endpoint_name
  repository_url          = var.serviceendpoint_generic_git.repository_url
  username                = var.serviceendpoint_generic_git.username
  password                = var.serviceendpoint_generic_git.password
  enable_pipelines_access = var.serviceendpoint_generic_git.enable_pipelines_access
  description             = var.serviceendpoint_generic_git.description
}

resource "azuredevops_serviceendpoint_generic_v2" "generic_v2" {
  count = var.serviceendpoint_generic_v2 == null ? 0 : 1

  project_id               = var.project_id
  name                     = var.serviceendpoint_generic_v2.name
  type                     = var.serviceendpoint_generic_v2.type
  server_url               = var.serviceendpoint_generic_v2.server_url
  authorization_scheme     = var.serviceendpoint_generic_v2.authorization_scheme
  shared_project_ids       = var.serviceendpoint_generic_v2.shared_project_ids
  description              = var.serviceendpoint_generic_v2.description
  authorization_parameters = var.serviceendpoint_generic_v2.authorization_parameters
  parameters               = var.serviceendpoint_generic_v2.parameters
}

resource "azuredevops_serviceendpoint_github" "github" {
  count = var.serviceendpoint_github == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_github.service_endpoint_name
  description           = var.serviceendpoint_github.description

  dynamic "auth_oauth" {
    for_each = local.serviceendpoint_github_auth_oauth == null ? [] : [local.serviceendpoint_github_auth_oauth]
    content {
      oauth_configuration_id = auth_oauth.value.oauth_configuration_id
    }
  }

  dynamic "auth_personal" {
    for_each = local.serviceendpoint_github_auth_personal == null ? [] : [local.serviceendpoint_github_auth_personal]
    content {
      personal_access_token = auth_personal.value.personal_access_token
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_github_auth_personal != null) !=
        (local.serviceendpoint_github_auth_oauth != null)
      )
      error_message = "serviceendpoint_github requires exactly one of personal access token or OAuth configuration."
    }
  }
}

resource "azuredevops_serviceendpoint_github_enterprise" "github_enterprise" {
  count = var.serviceendpoint_github_enterprise == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_github_enterprise.service_endpoint_name
  description           = var.serviceendpoint_github_enterprise.description
  url                   = var.serviceendpoint_github_enterprise.url

  dynamic "auth_personal" {
    for_each = local.serviceendpoint_github_enterprise_auth_personal == null ? [] : [local.serviceendpoint_github_enterprise_auth_personal]
    content {
      personal_access_token = auth_personal.value.personal_access_token
    }
  }

  dynamic "auth_oauth" {
    for_each = local.serviceendpoint_github_enterprise_auth_oauth == null ? [] : [local.serviceendpoint_github_enterprise_auth_oauth]
    content {
      oauth_configuration_id = auth_oauth.value.oauth_configuration_id
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_github_enterprise_auth_personal != null) !=
        (local.serviceendpoint_github_enterprise_auth_oauth != null)
      )
      error_message = "serviceendpoint_github_enterprise requires exactly one of personal access token or OAuth configuration."
    }
  }
}

resource "azuredevops_serviceendpoint_gitlab" "gitlab" {
  count = var.serviceendpoint_gitlab == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_gitlab.service_endpoint_name
  url                   = var.serviceendpoint_gitlab.url
  username              = var.serviceendpoint_gitlab.username
  api_token             = var.serviceendpoint_gitlab.api_token
  description           = var.serviceendpoint_gitlab.description
}

resource "azuredevops_serviceendpoint_incomingwebhook" "incomingwebhook" {
  count = var.serviceendpoint_incomingwebhook == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_incomingwebhook.service_endpoint_name
  webhook_name          = var.serviceendpoint_incomingwebhook.webhook_name
  description           = var.serviceendpoint_incomingwebhook.description
  http_header           = var.serviceendpoint_incomingwebhook.http_header
  secret                = var.serviceendpoint_incomingwebhook.secret
}

resource "azuredevops_serviceendpoint_jenkins" "jenkins" {
  count = var.serviceendpoint_jenkins == null ? 0 : 1

  project_id             = var.project_id
  service_endpoint_name  = var.serviceendpoint_jenkins.service_endpoint_name
  url                    = var.serviceendpoint_jenkins.url
  username               = var.serviceendpoint_jenkins.username
  password               = var.serviceendpoint_jenkins.password
  accept_untrusted_certs = var.serviceendpoint_jenkins.accept_untrusted_certs
  description            = var.serviceendpoint_jenkins.description
}

resource "azuredevops_serviceendpoint_jfrog_artifactory_v2" "jfrog_artifactory_v2" {
  count = var.serviceendpoint_jfrog_artifactory_v2 == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_jfrog_artifactory_v2.service_endpoint_name
  url                   = var.serviceendpoint_jfrog_artifactory_v2.url
  description           = var.serviceendpoint_jfrog_artifactory_v2.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_jfrog_artifactory_v2.authentication_token == null ? [] : [var.serviceendpoint_jfrog_artifactory_v2.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_jfrog_artifactory_v2.authentication_basic == null ? [] : [var.serviceendpoint_jfrog_artifactory_v2.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_jfrog_artifactory_v2.authentication_token != null) != (var.serviceendpoint_jfrog_artifactory_v2.authentication_basic != null)
        ) && (
        var.serviceendpoint_jfrog_artifactory_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_jfrog_artifactory_v2.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_artifactory_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_distribution_v2" "jfrog_distribution_v2" {
  count = var.serviceendpoint_jfrog_distribution_v2 == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_jfrog_distribution_v2.service_endpoint_name
  url                   = var.serviceendpoint_jfrog_distribution_v2.url
  description           = var.serviceendpoint_jfrog_distribution_v2.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_jfrog_distribution_v2.authentication_token == null ? [] : [var.serviceendpoint_jfrog_distribution_v2.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_jfrog_distribution_v2.authentication_basic == null ? [] : [var.serviceendpoint_jfrog_distribution_v2.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_jfrog_distribution_v2.authentication_token != null) != (var.serviceendpoint_jfrog_distribution_v2.authentication_basic != null)
        ) && (
        var.serviceendpoint_jfrog_distribution_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_distribution_v2.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_jfrog_distribution_v2.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_jfrog_distribution_v2.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_jfrog_distribution_v2.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_distribution_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_platform_v2" "jfrog_platform_v2" {
  count = var.serviceendpoint_jfrog_platform_v2 == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_jfrog_platform_v2.service_endpoint_name
  url                   = var.serviceendpoint_jfrog_platform_v2.url
  description           = var.serviceendpoint_jfrog_platform_v2.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_jfrog_platform_v2.authentication_token == null ? [] : [var.serviceendpoint_jfrog_platform_v2.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_jfrog_platform_v2.authentication_basic == null ? [] : [var.serviceendpoint_jfrog_platform_v2.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_jfrog_platform_v2.authentication_token != null) != (var.serviceendpoint_jfrog_platform_v2.authentication_basic != null)
        ) && (
        var.serviceendpoint_jfrog_platform_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_platform_v2.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_jfrog_platform_v2.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_jfrog_platform_v2.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_jfrog_platform_v2.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_platform_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_xray_v2" "jfrog_xray_v2" {
  count = var.serviceendpoint_jfrog_xray_v2 == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_jfrog_xray_v2.service_endpoint_name
  url                   = var.serviceendpoint_jfrog_xray_v2.url
  description           = var.serviceendpoint_jfrog_xray_v2.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_jfrog_xray_v2.authentication_token == null ? [] : [var.serviceendpoint_jfrog_xray_v2.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_jfrog_xray_v2.authentication_basic == null ? [] : [var.serviceendpoint_jfrog_xray_v2.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_jfrog_xray_v2.authentication_token != null) != (var.serviceendpoint_jfrog_xray_v2.authentication_basic != null)
        ) && (
        var.serviceendpoint_jfrog_xray_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_xray_v2.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_jfrog_xray_v2.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_jfrog_xray_v2.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_jfrog_xray_v2.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_xray_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_kubernetes" "kubernetes" {
  count = var.serviceendpoint_kubernetes == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_kubernetes.service_endpoint_name
  apiserver_url         = var.serviceendpoint_kubernetes.apiserver_url
  authorization_type    = var.serviceendpoint_kubernetes.authorization_type
  description           = var.serviceendpoint_kubernetes.description

  dynamic "azure_subscription" {
    for_each = var.serviceendpoint_kubernetes.azure_subscription == null ? [] : [var.serviceendpoint_kubernetes.azure_subscription]
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
    for_each = var.serviceendpoint_kubernetes.kubeconfig == null ? [] : [var.serviceendpoint_kubernetes.kubeconfig]
    content {
      kube_config            = kubeconfig.value.kube_config
      accept_untrusted_certs = kubeconfig.value.accept_untrusted_certs
      cluster_context        = kubeconfig.value.cluster_context
    }
  }

  dynamic "service_account" {
    for_each = var.serviceendpoint_kubernetes.service_account == null ? [] : [var.serviceendpoint_kubernetes.service_account]
    content {
      token                  = service_account.value.token
      ca_cert                = service_account.value.ca_cert
      accept_untrusted_certs = service_account.value.accept_untrusted_certs
    }
  }

  lifecycle {
    precondition {
      condition     = contains(["AzureSubscription", "Kubeconfig", "ServiceAccount"], var.serviceendpoint_kubernetes.authorization_type)
      error_message = "serviceendpoint_kubernetes.authorization_type must be AzureSubscription, Kubeconfig, or ServiceAccount."
    }
    precondition {
      condition = (
        var.serviceendpoint_kubernetes.authorization_type == "AzureSubscription"
        ? (var.serviceendpoint_kubernetes.azure_subscription != null && var.serviceendpoint_kubernetes.kubeconfig == null && var.serviceendpoint_kubernetes.service_account == null)
        : var.serviceendpoint_kubernetes.authorization_type == "Kubeconfig"
        ? (var.serviceendpoint_kubernetes.kubeconfig != null && var.serviceendpoint_kubernetes.azure_subscription == null && var.serviceendpoint_kubernetes.service_account == null)
        : var.serviceendpoint_kubernetes.authorization_type == "ServiceAccount"
        ? (var.serviceendpoint_kubernetes.service_account != null && var.serviceendpoint_kubernetes.azure_subscription == null && var.serviceendpoint_kubernetes.kubeconfig == null)
        : false
      )
      error_message = "serviceendpoint_kubernetes requires the authorization_type-specific block and no other auth blocks."
    }
  }
}

resource "azuredevops_serviceendpoint_maven" "maven" {
  count = var.serviceendpoint_maven == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_maven.service_endpoint_name
  url                   = var.serviceendpoint_maven.url
  repository_id         = var.serviceendpoint_maven.repository_id
  description           = var.serviceendpoint_maven.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_maven.authentication_token == null ? [] : [var.serviceendpoint_maven.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_maven.authentication_basic == null ? [] : [var.serviceendpoint_maven.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_maven.authentication_token != null) != (var.serviceendpoint_maven.authentication_basic != null)
        ) && (
        var.serviceendpoint_maven.authentication_token == null || length(trimspace(var.serviceendpoint_maven.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_maven.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_maven.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_maven.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_maven requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_nexus" "nexus" {
  count = var.serviceendpoint_nexus == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_nexus.service_endpoint_name
  url                   = var.serviceendpoint_nexus.url
  username              = var.serviceendpoint_nexus.username
  password              = var.serviceendpoint_nexus.password
  description           = var.serviceendpoint_nexus.description
}

resource "azuredevops_serviceendpoint_npm" "npm" {
  count = var.serviceendpoint_npm == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_npm.service_endpoint_name
  url                   = var.serviceendpoint_npm.url
  access_token          = var.serviceendpoint_npm.access_token
  description           = var.serviceendpoint_npm.description
}

resource "azuredevops_serviceendpoint_nuget" "nuget" {
  count = var.serviceendpoint_nuget == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_nuget.service_endpoint_name
  feed_url              = var.serviceendpoint_nuget.feed_url
  api_key               = var.serviceendpoint_nuget.api_key
  personal_access_token = var.serviceendpoint_nuget.personal_access_token
  username              = var.serviceendpoint_nuget.username
  password              = var.serviceendpoint_nuget.password
  description           = var.serviceendpoint_nuget.description

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_nuget.username == null && var.serviceendpoint_nuget.password == null) ||
        (var.serviceendpoint_nuget.username != null && var.serviceendpoint_nuget.password != null)
      )
      error_message = "serviceendpoint_nuget requires both username and password when using basic auth."
    }
    precondition {
      condition = length(compact([
        var.serviceendpoint_nuget.api_key != null ? "api_key" : "",
        var.serviceendpoint_nuget.personal_access_token != null ? "pat" : "",
        (var.serviceendpoint_nuget.username != null || var.serviceendpoint_nuget.password != null) ? "basic" : "",
      ])) <= 1
      error_message = "serviceendpoint_nuget allows only one authentication method (api_key, personal_access_token, or username/password)."
    }
  }
}

resource "azuredevops_serviceendpoint_octopusdeploy" "octopusdeploy" {
  count = var.serviceendpoint_octopusdeploy == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_octopusdeploy.service_endpoint_name
  url                   = var.serviceendpoint_octopusdeploy.url
  api_key               = var.serviceendpoint_octopusdeploy.api_key
  ignore_ssl_error      = var.serviceendpoint_octopusdeploy.ignore_ssl_error
  description           = var.serviceendpoint_octopusdeploy.description
}

resource "azuredevops_serviceendpoint_openshift" "openshift" {
  count = var.serviceendpoint_openshift == null ? 0 : 1

  project_id                 = var.project_id
  service_endpoint_name      = var.serviceendpoint_openshift.service_endpoint_name
  server_url                 = var.serviceendpoint_openshift.server_url
  accept_untrusted_certs     = var.serviceendpoint_openshift.accept_untrusted_certs
  certificate_authority_file = var.serviceendpoint_openshift.certificate_authority_file
  description                = var.serviceendpoint_openshift.description

  dynamic "auth_basic" {
    for_each = var.serviceendpoint_openshift.auth_basic == null ? [] : [var.serviceendpoint_openshift.auth_basic]
    content {
      username = auth_basic.value.username
      password = auth_basic.value.password
    }
  }

  dynamic "auth_token" {
    for_each = var.serviceendpoint_openshift.auth_token == null ? [] : [var.serviceendpoint_openshift.auth_token]
    content {
      token = auth_token.value.token
    }
  }

  dynamic "auth_none" {
    for_each = var.serviceendpoint_openshift.auth_none == null ? [] : [var.serviceendpoint_openshift.auth_none]
    content {
      kube_config = auth_none.value.kube_config
    }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        var.serviceendpoint_openshift.auth_basic != null ? "basic" : "",
        var.serviceendpoint_openshift.auth_token != null ? "token" : "",
        var.serviceendpoint_openshift.auth_none != null ? "none" : "",
      ])) == 1
      error_message = "serviceendpoint_openshift requires exactly one of auth_basic, auth_token, or auth_none."
    }
  }
}

locals {
  serviceendpoint_id = coalesce(
    try(one(azuredevops_serviceendpoint_argocd.argocd[*].id), null),
    try(one(azuredevops_serviceendpoint_artifactory.artifactory[*].id), null),
    try(one(azuredevops_serviceendpoint_aws.aws[*].id), null),
    try(one(azuredevops_serviceendpoint_azure_service_bus.azure_service_bus[*].id), null),
    try(one(azuredevops_serviceendpoint_azurecr.azurecr[*].id), null),
    try(one(azuredevops_serviceendpoint_azurerm.azurerm[*].id), null),
    try(one(azuredevops_serviceendpoint_bitbucket.bitbucket[*].id), null),
    try(one(azuredevops_serviceendpoint_black_duck.black_duck[*].id), null),
    try(one(azuredevops_serviceendpoint_checkmarx_one.checkmarx_one[*].id), null),
    try(one(azuredevops_serviceendpoint_checkmarx_sast.checkmarx_sast[*].id), null),
    try(one(azuredevops_serviceendpoint_checkmarx_sca.checkmarx_sca[*].id), null),
    try(one(azuredevops_serviceendpoint_dockerregistry.dockerregistry[*].id), null),
    try(one(azuredevops_serviceendpoint_dynamics_lifecycle_services.dynamics_lifecycle_services[*].id), null),
    try(one(azuredevops_serviceendpoint_externaltfs.externaltfs[*].id), null),
    try(one(azuredevops_serviceendpoint_gcp_terraform.gcp_terraform[*].id), null),
    try(one(azuredevops_serviceendpoint_generic.generic[*].id), null),
    try(one(azuredevops_serviceendpoint_generic_git.generic_git[*].id), null),
    try(one(azuredevops_serviceendpoint_generic_v2.generic_v2[*].id), null),
    try(one(azuredevops_serviceendpoint_github.github[*].id), null),
    try(one(azuredevops_serviceendpoint_github_enterprise.github_enterprise[*].id), null),
    try(one(azuredevops_serviceendpoint_gitlab.gitlab[*].id), null),
    try(one(azuredevops_serviceendpoint_incomingwebhook.incomingwebhook[*].id), null),
    try(one(azuredevops_serviceendpoint_jenkins.jenkins[*].id), null),
    try(one(azuredevops_serviceendpoint_jfrog_artifactory_v2.jfrog_artifactory_v2[*].id), null),
    try(one(azuredevops_serviceendpoint_jfrog_distribution_v2.jfrog_distribution_v2[*].id), null),
    try(one(azuredevops_serviceendpoint_jfrog_platform_v2.jfrog_platform_v2[*].id), null),
    try(one(azuredevops_serviceendpoint_jfrog_xray_v2.jfrog_xray_v2[*].id), null),
    try(one(azuredevops_serviceendpoint_kubernetes.kubernetes[*].id), null),
    try(one(azuredevops_serviceendpoint_maven.maven[*].id), null),
    try(one(azuredevops_serviceendpoint_nexus.nexus[*].id), null),
    try(one(azuredevops_serviceendpoint_npm.npm[*].id), null),
    try(one(azuredevops_serviceendpoint_nuget.nuget[*].id), null),
    try(one(azuredevops_serviceendpoint_octopusdeploy.octopusdeploy[*].id), null),
    try(one(azuredevops_serviceendpoint_openshift.openshift[*].id), null),
    try(one(azuredevops_serviceendpoint_runpipeline.runpipeline[*].id), null),
    try(one(azuredevops_serviceendpoint_servicefabric.servicefabric[*].id), null),
    try(one(azuredevops_serviceendpoint_snyk.snyk[*].id), null),
    try(one(azuredevops_serviceendpoint_sonarcloud.sonarcloud[*].id), null),
    try(one(azuredevops_serviceendpoint_sonarqube.sonarqube[*].id), null),
    try(one(azuredevops_serviceendpoint_ssh.ssh[*].id), null),
    try(one(azuredevops_serviceendpoint_visualstudiomarketplace.visualstudiomarketplace[*].id), null)
  )

  serviceendpoint_name = coalesce(
    try(one(azuredevops_serviceendpoint_argocd.argocd[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_artifactory.artifactory[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_aws.aws[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_azure_service_bus.azure_service_bus[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_azurecr.azurecr[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_azurerm.azurerm[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_bitbucket.bitbucket[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_black_duck.black_duck[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_checkmarx_one.checkmarx_one[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_checkmarx_sast.checkmarx_sast[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_checkmarx_sca.checkmarx_sca[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_dockerregistry.dockerregistry[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_dynamics_lifecycle_services.dynamics_lifecycle_services[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_externaltfs.externaltfs[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_gcp_terraform.gcp_terraform[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_generic.generic[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_generic_git.generic_git[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_generic_v2.generic_v2[*].name), null),
    try(one(azuredevops_serviceendpoint_github.github[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_github_enterprise.github_enterprise[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_gitlab.gitlab[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_incomingwebhook.incomingwebhook[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_jenkins.jenkins[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_jfrog_artifactory_v2.jfrog_artifactory_v2[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_jfrog_distribution_v2.jfrog_distribution_v2[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_jfrog_platform_v2.jfrog_platform_v2[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_jfrog_xray_v2.jfrog_xray_v2[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_kubernetes.kubernetes[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_maven.maven[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_nexus.nexus[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_npm.npm[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_nuget.nuget[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_octopusdeploy.octopusdeploy[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_openshift.openshift[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_runpipeline.runpipeline[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_servicefabric.servicefabric[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_snyk.snyk[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_sonarcloud.sonarcloud[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_sonarqube.sonarqube[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_ssh.ssh[*].service_endpoint_name), null),
    try(one(azuredevops_serviceendpoint_visualstudiomarketplace.visualstudiomarketplace[*].service_endpoint_name), null)
  )
}

resource "azuredevops_serviceendpoint_permissions" "permissions" {
  for_each = local.serviceendpoint_permissions

  project_id         = var.project_id
  principal          = each.value.principal
  permissions        = each.value.permissions
  serviceendpoint_id = coalesce(each.value.serviceendpoint_id, local.serviceendpoint_id)
  replace            = each.value.replace

  lifecycle {
    precondition {
      condition     = coalesce(each.value.serviceendpoint_id, local.serviceendpoint_id) != null
      error_message = "serviceendpoint_permissions requires a valid serviceendpoint_id or module-created endpoint."
    }
  }
}

resource "azuredevops_serviceendpoint_runpipeline" "runpipeline" {
  count = var.serviceendpoint_runpipeline == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_runpipeline.service_endpoint_name
  organization_name     = var.serviceendpoint_runpipeline.organization_name
  description           = var.serviceendpoint_runpipeline.description

  auth_personal {
    personal_access_token = var.serviceendpoint_runpipeline.auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_servicefabric" "servicefabric" {
  count = var.serviceendpoint_servicefabric == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_servicefabric.service_endpoint_name
  cluster_endpoint      = var.serviceendpoint_servicefabric.cluster_endpoint
  description           = var.serviceendpoint_servicefabric.description

  dynamic "certificate" {
    for_each = var.serviceendpoint_servicefabric.certificate == null ? [] : [var.serviceendpoint_servicefabric.certificate]
    content {
      server_certificate_lookup      = certificate.value.server_certificate_lookup
      server_certificate_thumbprint  = certificate.value.server_certificate_thumbprint
      server_certificate_common_name = certificate.value.server_certificate_common_name
      client_certificate             = certificate.value.client_certificate
      client_certificate_password    = certificate.value.client_certificate_password
    }
  }

  dynamic "azure_active_directory" {
    for_each = var.serviceendpoint_servicefabric.azure_active_directory == null ? [] : [var.serviceendpoint_servicefabric.azure_active_directory]
    content {
      server_certificate_lookup      = azure_active_directory.value.server_certificate_lookup
      server_certificate_thumbprint  = azure_active_directory.value.server_certificate_thumbprint
      server_certificate_common_name = azure_active_directory.value.server_certificate_common_name
      username                       = azure_active_directory.value.username
      password                       = azure_active_directory.value.password
    }
  }

  dynamic "none" {
    for_each = var.serviceendpoint_servicefabric.none == null ? [] : [var.serviceendpoint_servicefabric.none]
    content {
      unsecured   = none.value.unsecured
      cluster_spn = none.value.cluster_spn
    }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        var.serviceendpoint_servicefabric.certificate != null ? "certificate" : "",
        var.serviceendpoint_servicefabric.azure_active_directory != null ? "aad" : "",
        var.serviceendpoint_servicefabric.none != null ? "none" : "",
      ])) == 1
      error_message = "serviceendpoint_servicefabric requires exactly one of certificate, azure_active_directory, or none."
    }
  }
}

resource "azuredevops_serviceendpoint_snyk" "snyk" {
  count = var.serviceendpoint_snyk == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_snyk.service_endpoint_name
  server_url            = var.serviceendpoint_snyk.server_url
  api_token             = var.serviceendpoint_snyk.api_token
  description           = var.serviceendpoint_snyk.description
}

resource "azuredevops_serviceendpoint_sonarcloud" "sonarcloud" {
  count = var.serviceendpoint_sonarcloud == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_sonarcloud.service_endpoint_name
  token                 = var.serviceendpoint_sonarcloud.token
  description           = var.serviceendpoint_sonarcloud.description
}

resource "azuredevops_serviceendpoint_sonarqube" "sonarqube" {
  count = var.serviceendpoint_sonarqube == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_sonarqube.service_endpoint_name
  url                   = var.serviceendpoint_sonarqube.url
  token                 = var.serviceendpoint_sonarqube.token
  description           = var.serviceendpoint_sonarqube.description
}

resource "azuredevops_serviceendpoint_ssh" "ssh" {
  count = var.serviceendpoint_ssh == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_ssh.service_endpoint_name
  host                  = var.serviceendpoint_ssh.host
  username              = var.serviceendpoint_ssh.username
  port                  = var.serviceendpoint_ssh.port
  password              = var.serviceendpoint_ssh.password
  private_key           = var.serviceendpoint_ssh.private_key
  description           = var.serviceendpoint_ssh.description

  lifecycle {
    precondition {
      condition     = (var.serviceendpoint_ssh.password != null) != (var.serviceendpoint_ssh.private_key != null)
      error_message = "serviceendpoint_ssh requires exactly one of password or private_key."
    }
  }
}

resource "azuredevops_serviceendpoint_visualstudiomarketplace" "visualstudiomarketplace" {
  count = var.serviceendpoint_visualstudiomarketplace == null ? 0 : 1

  project_id            = var.project_id
  service_endpoint_name = var.serviceendpoint_visualstudiomarketplace.service_endpoint_name
  url                   = var.serviceendpoint_visualstudiomarketplace.url
  description           = var.serviceendpoint_visualstudiomarketplace.description

  dynamic "authentication_token" {
    for_each = var.serviceendpoint_visualstudiomarketplace.authentication_token == null ? [] : [var.serviceendpoint_visualstudiomarketplace.authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = var.serviceendpoint_visualstudiomarketplace.authentication_basic == null ? [] : [var.serviceendpoint_visualstudiomarketplace.authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.serviceendpoint_visualstudiomarketplace.authentication_token != null) != (var.serviceendpoint_visualstudiomarketplace.authentication_basic != null)
        ) && (
        var.serviceendpoint_visualstudiomarketplace.authentication_token == null || length(trimspace(var.serviceendpoint_visualstudiomarketplace.authentication_token.token)) > 0
        ) && (
        var.serviceendpoint_visualstudiomarketplace.authentication_basic == null || (
          length(trimspace(var.serviceendpoint_visualstudiomarketplace.authentication_basic.username)) > 0 &&
          length(trimspace(var.serviceendpoint_visualstudiomarketplace.authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_visualstudiomarketplace requires exactly one authentication method with non-empty credentials."
    }
  }
}
