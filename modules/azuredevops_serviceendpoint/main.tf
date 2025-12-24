# Azure DevOps Service Endpoints

resource "azuredevops_serviceendpoint_argocd" "argocd" {
  for_each = { for index, endpoint in var.serviceendpoint_argocd : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_artifactory" "artifactory" {
  for_each = { for index, endpoint in var.serviceendpoint_artifactory : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_aws" "aws" {
  for_each = { for index, endpoint in var.serviceendpoint_aws : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_azure_service_bus" "azure_service_bus" {
  for_each = { for index, endpoint in var.serviceendpoint_azure_service_bus : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  queue_name            = each.value.queue_name
  connection_string     = each.value.connection_string
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
  for_each = { for index, endpoint in var.serviceendpoint_azurecr : index => endpoint }

  project_id                             = var.project_id
  service_endpoint_name                  = each.value.service_endpoint_name
  resource_group                         = each.value.resource_group
  azurecr_spn_tenantid                    = each.value.azurecr_spn_tenantid
  azurecr_name                            = each.value.azurecr_name
  azurecr_subscription_id                 = each.value.azurecr_subscription_id
  azurecr_subscription_name               = each.value.azurecr_subscription_name
  service_endpoint_authentication_scheme  = each.value.service_endpoint_authentication_scheme
  description                             = each.value.description

  dynamic "credentials" {
    for_each = each.value.credentials == null ? [] : [each.value.credentials]
    content {
      serviceprincipalid = credentials.value.serviceprincipalid
    }
  }
}

resource "azuredevops_serviceendpoint_azuredevops" "azuredevops" {
  for_each = { for index, endpoint in var.serviceendpoint_azuredevops : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  org_url               = each.value.org_url
  release_api_url       = each.value.release_api_url
  personal_access_token = each.value.personal_access_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_azurerm" "azurerm" {
  for_each = { for index, endpoint in var.serviceendpoint_azurerm : index => endpoint }

  project_id                             = var.project_id
  service_endpoint_name                  = each.value.service_endpoint_name
  azurerm_spn_tenantid                    = each.value.azurerm_spn_tenantid
  serviceprincipalid                      = each.value.serviceprincipalid
  serviceprincipalkey                     = each.value.serviceprincipalkey
  serviceprincipalcertificate             = each.value.serviceprincipalcertificate
  service_endpoint_authentication_scheme  = each.value.service_endpoint_authentication_scheme
  azurerm_management_group_id             = each.value.azurerm_management_group_id
  azurerm_management_group_name           = each.value.azurerm_management_group_name
  azurerm_subscription_id                 = each.value.azurerm_subscription_id
  azurerm_subscription_name               = each.value.azurerm_subscription_name
  environment                             = each.value.environment
  server_url                              = each.value.server_url
  resource_group                          = each.value.resource_group
  validate                                = each.value.validate
  description                             = each.value.description

  dynamic "credentials" {
    for_each = each.value.credentials == null ? [] : [each.value.credentials]
    content {
      serviceprincipalid = credentials.value.serviceprincipalid
    }
  }

  dynamic "features" {
    for_each = each.value.features == null ? [] : [each.value.features]
    content {
      active_directory_service_endpoint_resource_id = features.value.active_directory_service_endpoint_resource_id
      validate = features.value.validate
    }
  }
}

resource "azuredevops_serviceendpoint_bitbucket" "bitbucket" {
  for_each = { for index, endpoint in var.serviceendpoint_bitbucket : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_black_duck" "black_duck" {
  for_each = { for index, endpoint in var.serviceendpoint_black_duck : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  api_token             = each.value.api_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_checkmarx_one" "checkmarx_one" {
  for_each = { for index, endpoint in var.serviceendpoint_checkmarx_one : index => endpoint }

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
  for_each = { for index, endpoint in var.serviceendpoint_checkmarx_sast : index => endpoint }

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
  for_each = { for index, endpoint in var.serviceendpoint_checkmarx_sca : index => endpoint }

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
  for_each = { for index, endpoint in var.serviceendpoint_dockerregistry : index => endpoint }

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
  for_each = { for index, endpoint in var.serviceendpoint_dynamics_lifecycle_services : index => endpoint }

  project_id                          = var.project_id
  service_endpoint_name               = each.value.service_endpoint_name
  authorization_endpoint              = each.value.authorization_endpoint
  lifecycle_services_api_endpoint     = each.value.lifecycle_services_api_endpoint
  client_id                           = each.value.client_id
  username                            = each.value.username
  password                            = each.value.password
  description                         = each.value.description
}

resource "azuredevops_serviceendpoint_externaltfs" "externaltfs" {
  for_each = { for index, endpoint in var.serviceendpoint_externaltfs : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  connection_url        = each.value.connection_url
  description           = each.value.description

  auth_personal {
    personal_access_token = each.value.auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_gcp_terraform" "gcp_terraform" {
  for_each = { for index, endpoint in var.serviceendpoint_gcp_terraform : index => endpoint }

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
  for_each = { for index, endpoint in var.serviceendpoint_generic : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_generic_git" "generic_git" {
  for_each = { for index, endpoint in var.serviceendpoint_generic_git : index => endpoint }

  project_id              = var.project_id
  service_endpoint_name   = each.value.service_endpoint_name
  repository_url          = each.value.repository_url
  username                = each.value.username
  password                = each.value.password
  enable_pipelines_access = each.value.enable_pipelines_access
  description             = each.value.description
}

resource "azuredevops_serviceendpoint_generic_v2" "generic_v2" {
  for_each = { for index, endpoint in var.serviceendpoint_generic_v2 : index => endpoint }

  project_id             = var.project_id
  name                   = each.value.name
  type                   = each.value.type
  server_url             = each.value.server_url
  authorization_scheme   = each.value.authorization_scheme
  shared_project_ids     = each.value.shared_project_ids
  description            = each.value.description
  authorization_parameters = each.value.authorization_parameters
  parameters             = each.value.parameters
}

resource "azuredevops_serviceendpoint_github" "github" {
  for_each = { for index, endpoint in var.serviceendpoint_github : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  description           = each.value.description
  personal_access_token = each.value.personal_access_token
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
}

resource "azuredevops_serviceendpoint_github_enterprise" "github_enterprise" {
  for_each = { for index, endpoint in var.serviceendpoint_github_enterprise : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  description           = each.value.description
  url                   = each.value.url
  personal_access_token = each.value.personal_access_token
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
}

resource "azuredevops_serviceendpoint_gitlab" "gitlab" {
  for_each = { for index, endpoint in var.serviceendpoint_gitlab : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  username              = each.value.username
  api_token             = each.value.api_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_incomingwebhook" "incomingwebhook" {
  for_each = { for index, endpoint in var.serviceendpoint_incomingwebhook : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  webhook_name          = each.value.webhook_name
  description           = each.value.description
  http_header           = each.value.http_header
  secret                = each.value.secret
}

resource "azuredevops_serviceendpoint_jenkins" "jenkins" {
  for_each = { for index, endpoint in var.serviceendpoint_jenkins : index => endpoint }

  project_id             = var.project_id
  service_endpoint_name  = each.value.service_endpoint_name
  url                    = each.value.url
  username               = each.value.username
  password               = each.value.password
  accept_untrusted_certs = each.value.accept_untrusted_certs
  description            = each.value.description
}

resource "azuredevops_serviceendpoint_jfrog_artifactory_v2" "jfrog_artifactory_v2" {
  for_each = { for index, endpoint in var.serviceendpoint_jfrog_artifactory_v2 : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_jfrog_distribution_v2" "jfrog_distribution_v2" {
  for_each = { for index, endpoint in var.serviceendpoint_jfrog_distribution_v2 : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_jfrog_platform_v2" "jfrog_platform_v2" {
  for_each = { for index, endpoint in var.serviceendpoint_jfrog_platform_v2 : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_jfrog_xray_v2" "jfrog_xray_v2" {
  for_each = { for index, endpoint in var.serviceendpoint_jfrog_xray_v2 : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_kubernetes" "kubernetes" {
  for_each = { for index, endpoint in var.serviceendpoint_kubernetes : index => endpoint }

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
      token                 = service_account.value.token
      ca_cert               = service_account.value.ca_cert
      accept_untrusted_certs = service_account.value.accept_untrusted_certs
    }
  }
}

resource "azuredevops_serviceendpoint_maven" "maven" {
  for_each = { for index, endpoint in var.serviceendpoint_maven : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_nexus" "nexus" {
  for_each = { for index, endpoint in var.serviceendpoint_nexus : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_npm" "npm" {
  for_each = { for index, endpoint in var.serviceendpoint_npm : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  access_token          = each.value.access_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_nuget" "nuget" {
  for_each = { for index, endpoint in var.serviceendpoint_nuget : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  feed_url              = each.value.feed_url
  api_key               = each.value.api_key
  personal_access_token = each.value.personal_access_token
  username              = each.value.username
  password              = each.value.password
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_octopusdeploy" "octopusdeploy" {
  for_each = { for index, endpoint in var.serviceendpoint_octopusdeploy : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  api_key               = each.value.api_key
  ignore_ssl_error      = each.value.ignore_ssl_error
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_openshift" "openshift" {
  for_each = { for index, endpoint in var.serviceendpoint_openshift : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_permissions" "permissions" {
  for_each = { for index, permission in var.serviceendpoint_permissions : index => permission }

  project_id         = var.project_id
  principal          = each.value.principal
  permissions        = each.value.permissions
  serviceendpoint_id = each.value.serviceendpoint_id
  replace            = each.value.replace
}

resource "azuredevops_serviceendpoint_runpipeline" "runpipeline" {
  for_each = { for index, endpoint in var.serviceendpoint_runpipeline : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  organization_name     = each.value.organization_name
  description           = each.value.description

  auth_personal {
    personal_access_token = each.value.auth_personal.personal_access_token
  }
}

resource "azuredevops_serviceendpoint_servicefabric" "servicefabric" {
  for_each = { for index, endpoint in var.serviceendpoint_servicefabric : index => endpoint }

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
}

resource "azuredevops_serviceendpoint_snyk" "snyk" {
  for_each = { for index, endpoint in var.serviceendpoint_snyk : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  server_url            = each.value.server_url
  api_token             = each.value.api_token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_sonarcloud" "sonarcloud" {
  for_each = { for index, endpoint in var.serviceendpoint_sonarcloud : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  token                 = each.value.token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_sonarqube" "sonarqube" {
  for_each = { for index, endpoint in var.serviceendpoint_sonarqube : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  url                   = each.value.url
  token                 = each.value.token
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_ssh" "ssh" {
  for_each = { for index, endpoint in var.serviceendpoint_ssh : index => endpoint }

  project_id            = var.project_id
  service_endpoint_name = each.value.service_endpoint_name
  host                  = each.value.host
  username              = each.value.username
  port                  = each.value.port
  password              = each.value.password
  private_key           = each.value.private_key
  description           = each.value.description
}

resource "azuredevops_serviceendpoint_visualstudiomarketplace" "visualstudiomarketplace" {
  for_each = { for index, endpoint in var.serviceendpoint_visualstudiomarketplace : index => endpoint }

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
}
