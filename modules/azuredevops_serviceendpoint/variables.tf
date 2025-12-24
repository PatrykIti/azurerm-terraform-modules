# -----------------------------------------------------------------------------
# Core
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# ArgoCD
# -----------------------------------------------------------------------------

variable "serviceendpoint_argocd" {
  description = "List of ArgoCD service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Artifactory
# -----------------------------------------------------------------------------

variable "serviceendpoint_artifactory" {
  description = "List of Artifactory service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# AWS
# -----------------------------------------------------------------------------

variable "serviceendpoint_aws" {
  description = "List of AWS service endpoints."
  type = list(object({
    service_endpoint_name = string
    access_key_id         = optional(string)
    secret_access_key     = optional(string)
    session_token         = optional(string)
    role_to_assume        = optional(string)
    role_session_name     = optional(string)
    external_id           = optional(string)
    description           = optional(string)
    use_oidc              = optional(bool)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Azure Service Bus
# -----------------------------------------------------------------------------

variable "serviceendpoint_azure_service_bus" {
  description = "List of Azure Service Bus service endpoints."
  type = list(object({
    service_endpoint_name = string
    queue_name            = string
    connection_string     = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------

variable "serviceendpoint_azurecr" {
  description = "List of Azure Container Registry service endpoints."
  type = list(object({
    service_endpoint_name                  = string
    resource_group                         = string
    azurecr_spn_tenantid                   = string
    azurecr_name                           = string
    azurecr_subscription_id                = string
    azurecr_subscription_name              = string
    service_endpoint_authentication_scheme = optional(string)
    description                            = optional(string)
    credentials = optional(object({
      serviceprincipalid = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Azure DevOps
# -----------------------------------------------------------------------------

variable "serviceendpoint_azuredevops" {
  description = "List of Azure DevOps service endpoints."
  type = list(object({
    service_endpoint_name = string
    org_url               = string
    release_api_url       = string
    personal_access_token = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Azure Resource Manager
# -----------------------------------------------------------------------------

variable "serviceendpoint_azurerm" {
  description = "List of Azure Resource Manager service endpoints."
  type = list(object({
    service_endpoint_name                  = string
    azurerm_spn_tenantid                   = string
    serviceprincipalid                     = string
    serviceprincipalkey                    = optional(string)
    serviceprincipalcertificate            = optional(string)
    service_endpoint_authentication_scheme = optional(string)
    azurerm_management_group_id            = optional(string)
    azurerm_management_group_name          = optional(string)
    azurerm_subscription_id                = optional(string)
    azurerm_subscription_name              = optional(string)
    environment                            = optional(string)
    server_url                             = optional(string)
    resource_group                         = optional(string)
    validate                               = optional(bool)
    description                            = optional(string)
    credentials = optional(object({
      serviceprincipalid          = string
      serviceprincipalkey         = optional(string)
      serviceprincipalcertificate = optional(string)
    }))
    features = optional(object({
      validate = optional(bool)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Bitbucket
# -----------------------------------------------------------------------------

variable "serviceendpoint_bitbucket" {
  description = "List of Bitbucket service endpoints."
  type = list(object({
    service_endpoint_name = string
    username              = string
    password              = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Black Duck
# -----------------------------------------------------------------------------

variable "serviceendpoint_black_duck" {
  description = "List of Black Duck service endpoints."
  type = list(object({
    service_endpoint_name = string
    server_url            = string
    api_token             = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Checkmarx One
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_one" {
  description = "List of Checkmarx One service endpoints."
  type = list(object({
    service_endpoint_name = string
    server_url            = string
    authorization_url     = optional(string)
    api_key               = optional(string)
    client_id             = optional(string)
    client_secret         = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Checkmarx SAST
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_sast" {
  description = "List of Checkmarx SAST service endpoints."
  type = list(object({
    service_endpoint_name = string
    server_url            = string
    username              = string
    password              = string
    team                  = optional(string)
    preset                = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Checkmarx SCA
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_sca" {
  description = "List of Checkmarx SCA service endpoints."
  type = list(object({
    service_endpoint_name = string
    access_control_url    = string
    server_url            = string
    web_app_url           = string
    account               = string
    username              = string
    password              = string
    team                  = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Docker Registry
# -----------------------------------------------------------------------------

variable "serviceendpoint_dockerregistry" {
  description = "List of Docker registry service endpoints."
  type = list(object({
    service_endpoint_name = string
    description           = optional(string)
    docker_registry       = optional(string)
    docker_username       = optional(string)
    docker_email          = optional(string)
    docker_password       = optional(string)
    registry_type         = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Dynamics Lifecycle Services
# -----------------------------------------------------------------------------

variable "serviceendpoint_dynamics_lifecycle_services" {
  description = "List of Dynamics Lifecycle Services service endpoints."
  type = list(object({
    service_endpoint_name           = string
    authorization_endpoint          = string
    lifecycle_services_api_endpoint = string
    client_id                       = string
    username                        = string
    password                        = string
    description                     = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# External TFS
# -----------------------------------------------------------------------------

variable "serviceendpoint_externaltfs" {
  description = "List of external TFS service endpoints."
  type = list(object({
    service_endpoint_name = string
    connection_url        = string
    description           = optional(string)
    auth_personal = object({
      personal_access_token = string
    })
  }))
  default = []
}

# -----------------------------------------------------------------------------
# GCP Terraform
# -----------------------------------------------------------------------------

variable "serviceendpoint_gcp_terraform" {
  description = "List of GCP Terraform service endpoints."
  type = list(object({
    service_endpoint_name = string
    private_key           = string
    token_uri             = string
    gcp_project_id        = string
    client_email          = optional(string)
    scope                 = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Generic
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic" {
  description = "List of generic service endpoints."
  type = list(object({
    service_endpoint_name = string
    server_url            = string
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Generic Git
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic_git" {
  description = "List of generic Git service endpoints."
  type = list(object({
    service_endpoint_name   = string
    repository_url          = string
    username                = optional(string)
    password                = optional(string)
    enable_pipelines_access = optional(bool)
    description             = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Generic V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic_v2" {
  description = "List of generic v2 service endpoints."
  type = list(object({
    name                     = string
    type                     = string
    server_url               = string
    authorization_scheme     = string
    shared_project_ids       = optional(list(string))
    description              = optional(string)
    authorization_parameters = optional(map(string))
    parameters               = optional(map(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# GitHub
# -----------------------------------------------------------------------------

variable "serviceendpoint_github" {
  description = "List of GitHub service endpoints."
  type = list(object({
    service_endpoint_name = string
    description           = optional(string)
    auth_oauth = optional(object({
      oauth_configuration_id = string
    }))
    auth_personal = optional(object({
      personal_access_token = string
    }))
    personal_access_token  = optional(string)
    oauth_configuration_id = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# GitHub Enterprise
# -----------------------------------------------------------------------------

variable "serviceendpoint_github_enterprise" {
  description = "List of GitHub Enterprise service endpoints."
  type = list(object({
    service_endpoint_name = string
    description           = optional(string)
    url                   = optional(string)
    auth_personal = optional(object({
      personal_access_token = string
    }))
    auth_oauth = optional(object({
      oauth_configuration_id = string
    }))
    personal_access_token  = optional(string)
    oauth_configuration_id = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# GitLab
# -----------------------------------------------------------------------------

variable "serviceendpoint_gitlab" {
  description = "List of GitLab service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    username              = string
    api_token             = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Incoming Webhook
# -----------------------------------------------------------------------------

variable "serviceendpoint_incomingwebhook" {
  description = "List of incoming webhook service endpoints."
  type = list(object({
    service_endpoint_name = string
    webhook_name          = string
    description           = optional(string)
    http_header           = optional(string)
    secret                = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Jenkins
# -----------------------------------------------------------------------------

variable "serviceendpoint_jenkins" {
  description = "List of Jenkins service endpoints."
  type = list(object({
    service_endpoint_name  = string
    url                    = string
    username               = string
    password               = string
    accept_untrusted_certs = optional(bool)
    description            = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# JFrog Artifactory V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_artifactory_v2" {
  description = "List of JFrog Artifactory v2 service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# JFrog Distribution V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_distribution_v2" {
  description = "List of JFrog Distribution v2 service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# JFrog Platform V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_platform_v2" {
  description = "List of JFrog Platform v2 service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# JFrog Xray V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_xray_v2" {
  description = "List of JFrog Xray v2 service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Kubernetes
# -----------------------------------------------------------------------------

variable "serviceendpoint_kubernetes" {
  description = "List of Kubernetes service endpoints."
  type = list(object({
    service_endpoint_name = string
    apiserver_url         = string
    authorization_type    = string
    description           = optional(string)
    azure_subscription = optional(object({
      azure_environment = optional(string)
      cluster_name      = string
      subscription_id   = string
      subscription_name = string
      tenant_id         = string
      resourcegroup_id  = string
      namespace         = optional(string)
      cluster_admin     = optional(bool)
    }))
    kubeconfig = optional(object({
      kube_config            = string
      accept_untrusted_certs = optional(bool)
      cluster_context        = optional(string)
    }))
    service_account = optional(object({
      token                  = string
      ca_cert                = string
      accept_untrusted_certs = optional(bool)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Maven
# -----------------------------------------------------------------------------

variable "serviceendpoint_maven" {
  description = "List of Maven service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    repository_id         = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Nexus
# -----------------------------------------------------------------------------

variable "serviceendpoint_nexus" {
  description = "List of Nexus service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    username              = string
    password              = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# npm
# -----------------------------------------------------------------------------

variable "serviceendpoint_npm" {
  description = "List of npm service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    access_token          = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# NuGet
# -----------------------------------------------------------------------------

variable "serviceendpoint_nuget" {
  description = "List of NuGet service endpoints."
  type = list(object({
    service_endpoint_name = string
    feed_url              = string
    api_key               = optional(string)
    personal_access_token = optional(string)
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Octopus Deploy
# -----------------------------------------------------------------------------

variable "serviceendpoint_octopusdeploy" {
  description = "List of Octopus Deploy service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    api_key               = string
    ignore_ssl_error      = optional(bool)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# OpenShift
# -----------------------------------------------------------------------------

variable "serviceendpoint_openshift" {
  description = "List of OpenShift service endpoints."
  type = list(object({
    service_endpoint_name      = string
    server_url                 = optional(string)
    accept_untrusted_certs     = optional(bool)
    certificate_authority_file = optional(string)
    description                = optional(string)
    auth_basic = optional(object({
      username = string
      password = string
    }))
    auth_token = optional(object({
      token = string
    }))
    auth_none = optional(object({
      kube_config = optional(string)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Service Endpoint Permissions
# -----------------------------------------------------------------------------

variable "serviceendpoint_permissions" {
  description = "List of service endpoint permissions to assign."
  type = list(object({
    principal          = string
    permissions        = map(string)
    serviceendpoint_id = optional(string)
    replace            = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : length(trimspace(permission.principal)) > 0
    ])
    error_message = "serviceendpoint_permissions.principal must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Run Pipeline
# -----------------------------------------------------------------------------

variable "serviceendpoint_runpipeline" {
  description = "List of run pipeline service endpoints."
  type = list(object({
    service_endpoint_name = string
    organization_name     = string
    description           = optional(string)
    auth_personal = object({
      personal_access_token = string
    })
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Service Fabric
# -----------------------------------------------------------------------------

variable "serviceendpoint_servicefabric" {
  description = "List of Service Fabric service endpoints."
  type = list(object({
    service_endpoint_name = string
    cluster_endpoint      = string
    description           = optional(string)
    certificate = optional(object({
      server_certificate_lookup      = string
      server_certificate_thumbprint  = optional(string)
      server_certificate_common_name = optional(string)
      client_certificate             = string
      client_certificate_password    = optional(string)
    }))
    azure_active_directory = optional(object({
      server_certificate_lookup      = string
      server_certificate_thumbprint  = optional(string)
      server_certificate_common_name = optional(string)
      username                       = string
      password                       = string
    }))
    none = optional(object({
      unsecured   = optional(bool)
      cluster_spn = optional(string)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Snyk
# -----------------------------------------------------------------------------

variable "serviceendpoint_snyk" {
  description = "List of Snyk service endpoints."
  type = list(object({
    service_endpoint_name = string
    server_url            = string
    api_token             = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# SonarCloud
# -----------------------------------------------------------------------------

variable "serviceendpoint_sonarcloud" {
  description = "List of SonarCloud service endpoints."
  type = list(object({
    service_endpoint_name = string
    token                 = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# SonarQube
# -----------------------------------------------------------------------------

variable "serviceendpoint_sonarqube" {
  description = "List of SonarQube service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    token                 = string
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# SSH
# -----------------------------------------------------------------------------

variable "serviceendpoint_ssh" {
  description = "List of SSH service endpoints."
  type = list(object({
    service_endpoint_name = string
    host                  = string
    username              = string
    port                  = optional(number)
    password              = optional(string)
    private_key           = optional(string)
    description           = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Visual Studio Marketplace
# -----------------------------------------------------------------------------

variable "serviceendpoint_visualstudiomarketplace" {
  description = "List of Visual Studio Marketplace service endpoints."
  type = list(object({
    service_endpoint_name = string
    url                   = string
    description           = optional(string)
    authentication_token = optional(object({
      token = string
    }))
    authentication_basic = optional(object({
      username = string
      password = string
    }))
  }))
  default = []
}
