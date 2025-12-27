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

locals {
  serviceendpoint_argocd_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_argocd :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_artifactory_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_artifactory :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_aws_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_aws :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_azure_service_bus_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_azure_service_bus :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_azurecr_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_azurecr :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_azurerm_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_azurerm :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_bitbucket_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_bitbucket :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_black_duck_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_black_duck :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_checkmarx_one_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_checkmarx_one :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_checkmarx_sast_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_checkmarx_sast :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_checkmarx_sca_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_checkmarx_sca :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_dockerregistry_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_dockerregistry :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_dynamics_lifecycle_services_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_dynamics_lifecycle_services :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_externaltfs_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_externaltfs :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_gcp_terraform_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_gcp_terraform :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_generic_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_generic :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_generic_git_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_generic_git :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_generic_v2_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_generic_v2 :
    coalesce(endpoint.key, endpoint.name) => true
  })
  serviceendpoint_github_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_github :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_github_enterprise_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_github_enterprise :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_gitlab_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_gitlab :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_incomingwebhook_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_incomingwebhook :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_jenkins_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_jenkins :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_jfrog_artifactory_v2_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_jfrog_artifactory_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_jfrog_distribution_v2_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_jfrog_distribution_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_jfrog_platform_v2_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_jfrog_platform_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_jfrog_xray_v2_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_jfrog_xray_v2 :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_kubernetes_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_kubernetes :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_maven_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_maven :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_nexus_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_nexus :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_npm_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_npm :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_nuget_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_nuget :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_octopusdeploy_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_octopusdeploy :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_openshift_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_openshift :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_runpipeline_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_runpipeline :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_servicefabric_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_servicefabric :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_snyk_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_snyk :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_sonarcloud_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_sonarcloud :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_sonarqube_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_sonarqube :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_ssh_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_ssh :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_visualstudiomarketplace_for_each = nonsensitive({
    for endpoint in var.serviceendpoint_visualstudiomarketplace :
    coalesce(endpoint.key, endpoint.service_endpoint_name) => true
  })
  serviceendpoint_azurerm_credentials = {
    for key, endpoint in local.serviceendpoint_azurerm :
    key => {
      serviceprincipalid = coalesce(
        try(endpoint.credentials.serviceprincipalid, null),
        endpoint.serviceprincipalid,
        null
      )
      serviceprincipalkey = coalesce(
        try(endpoint.credentials.serviceprincipalkey, null),
        endpoint.serviceprincipalkey,
        null
      )
      serviceprincipalcertificate = coalesce(
        try(endpoint.credentials.serviceprincipalcertificate, null),
        endpoint.serviceprincipalcertificate,
        null
      )
    }
  }
  serviceendpoint_azurerm_features = {
    for key, endpoint in local.serviceendpoint_azurerm :
    key => {
      validate = coalesce(
        try(endpoint.features.validate, null),
        endpoint.validate,
        null
      )
    }
  }
  serviceendpoint_github_auth_personal = {
    for key, endpoint in local.serviceendpoint_github :
    key => (
      endpoint.auth_personal != null ? endpoint.auth_personal :
      endpoint.personal_access_token != null ? { personal_access_token = endpoint.personal_access_token } :
      null
    )
  }
  serviceendpoint_github_auth_oauth = {
    for key, endpoint in local.serviceendpoint_github :
    key => (
      endpoint.auth_oauth != null ? endpoint.auth_oauth :
      endpoint.oauth_configuration_id != null ? { oauth_configuration_id = endpoint.oauth_configuration_id } :
      null
    )
  }
  serviceendpoint_github_enterprise_auth_personal = {
    for key, endpoint in local.serviceendpoint_github_enterprise :
    key => (
      endpoint.auth_personal != null ? endpoint.auth_personal :
      endpoint.personal_access_token != null ? { personal_access_token = endpoint.personal_access_token } :
      null
    )
  }
  serviceendpoint_github_enterprise_auth_oauth = {
    for key, endpoint in local.serviceendpoint_github_enterprise :
    key => (
      endpoint.auth_oauth != null ? endpoint.auth_oauth :
      endpoint.oauth_configuration_id != null ? { oauth_configuration_id = endpoint.oauth_configuration_id } :
      null
    )
  }
}

resource "azuredevops_serviceendpoint_argocd" "argocd" {
  for_each = local.serviceendpoint_argocd_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_argocd[each.key].service_endpoint_name
  url                   = local.serviceendpoint_argocd[each.key].url
  description           = local.serviceendpoint_argocd[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_argocd[each.key].authentication_token == null ? [] : [local.serviceendpoint_argocd[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_argocd[each.key].authentication_basic == null ? [] : [local.serviceendpoint_argocd[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_argocd[each.key].authentication_token != null) != (local.serviceendpoint_argocd[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_argocd[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_argocd[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_argocd[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_argocd[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_argocd[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_argocd requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_artifactory" "artifactory" {
  for_each = local.serviceendpoint_artifactory_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_artifactory[each.key].service_endpoint_name
  url                   = local.serviceendpoint_artifactory[each.key].url
  description           = local.serviceendpoint_artifactory[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_artifactory[each.key].authentication_token == null ? [] : [local.serviceendpoint_artifactory[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_artifactory[each.key].authentication_basic == null ? [] : [local.serviceendpoint_artifactory[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_artifactory[each.key].authentication_token != null) != (local.serviceendpoint_artifactory[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_artifactory[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_artifactory[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_artifactory[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_artifactory[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_artifactory[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_artifactory requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_aws" "aws" {
  for_each = local.serviceendpoint_aws_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_aws[each.key].service_endpoint_name
  access_key_id         = local.serviceendpoint_aws[each.key].access_key_id
  secret_access_key     = local.serviceendpoint_aws[each.key].secret_access_key
  session_token         = local.serviceendpoint_aws[each.key].session_token
  role_to_assume        = local.serviceendpoint_aws[each.key].role_to_assume
  role_session_name     = local.serviceendpoint_aws[each.key].role_session_name
  external_id           = local.serviceendpoint_aws[each.key].external_id
  description           = local.serviceendpoint_aws[each.key].description
  use_oidc              = local.serviceendpoint_aws[each.key].use_oidc

  lifecycle {
    precondition {
      condition = (
        local.serviceendpoint_aws[each.key].use_oidc == true
        ? (
          local.serviceendpoint_aws[each.key].access_key_id == null &&
          local.serviceendpoint_aws[each.key].secret_access_key == null &&
          length(trimspace(coalesce(local.serviceendpoint_aws[each.key].role_to_assume, ""))) > 0 &&
          length(trimspace(coalesce(local.serviceendpoint_aws[each.key].role_session_name, ""))) > 0
        )
        : (
          length(trimspace(coalesce(local.serviceendpoint_aws[each.key].access_key_id, ""))) > 0 &&
          length(trimspace(coalesce(local.serviceendpoint_aws[each.key].secret_access_key, ""))) > 0
        )
      )
      error_message = "serviceendpoint_aws requires access_key_id/secret_access_key or OIDC with role_to_assume and role_session_name, but not both."
    }
  }
}

resource "azuredevops_serviceendpoint_azure_service_bus" "azure_service_bus" {
  for_each = local.serviceendpoint_azure_service_bus_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_azure_service_bus[each.key].service_endpoint_name
  queue_name            = local.serviceendpoint_azure_service_bus[each.key].queue_name
  connection_string     = local.serviceendpoint_azure_service_bus[each.key].connection_string
  description           = local.serviceendpoint_azure_service_bus[each.key].description
}

resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
  for_each = local.serviceendpoint_azurecr_for_each

  project_id                             = var.project_id
  service_endpoint_name                  = local.serviceendpoint_azurecr[each.key].service_endpoint_name
  resource_group                         = local.serviceendpoint_azurecr[each.key].resource_group
  azurecr_spn_tenantid                   = local.serviceendpoint_azurecr[each.key].azurecr_spn_tenantid
  azurecr_name                           = local.serviceendpoint_azurecr[each.key].azurecr_name
  azurecr_subscription_id                = local.serviceendpoint_azurecr[each.key].azurecr_subscription_id
  azurecr_subscription_name              = local.serviceendpoint_azurecr[each.key].azurecr_subscription_name
  service_endpoint_authentication_scheme = local.serviceendpoint_azurecr[each.key].service_endpoint_authentication_scheme
  description                            = local.serviceendpoint_azurecr[each.key].description

  dynamic "credentials" {
    for_each = local.serviceendpoint_azurecr[each.key].credentials == null ? [] : [local.serviceendpoint_azurecr[each.key].credentials]
    content {
      serviceprincipalid = credentials.value.serviceprincipalid
    }
  }
}

resource "azuredevops_serviceendpoint_azurerm" "azurerm" {
  for_each = local.serviceendpoint_azurerm_for_each

  project_id                             = var.project_id
  service_endpoint_name                  = local.serviceendpoint_azurerm[each.key].service_endpoint_name
  azurerm_spn_tenantid                   = local.serviceendpoint_azurerm[each.key].azurerm_spn_tenantid
  service_endpoint_authentication_scheme = local.serviceendpoint_azurerm[each.key].service_endpoint_authentication_scheme
  azurerm_management_group_id            = local.serviceendpoint_azurerm[each.key].azurerm_management_group_id
  azurerm_management_group_name          = local.serviceendpoint_azurerm[each.key].azurerm_management_group_name
  azurerm_subscription_id                = local.serviceendpoint_azurerm[each.key].azurerm_subscription_id
  azurerm_subscription_name              = local.serviceendpoint_azurerm[each.key].azurerm_subscription_name
  environment                            = local.serviceendpoint_azurerm[each.key].environment
  server_url                             = local.serviceendpoint_azurerm[each.key].server_url
  resource_group                         = local.serviceendpoint_azurerm[each.key].resource_group
  description                            = local.serviceendpoint_azurerm[each.key].description

  dynamic "credentials" {
    for_each = (
      local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalid == null &&
      local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalkey == null &&
      local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalcertificate == null
    ) ? [] : [local.serviceendpoint_azurerm_credentials[each.key]]
    content {
      serviceprincipalid          = credentials.value.serviceprincipalid
      serviceprincipalkey         = credentials.value.serviceprincipalkey
      serviceprincipalcertificate = credentials.value.serviceprincipalcertificate
    }
  }

  dynamic "features" {
    for_each = local.serviceendpoint_azurerm_features[each.key].validate == null ? [] : [local.serviceendpoint_azurerm_features[each.key]]
    content {
      validate = features.value.validate
    }
  }

  lifecycle {
    precondition {
      condition = length(trimspace(coalesce(local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalid, ""))) > 0
      error_message = "serviceendpoint_azurerm requires a non-empty service principal ID."
    }
    precondition {
      condition = !(
        local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalkey != null &&
        local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalcertificate != null
      )
      error_message = "serviceendpoint_azurerm cannot set both serviceprincipalkey and serviceprincipalcertificate."
    }
    precondition {
      condition = (
        local.serviceendpoint_azurerm[each.key].service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
        ? (
          local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalkey == null &&
          local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalcertificate == null
        )
        : true
      )
      error_message = "serviceendpoint_azurerm workload identity requires omitting service principal secrets/certificates."
    }
    precondition {
      condition = (
        local.serviceendpoint_azurerm[each.key].service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
        ? true
        : (
          local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalkey != null ||
          local.serviceendpoint_azurerm_credentials[each.key].serviceprincipalcertificate != null
        )
      )
      error_message = "serviceendpoint_azurerm requires a service principal key or certificate unless workload identity is selected."
    }
  }
}

resource "azuredevops_serviceendpoint_bitbucket" "bitbucket" {
  for_each = local.serviceendpoint_bitbucket_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_bitbucket[each.key].service_endpoint_name
  username              = local.serviceendpoint_bitbucket[each.key].username
  password              = local.serviceendpoint_bitbucket[each.key].password
  description           = local.serviceendpoint_bitbucket[each.key].description
}

resource "azuredevops_serviceendpoint_black_duck" "black_duck" {
  for_each = local.serviceendpoint_black_duck_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_black_duck[each.key].service_endpoint_name
  server_url            = local.serviceendpoint_black_duck[each.key].server_url
  api_token             = local.serviceendpoint_black_duck[each.key].api_token
  description           = local.serviceendpoint_black_duck[each.key].description
}

resource "azuredevops_serviceendpoint_checkmarx_one" "checkmarx_one" {
  for_each = local.serviceendpoint_checkmarx_one_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_checkmarx_one[each.key].service_endpoint_name
  server_url            = local.serviceendpoint_checkmarx_one[each.key].server_url
  authorization_url     = local.serviceendpoint_checkmarx_one[each.key].authorization_url
  api_key               = local.serviceendpoint_checkmarx_one[each.key].api_key
  client_id             = local.serviceendpoint_checkmarx_one[each.key].client_id
  client_secret         = local.serviceendpoint_checkmarx_one[each.key].client_secret
  description           = local.serviceendpoint_checkmarx_one[each.key].description
}

resource "azuredevops_serviceendpoint_checkmarx_sast" "checkmarx_sast" {
  for_each = local.serviceendpoint_checkmarx_sast_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_checkmarx_sast[each.key].service_endpoint_name
  server_url            = local.serviceendpoint_checkmarx_sast[each.key].server_url
  username              = local.serviceendpoint_checkmarx_sast[each.key].username
  password              = local.serviceendpoint_checkmarx_sast[each.key].password
  team                  = local.serviceendpoint_checkmarx_sast[each.key].team
  preset                = local.serviceendpoint_checkmarx_sast[each.key].preset
  description           = local.serviceendpoint_checkmarx_sast[each.key].description
}

resource "azuredevops_serviceendpoint_checkmarx_sca" "checkmarx_sca" {
  for_each = local.serviceendpoint_checkmarx_sca_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_checkmarx_sca[each.key].service_endpoint_name
  access_control_url    = local.serviceendpoint_checkmarx_sca[each.key].access_control_url
  server_url            = local.serviceendpoint_checkmarx_sca[each.key].server_url
  web_app_url           = local.serviceendpoint_checkmarx_sca[each.key].web_app_url
  account               = local.serviceendpoint_checkmarx_sca[each.key].account
  username              = local.serviceendpoint_checkmarx_sca[each.key].username
  password              = local.serviceendpoint_checkmarx_sca[each.key].password
  team                  = local.serviceendpoint_checkmarx_sca[each.key].team
  description           = local.serviceendpoint_checkmarx_sca[each.key].description
}

resource "azuredevops_serviceendpoint_dockerregistry" "dockerregistry" {
  for_each = local.serviceendpoint_dockerregistry_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_dockerregistry[each.key].service_endpoint_name
  description           = local.serviceendpoint_dockerregistry[each.key].description
  docker_registry       = local.serviceendpoint_dockerregistry[each.key].docker_registry
  docker_username       = local.serviceendpoint_dockerregistry[each.key].docker_username
  docker_email          = local.serviceendpoint_dockerregistry[each.key].docker_email
  docker_password       = local.serviceendpoint_dockerregistry[each.key].docker_password
  registry_type         = local.serviceendpoint_dockerregistry[each.key].registry_type
}

resource "azuredevops_serviceendpoint_dynamics_lifecycle_services" "dynamics_lifecycle_services" {
  for_each = local.serviceendpoint_dynamics_lifecycle_services_for_each

  project_id                      = var.project_id
  service_endpoint_name           = local.serviceendpoint_dynamics_lifecycle_services[each.key].service_endpoint_name
  authorization_endpoint          = local.serviceendpoint_dynamics_lifecycle_services[each.key].authorization_endpoint
  lifecycle_services_api_endpoint = local.serviceendpoint_dynamics_lifecycle_services[each.key].lifecycle_services_api_endpoint
  client_id                       = local.serviceendpoint_dynamics_lifecycle_services[each.key].client_id
  username                        = local.serviceendpoint_dynamics_lifecycle_services[each.key].username
  password                        = local.serviceendpoint_dynamics_lifecycle_services[each.key].password
  description                     = local.serviceendpoint_dynamics_lifecycle_services[each.key].description
}

resource "azuredevops_serviceendpoint_externaltfs" "externaltfs" {
  for_each = local.serviceendpoint_externaltfs_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_externaltfs[each.key].service_endpoint_name
  connection_url        = local.serviceendpoint_externaltfs[each.key].connection_url
  description           = local.serviceendpoint_externaltfs[each.key].description

  auth_personal {
    personal_access_token = local.serviceendpoint_externaltfs[each.key].auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_gcp_terraform" "gcp_terraform" {
  for_each = local.serviceendpoint_gcp_terraform_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_gcp_terraform[each.key].service_endpoint_name
  private_key           = local.serviceendpoint_gcp_terraform[each.key].private_key
  token_uri             = local.serviceendpoint_gcp_terraform[each.key].token_uri
  gcp_project_id        = local.serviceendpoint_gcp_terraform[each.key].gcp_project_id
  client_email          = local.serviceendpoint_gcp_terraform[each.key].client_email
  scope                 = local.serviceendpoint_gcp_terraform[each.key].scope
  description           = local.serviceendpoint_gcp_terraform[each.key].description
}

resource "azuredevops_serviceendpoint_generic" "generic" {
  for_each = local.serviceendpoint_generic_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_generic[each.key].service_endpoint_name
  server_url            = local.serviceendpoint_generic[each.key].server_url
  username              = local.serviceendpoint_generic[each.key].username
  password              = local.serviceendpoint_generic[each.key].password
  description           = local.serviceendpoint_generic[each.key].description
}

resource "azuredevops_serviceendpoint_generic_git" "generic_git" {
  for_each = local.serviceendpoint_generic_git_for_each

  project_id              = var.project_id
  service_endpoint_name   = local.serviceendpoint_generic_git[each.key].service_endpoint_name
  repository_url          = local.serviceendpoint_generic_git[each.key].repository_url
  username                = local.serviceendpoint_generic_git[each.key].username
  password                = local.serviceendpoint_generic_git[each.key].password
  enable_pipelines_access = local.serviceendpoint_generic_git[each.key].enable_pipelines_access
  description             = local.serviceendpoint_generic_git[each.key].description
}

resource "azuredevops_serviceendpoint_generic_v2" "generic_v2" {
  for_each = local.serviceendpoint_generic_v2_for_each

  project_id               = var.project_id
  name                     = local.serviceendpoint_generic_v2[each.key].name
  type                     = local.serviceendpoint_generic_v2[each.key].type
  server_url               = local.serviceendpoint_generic_v2[each.key].server_url
  authorization_scheme     = local.serviceendpoint_generic_v2[each.key].authorization_scheme
  shared_project_ids       = local.serviceendpoint_generic_v2[each.key].shared_project_ids
  description              = local.serviceendpoint_generic_v2[each.key].description
  authorization_parameters = local.serviceendpoint_generic_v2[each.key].authorization_parameters
  parameters               = local.serviceendpoint_generic_v2[each.key].parameters
}

resource "azuredevops_serviceendpoint_github" "github" {
  for_each = local.serviceendpoint_github_for_each

  project_id             = var.project_id
  service_endpoint_name  = local.serviceendpoint_github[each.key].service_endpoint_name
  description            = local.serviceendpoint_github[each.key].description

  dynamic "auth_oauth" {
    for_each = local.serviceendpoint_github_auth_oauth[each.key] == null ? [] : [local.serviceendpoint_github_auth_oauth[each.key]]
    content {
      oauth_configuration_id = auth_oauth.value.oauth_configuration_id
    }
  }

  dynamic "auth_personal" {
    for_each = local.serviceendpoint_github_auth_personal[each.key] == null ? [] : [local.serviceendpoint_github_auth_personal[each.key]]
    content {
      personal_access_token = auth_personal.value.personal_access_token
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_github_auth_personal[each.key] != null) !=
        (local.serviceendpoint_github_auth_oauth[each.key] != null)
      )
      error_message = "serviceendpoint_github requires exactly one of personal access token or OAuth configuration."
    }
  }
}

resource "azuredevops_serviceendpoint_github_enterprise" "github_enterprise" {
  for_each = local.serviceendpoint_github_enterprise_for_each

  project_id             = var.project_id
  service_endpoint_name  = local.serviceendpoint_github_enterprise[each.key].service_endpoint_name
  description            = local.serviceendpoint_github_enterprise[each.key].description
  url                    = local.serviceendpoint_github_enterprise[each.key].url

  dynamic "auth_personal" {
    for_each = local.serviceendpoint_github_enterprise_auth_personal[each.key] == null ? [] : [local.serviceendpoint_github_enterprise_auth_personal[each.key]]
    content {
      personal_access_token = auth_personal.value.personal_access_token
    }
  }

  dynamic "auth_oauth" {
    for_each = local.serviceendpoint_github_enterprise_auth_oauth[each.key] == null ? [] : [local.serviceendpoint_github_enterprise_auth_oauth[each.key]]
    content {
      oauth_configuration_id = auth_oauth.value.oauth_configuration_id
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_github_enterprise_auth_personal[each.key] != null) !=
        (local.serviceendpoint_github_enterprise_auth_oauth[each.key] != null)
      )
      error_message = "serviceendpoint_github_enterprise requires exactly one of personal access token or OAuth configuration."
    }
  }
}

resource "azuredevops_serviceendpoint_gitlab" "gitlab" {
  for_each = local.serviceendpoint_gitlab_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_gitlab[each.key].service_endpoint_name
  url                   = local.serviceendpoint_gitlab[each.key].url
  username              = local.serviceendpoint_gitlab[each.key].username
  api_token             = local.serviceendpoint_gitlab[each.key].api_token
  description           = local.serviceendpoint_gitlab[each.key].description
}

resource "azuredevops_serviceendpoint_incomingwebhook" "incomingwebhook" {
  for_each = local.serviceendpoint_incomingwebhook_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_incomingwebhook[each.key].service_endpoint_name
  webhook_name          = local.serviceendpoint_incomingwebhook[each.key].webhook_name
  description           = local.serviceendpoint_incomingwebhook[each.key].description
  http_header           = local.serviceendpoint_incomingwebhook[each.key].http_header
  secret                = local.serviceendpoint_incomingwebhook[each.key].secret
}

resource "azuredevops_serviceendpoint_jenkins" "jenkins" {
  for_each = local.serviceendpoint_jenkins_for_each

  project_id             = var.project_id
  service_endpoint_name  = local.serviceendpoint_jenkins[each.key].service_endpoint_name
  url                    = local.serviceendpoint_jenkins[each.key].url
  username               = local.serviceendpoint_jenkins[each.key].username
  password               = local.serviceendpoint_jenkins[each.key].password
  accept_untrusted_certs = local.serviceendpoint_jenkins[each.key].accept_untrusted_certs
  description            = local.serviceendpoint_jenkins[each.key].description
}

resource "azuredevops_serviceendpoint_jfrog_artifactory_v2" "jfrog_artifactory_v2" {
  for_each = local.serviceendpoint_jfrog_artifactory_v2_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_jfrog_artifactory_v2[each.key].service_endpoint_name
  url                   = local.serviceendpoint_jfrog_artifactory_v2[each.key].url
  description           = local.serviceendpoint_jfrog_artifactory_v2[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_token == null ? [] : [local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_basic == null ? [] : [local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_token != null) != (local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_jfrog_artifactory_v2[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_artifactory_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_distribution_v2" "jfrog_distribution_v2" {
  for_each = local.serviceendpoint_jfrog_distribution_v2_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_jfrog_distribution_v2[each.key].service_endpoint_name
  url                   = local.serviceendpoint_jfrog_distribution_v2[each.key].url
  description           = local.serviceendpoint_jfrog_distribution_v2[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_token == null ? [] : [local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_basic == null ? [] : [local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_token != null) != (local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_jfrog_distribution_v2[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_distribution_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_platform_v2" "jfrog_platform_v2" {
  for_each = local.serviceendpoint_jfrog_platform_v2_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_jfrog_platform_v2[each.key].service_endpoint_name
  url                   = local.serviceendpoint_jfrog_platform_v2[each.key].url
  description           = local.serviceendpoint_jfrog_platform_v2[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_jfrog_platform_v2[each.key].authentication_token == null ? [] : [local.serviceendpoint_jfrog_platform_v2[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_jfrog_platform_v2[each.key].authentication_basic == null ? [] : [local.serviceendpoint_jfrog_platform_v2[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_jfrog_platform_v2[each.key].authentication_token != null) != (local.serviceendpoint_jfrog_platform_v2[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_jfrog_platform_v2[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_jfrog_platform_v2[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_jfrog_platform_v2[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_jfrog_platform_v2[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_jfrog_platform_v2[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_platform_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_jfrog_xray_v2" "jfrog_xray_v2" {
  for_each = local.serviceendpoint_jfrog_xray_v2_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_jfrog_xray_v2[each.key].service_endpoint_name
  url                   = local.serviceendpoint_jfrog_xray_v2[each.key].url
  description           = local.serviceendpoint_jfrog_xray_v2[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_jfrog_xray_v2[each.key].authentication_token == null ? [] : [local.serviceendpoint_jfrog_xray_v2[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_jfrog_xray_v2[each.key].authentication_basic == null ? [] : [local.serviceendpoint_jfrog_xray_v2[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_jfrog_xray_v2[each.key].authentication_token != null) != (local.serviceendpoint_jfrog_xray_v2[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_jfrog_xray_v2[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_jfrog_xray_v2[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_jfrog_xray_v2[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_jfrog_xray_v2[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_jfrog_xray_v2[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_jfrog_xray_v2 requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_kubernetes" "kubernetes" {
  for_each = local.serviceendpoint_kubernetes_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_kubernetes[each.key].service_endpoint_name
  apiserver_url         = local.serviceendpoint_kubernetes[each.key].apiserver_url
  authorization_type    = local.serviceendpoint_kubernetes[each.key].authorization_type
  description           = local.serviceendpoint_kubernetes[each.key].description

  dynamic "azure_subscription" {
    for_each = local.serviceendpoint_kubernetes[each.key].azure_subscription == null ? [] : [local.serviceendpoint_kubernetes[each.key].azure_subscription]
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
    for_each = local.serviceendpoint_kubernetes[each.key].kubeconfig == null ? [] : [local.serviceendpoint_kubernetes[each.key].kubeconfig]
    content {
      kube_config            = kubeconfig.value.kube_config
      accept_untrusted_certs = kubeconfig.value.accept_untrusted_certs
      cluster_context        = kubeconfig.value.cluster_context
    }
  }

  dynamic "service_account" {
    for_each = local.serviceendpoint_kubernetes[each.key].service_account == null ? [] : [local.serviceendpoint_kubernetes[each.key].service_account]
    content {
      token                  = service_account.value.token
      ca_cert                = service_account.value.ca_cert
      accept_untrusted_certs = service_account.value.accept_untrusted_certs
    }
  }

  lifecycle {
    precondition {
      condition = contains(["AzureSubscription", "Kubeconfig", "ServiceAccount"], local.serviceendpoint_kubernetes[each.key].authorization_type)
      error_message = "serviceendpoint_kubernetes.authorization_type must be AzureSubscription, Kubeconfig, or ServiceAccount."
    }
    precondition {
      condition = (
        local.serviceendpoint_kubernetes[each.key].authorization_type == "AzureSubscription"
        ? (local.serviceendpoint_kubernetes[each.key].azure_subscription != null && local.serviceendpoint_kubernetes[each.key].kubeconfig == null && local.serviceendpoint_kubernetes[each.key].service_account == null)
        : local.serviceendpoint_kubernetes[each.key].authorization_type == "Kubeconfig"
        ? (local.serviceendpoint_kubernetes[each.key].kubeconfig != null && local.serviceendpoint_kubernetes[each.key].azure_subscription == null && local.serviceendpoint_kubernetes[each.key].service_account == null)
        : local.serviceendpoint_kubernetes[each.key].authorization_type == "ServiceAccount"
        ? (local.serviceendpoint_kubernetes[each.key].service_account != null && local.serviceendpoint_kubernetes[each.key].azure_subscription == null && local.serviceendpoint_kubernetes[each.key].kubeconfig == null)
        : false
      )
      error_message = "serviceendpoint_kubernetes requires the authorization_type-specific block and no other auth blocks."
    }
  }
}

resource "azuredevops_serviceendpoint_maven" "maven" {
  for_each = local.serviceendpoint_maven_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_maven[each.key].service_endpoint_name
  url                   = local.serviceendpoint_maven[each.key].url
  repository_id         = local.serviceendpoint_maven[each.key].repository_id
  description           = local.serviceendpoint_maven[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_maven[each.key].authentication_token == null ? [] : [local.serviceendpoint_maven[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_maven[each.key].authentication_basic == null ? [] : [local.serviceendpoint_maven[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_maven[each.key].authentication_token != null) != (local.serviceendpoint_maven[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_maven[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_maven[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_maven[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_maven[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_maven[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_maven requires exactly one authentication method with non-empty credentials."
    }
  }
}

resource "azuredevops_serviceendpoint_nexus" "nexus" {
  for_each = local.serviceendpoint_nexus_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_nexus[each.key].service_endpoint_name
  url                   = local.serviceendpoint_nexus[each.key].url
  username              = local.serviceendpoint_nexus[each.key].username
  password              = local.serviceendpoint_nexus[each.key].password
  description           = local.serviceendpoint_nexus[each.key].description
}

resource "azuredevops_serviceendpoint_npm" "npm" {
  for_each = local.serviceendpoint_npm_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_npm[each.key].service_endpoint_name
  url                   = local.serviceendpoint_npm[each.key].url
  access_token          = local.serviceendpoint_npm[each.key].access_token
  description           = local.serviceendpoint_npm[each.key].description
}

resource "azuredevops_serviceendpoint_nuget" "nuget" {
  for_each = local.serviceendpoint_nuget_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_nuget[each.key].service_endpoint_name
  feed_url              = local.serviceendpoint_nuget[each.key].feed_url
  api_key               = local.serviceendpoint_nuget[each.key].api_key
  personal_access_token = local.serviceendpoint_nuget[each.key].personal_access_token
  username              = local.serviceendpoint_nuget[each.key].username
  password              = local.serviceendpoint_nuget[each.key].password
  description           = local.serviceendpoint_nuget[each.key].description

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_nuget[each.key].username == null && local.serviceendpoint_nuget[each.key].password == null) ||
        (local.serviceendpoint_nuget[each.key].username != null && local.serviceendpoint_nuget[each.key].password != null)
      )
      error_message = "serviceendpoint_nuget requires both username and password when using basic auth."
    }
    precondition {
      condition = length(compact([
        local.serviceendpoint_nuget[each.key].api_key != null ? "api_key" : "",
        local.serviceendpoint_nuget[each.key].personal_access_token != null ? "pat" : "",
        (local.serviceendpoint_nuget[each.key].username != null || local.serviceendpoint_nuget[each.key].password != null) ? "basic" : "",
      ])) <= 1
      error_message = "serviceendpoint_nuget allows only one authentication method (api_key, personal_access_token, or username/password)."
    }
  }
}

resource "azuredevops_serviceendpoint_octopusdeploy" "octopusdeploy" {
  for_each = local.serviceendpoint_octopusdeploy_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_octopusdeploy[each.key].service_endpoint_name
  url                   = local.serviceendpoint_octopusdeploy[each.key].url
  api_key               = local.serviceendpoint_octopusdeploy[each.key].api_key
  ignore_ssl_error      = local.serviceendpoint_octopusdeploy[each.key].ignore_ssl_error
  description           = local.serviceendpoint_octopusdeploy[each.key].description
}

resource "azuredevops_serviceendpoint_openshift" "openshift" {
  for_each = local.serviceendpoint_openshift_for_each

  project_id                 = var.project_id
  service_endpoint_name      = local.serviceendpoint_openshift[each.key].service_endpoint_name
  server_url                 = local.serviceendpoint_openshift[each.key].server_url
  accept_untrusted_certs     = local.serviceendpoint_openshift[each.key].accept_untrusted_certs
  certificate_authority_file = local.serviceendpoint_openshift[each.key].certificate_authority_file
  description                = local.serviceendpoint_openshift[each.key].description

  dynamic "auth_basic" {
    for_each = local.serviceendpoint_openshift[each.key].auth_basic == null ? [] : [local.serviceendpoint_openshift[each.key].auth_basic]
    content {
      username = auth_basic.value.username
      password = auth_basic.value.password
    }
  }

  dynamic "auth_token" {
    for_each = local.serviceendpoint_openshift[each.key].auth_token == null ? [] : [local.serviceendpoint_openshift[each.key].auth_token]
    content {
      token = auth_token.value.token
    }
  }

  dynamic "auth_none" {
    for_each = local.serviceendpoint_openshift[each.key].auth_none == null ? [] : [local.serviceendpoint_openshift[each.key].auth_none]
    content {
      kube_config = auth_none.value.kube_config
    }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        local.serviceendpoint_openshift[each.key].auth_basic != null ? "basic" : "",
        local.serviceendpoint_openshift[each.key].auth_token != null ? "token" : "",
        local.serviceendpoint_openshift[each.key].auth_none != null ? "none" : "",
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
  for_each = local.serviceendpoint_runpipeline_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_runpipeline[each.key].service_endpoint_name
  organization_name     = local.serviceendpoint_runpipeline[each.key].organization_name
  description           = local.serviceendpoint_runpipeline[each.key].description

  auth_personal {
    personal_access_token = local.serviceendpoint_runpipeline[each.key].auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_servicefabric" "servicefabric" {
  for_each = local.serviceendpoint_servicefabric_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_servicefabric[each.key].service_endpoint_name
  cluster_endpoint      = local.serviceendpoint_servicefabric[each.key].cluster_endpoint
  description           = local.serviceendpoint_servicefabric[each.key].description

  dynamic "certificate" {
    for_each = local.serviceendpoint_servicefabric[each.key].certificate == null ? [] : [local.serviceendpoint_servicefabric[each.key].certificate]
    content {
      server_certificate_lookup      = certificate.value.server_certificate_lookup
      server_certificate_thumbprint  = certificate.value.server_certificate_thumbprint
      server_certificate_common_name = certificate.value.server_certificate_common_name
      client_certificate             = certificate.value.client_certificate
      client_certificate_password    = certificate.value.client_certificate_password
    }
  }

  dynamic "azure_active_directory" {
    for_each = local.serviceendpoint_servicefabric[each.key].azure_active_directory == null ? [] : [local.serviceendpoint_servicefabric[each.key].azure_active_directory]
    content {
      server_certificate_lookup      = azure_active_directory.value.server_certificate_lookup
      server_certificate_thumbprint  = azure_active_directory.value.server_certificate_thumbprint
      server_certificate_common_name = azure_active_directory.value.server_certificate_common_name
      username                       = azure_active_directory.value.username
      password                       = azure_active_directory.value.password
    }
  }

  dynamic "none" {
    for_each = local.serviceendpoint_servicefabric[each.key].none == null ? [] : [local.serviceendpoint_servicefabric[each.key].none]
    content {
      unsecured   = none.value.unsecured
      cluster_spn = none.value.cluster_spn
    }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        local.serviceendpoint_servicefabric[each.key].certificate != null ? "certificate" : "",
        local.serviceendpoint_servicefabric[each.key].azure_active_directory != null ? "aad" : "",
        local.serviceendpoint_servicefabric[each.key].none != null ? "none" : "",
      ])) == 1
      error_message = "serviceendpoint_servicefabric requires exactly one of certificate, azure_active_directory, or none."
    }
  }
}

resource "azuredevops_serviceendpoint_snyk" "snyk" {
  for_each = local.serviceendpoint_snyk_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_snyk[each.key].service_endpoint_name
  server_url            = local.serviceendpoint_snyk[each.key].server_url
  api_token             = local.serviceendpoint_snyk[each.key].api_token
  description           = local.serviceendpoint_snyk[each.key].description
}

resource "azuredevops_serviceendpoint_sonarcloud" "sonarcloud" {
  for_each = local.serviceendpoint_sonarcloud_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_sonarcloud[each.key].service_endpoint_name
  token                 = local.serviceendpoint_sonarcloud[each.key].token
  description           = local.serviceendpoint_sonarcloud[each.key].description
}

resource "azuredevops_serviceendpoint_sonarqube" "sonarqube" {
  for_each = local.serviceendpoint_sonarqube_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_sonarqube[each.key].service_endpoint_name
  url                   = local.serviceendpoint_sonarqube[each.key].url
  token                 = local.serviceendpoint_sonarqube[each.key].token
  description           = local.serviceendpoint_sonarqube[each.key].description
}

resource "azuredevops_serviceendpoint_ssh" "ssh" {
  for_each = local.serviceendpoint_ssh_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_ssh[each.key].service_endpoint_name
  host                  = local.serviceendpoint_ssh[each.key].host
  username              = local.serviceendpoint_ssh[each.key].username
  port                  = local.serviceendpoint_ssh[each.key].port
  password              = local.serviceendpoint_ssh[each.key].password
  private_key           = local.serviceendpoint_ssh[each.key].private_key
  description           = local.serviceendpoint_ssh[each.key].description

  lifecycle {
    precondition {
      condition     = (local.serviceendpoint_ssh[each.key].password != null) != (local.serviceendpoint_ssh[each.key].private_key != null)
      error_message = "serviceendpoint_ssh requires exactly one of password or private_key."
    }
  }
}

resource "azuredevops_serviceendpoint_visualstudiomarketplace" "visualstudiomarketplace" {
  for_each = local.serviceendpoint_visualstudiomarketplace_for_each

  project_id            = var.project_id
  service_endpoint_name = local.serviceendpoint_visualstudiomarketplace[each.key].service_endpoint_name
  url                   = local.serviceendpoint_visualstudiomarketplace[each.key].url
  description           = local.serviceendpoint_visualstudiomarketplace[each.key].description

  dynamic "authentication_token" {
    for_each = local.serviceendpoint_visualstudiomarketplace[each.key].authentication_token == null ? [] : [local.serviceendpoint_visualstudiomarketplace[each.key].authentication_token]
    content {
      token = authentication_token.value.token
    }
  }

  dynamic "authentication_basic" {
    for_each = local.serviceendpoint_visualstudiomarketplace[each.key].authentication_basic == null ? [] : [local.serviceendpoint_visualstudiomarketplace[each.key].authentication_basic]
    content {
      username = authentication_basic.value.username
      password = authentication_basic.value.password
    }
  }

  lifecycle {
    precondition {
      condition = (
        (local.serviceendpoint_visualstudiomarketplace[each.key].authentication_token != null) != (local.serviceendpoint_visualstudiomarketplace[each.key].authentication_basic != null)
      ) && (
        local.serviceendpoint_visualstudiomarketplace[each.key].authentication_token == null || length(trimspace(local.serviceendpoint_visualstudiomarketplace[each.key].authentication_token.token)) > 0
      ) && (
        local.serviceendpoint_visualstudiomarketplace[each.key].authentication_basic == null || (
          length(trimspace(local.serviceendpoint_visualstudiomarketplace[each.key].authentication_basic.username)) > 0 &&
          length(trimspace(local.serviceendpoint_visualstudiomarketplace[each.key].authentication_basic.password)) > 0
        )
      )
      error_message = "serviceendpoint_visualstudiomarketplace requires exactly one authentication method with non-empty credentials."
    }
  }
}
