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

  validation {
    condition = length(trimspace(var.project_id)) > 0 && length([for is_set in [
      var.serviceendpoint_argocd != null,
      var.serviceendpoint_artifactory != null,
      var.serviceendpoint_aws != null,
      var.serviceendpoint_azure_service_bus != null,
      var.serviceendpoint_azurecr != null,
      var.serviceendpoint_azurerm != null,
      var.serviceendpoint_bitbucket != null,
      var.serviceendpoint_black_duck != null,
      var.serviceendpoint_checkmarx_one != null,
      var.serviceendpoint_checkmarx_sast != null,
      var.serviceendpoint_checkmarx_sca != null,
      var.serviceendpoint_dockerregistry != null,
      var.serviceendpoint_dynamics_lifecycle_services != null,
      var.serviceendpoint_externaltfs != null,
      var.serviceendpoint_gcp_terraform != null,
      var.serviceendpoint_generic != null,
      var.serviceendpoint_generic_git != null,
      var.serviceendpoint_generic_v2 != null,
      var.serviceendpoint_github != null,
      var.serviceendpoint_github_enterprise != null,
      var.serviceendpoint_gitlab != null,
      var.serviceendpoint_incomingwebhook != null,
      var.serviceendpoint_jenkins != null,
      var.serviceendpoint_jfrog_artifactory_v2 != null,
      var.serviceendpoint_jfrog_distribution_v2 != null,
      var.serviceendpoint_jfrog_platform_v2 != null,
      var.serviceendpoint_jfrog_xray_v2 != null,
      var.serviceendpoint_kubernetes != null,
      var.serviceendpoint_maven != null,
      var.serviceendpoint_nexus != null,
      var.serviceendpoint_npm != null,
      var.serviceendpoint_nuget != null,
      var.serviceendpoint_octopusdeploy != null,
      var.serviceendpoint_openshift != null,
      var.serviceendpoint_runpipeline != null,
      var.serviceendpoint_servicefabric != null,
      var.serviceendpoint_snyk != null,
      var.serviceendpoint_sonarcloud != null,
      var.serviceendpoint_sonarqube != null,
      var.serviceendpoint_ssh != null,
      var.serviceendpoint_visualstudiomarketplace != null,
    ] : is_set if is_set]) == 1
    error_message = "Exactly one serviceendpoint_* object must be set."
  }
}

# -----------------------------------------------------------------------------
# ArgoCD
# -----------------------------------------------------------------------------

variable "serviceendpoint_argocd" {
  description = "ArgoCD service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_argocd == null || (
      length(trimspace(var.serviceendpoint_argocd.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_argocd.url)) > 0
    )
    error_message = "serviceendpoint_argocd requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_argocd == null || (
      (var.serviceendpoint_argocd.authentication_token != null) != (var.serviceendpoint_argocd.authentication_basic != null) &&
      (var.serviceendpoint_argocd.authentication_token == null || length(trimspace(var.serviceendpoint_argocd.authentication_token.token)) > 0) &&
      (var.serviceendpoint_argocd.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_argocd.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_argocd.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_argocd requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# Artifactory
# -----------------------------------------------------------------------------

variable "serviceendpoint_artifactory" {
  description = "Artifactory service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_artifactory == null || (
      length(trimspace(var.serviceendpoint_artifactory.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_artifactory.url)) > 0
    )
    error_message = "serviceendpoint_artifactory requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_artifactory == null || (
      (var.serviceendpoint_artifactory.authentication_token != null) != (var.serviceendpoint_artifactory.authentication_basic != null) &&
      (var.serviceendpoint_artifactory.authentication_token == null || length(trimspace(var.serviceendpoint_artifactory.authentication_token.token)) > 0) &&
      (var.serviceendpoint_artifactory.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_artifactory.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_artifactory.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_artifactory requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# AWS
# -----------------------------------------------------------------------------

variable "serviceendpoint_aws" {
  description = "AWS service endpoint."
  type = object({
    service_endpoint_name = string
    access_key_id         = optional(string)
    secret_access_key     = optional(string)
    session_token         = optional(string)
    role_to_assume        = optional(string)
    role_session_name     = optional(string)
    external_id           = optional(string)
    description           = optional(string)
    use_oidc              = optional(bool)
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.serviceendpoint_aws == null || length(trimspace(var.serviceendpoint_aws.service_endpoint_name)) > 0
    error_message = "serviceendpoint_aws requires non-empty service_endpoint_name."
  }

  validation {
    condition = var.serviceendpoint_aws == null || (
      var.serviceendpoint_aws.use_oidc == true
      ? (
        (var.serviceendpoint_aws.access_key_id == null || trimspace(var.serviceendpoint_aws.access_key_id) == "") &&
        (var.serviceendpoint_aws.secret_access_key == null || trimspace(var.serviceendpoint_aws.secret_access_key) == "") &&
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

# -----------------------------------------------------------------------------
# Azure Service Bus
# -----------------------------------------------------------------------------

variable "serviceendpoint_azure_service_bus" {
  description = "Azure Service Bus service endpoint."
  type = object({
    service_endpoint_name = string
    queue_name            = string
    connection_string     = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_azure_service_bus == null || (
      length(trimspace(var.serviceendpoint_azure_service_bus.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_azure_service_bus.queue_name)) > 0 &&
      length(trimspace(var.serviceendpoint_azure_service_bus.connection_string)) > 0
    )
    error_message = "serviceendpoint_azure_service_bus requires non-empty service_endpoint_name, queue_name, and connection_string."
  }
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------

variable "serviceendpoint_azurecr" {
  description = "Azure Container Registry service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_azurecr == null || (
      length(trimspace(var.serviceendpoint_azurecr.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_azurecr.resource_group)) > 0 &&
      length(trimspace(var.serviceendpoint_azurecr.azurecr_spn_tenantid)) > 0 &&
      length(trimspace(var.serviceendpoint_azurecr.azurecr_name)) > 0 &&
      length(trimspace(var.serviceendpoint_azurecr.azurecr_subscription_id)) > 0 &&
      length(trimspace(var.serviceendpoint_azurecr.azurecr_subscription_name)) > 0
    )
    error_message = "serviceendpoint_azurecr requires non-empty service_endpoint_name, resource_group, azurecr_spn_tenantid, azurecr_name, azurecr_subscription_id, and azurecr_subscription_name."
  }

  validation {
    condition = var.serviceendpoint_azurecr == null || (
      var.serviceendpoint_azurecr.credentials == null || length(trimspace(var.serviceendpoint_azurecr.credentials.serviceprincipalid)) > 0
    )
    error_message = "serviceendpoint_azurecr.credentials.serviceprincipalid must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Azure Resource Manager
# -----------------------------------------------------------------------------

variable "serviceendpoint_azurerm" {
  description = "Azure Resource Manager service endpoint."
  type = object({
    service_endpoint_name                  = string
    azurerm_spn_tenantid                   = string
    serviceprincipalid                     = optional(string)
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_azurerm == null || (
      length(trimspace(var.serviceendpoint_azurerm.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_azurerm.azurerm_spn_tenantid)) > 0
    )
    error_message = "serviceendpoint_azurerm requires non-empty service_endpoint_name and azurerm_spn_tenantid."
  }

  validation {
    condition = var.serviceendpoint_azurerm == null || length(trimspace(coalesce(
      try(var.serviceendpoint_azurerm.credentials.serviceprincipalid, null),
      var.serviceendpoint_azurerm.serviceprincipalid,
      ""
    ))) > 0
    error_message = "serviceendpoint_azurerm requires a non-empty service principal ID."
  }

  validation {
    condition = var.serviceendpoint_azurerm == null || !(
      length(trimspace(coalesce(
        try(var.serviceendpoint_azurerm.credentials.serviceprincipalkey, null),
        var.serviceendpoint_azurerm.serviceprincipalkey,
        ""
      ))) > 0 &&
      length(trimspace(coalesce(
        try(var.serviceendpoint_azurerm.credentials.serviceprincipalcertificate, null),
        var.serviceendpoint_azurerm.serviceprincipalcertificate,
        ""
      ))) > 0
    )
    error_message = "serviceendpoint_azurerm cannot set both serviceprincipalkey and serviceprincipalcertificate."
  }

  validation {
    condition = var.serviceendpoint_azurerm == null || (
      var.serviceendpoint_azurerm.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
      ? (
        length(trimspace(coalesce(
          try(var.serviceendpoint_azurerm.credentials.serviceprincipalkey, null),
          var.serviceendpoint_azurerm.serviceprincipalkey,
          ""
        ))) == 0 &&
        length(trimspace(coalesce(
          try(var.serviceendpoint_azurerm.credentials.serviceprincipalcertificate, null),
          var.serviceendpoint_azurerm.serviceprincipalcertificate,
          ""
        ))) == 0
      )
      : true
    )
    error_message = "serviceendpoint_azurerm workload identity requires omitting service principal secrets/certificates."
  }

  validation {
    condition = var.serviceendpoint_azurerm == null || (
      var.serviceendpoint_azurerm.service_endpoint_authentication_scheme == "WorkloadIdentityFederation"
      ? true
      : (
        length(trimspace(coalesce(
          try(var.serviceendpoint_azurerm.credentials.serviceprincipalkey, null),
          var.serviceendpoint_azurerm.serviceprincipalkey,
          ""
        ))) > 0 ||
        length(trimspace(coalesce(
          try(var.serviceendpoint_azurerm.credentials.serviceprincipalcertificate, null),
          var.serviceendpoint_azurerm.serviceprincipalcertificate,
          ""
        ))) > 0
      )
    )
    error_message = "serviceendpoint_azurerm requires a service principal key or certificate unless workload identity is selected."
  }
}

# -----------------------------------------------------------------------------
# Bitbucket
# -----------------------------------------------------------------------------

variable "serviceendpoint_bitbucket" {
  description = "Bitbucket service endpoint."
  type = object({
    service_endpoint_name = string
    username              = string
    password              = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_bitbucket == null || (
      length(trimspace(var.serviceendpoint_bitbucket.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_bitbucket.username)) > 0 &&
      length(trimspace(var.serviceendpoint_bitbucket.password)) > 0
    )
    error_message = "serviceendpoint_bitbucket requires non-empty service_endpoint_name, username, and password."
  }
}

# -----------------------------------------------------------------------------
# Black Duck
# -----------------------------------------------------------------------------

variable "serviceendpoint_black_duck" {
  description = "Black Duck service endpoint."
  type = object({
    service_endpoint_name = string
    server_url            = string
    api_token             = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_black_duck == null || (
      length(trimspace(var.serviceendpoint_black_duck.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_black_duck.server_url)) > 0 &&
      length(trimspace(var.serviceendpoint_black_duck.api_token)) > 0
    )
    error_message = "serviceendpoint_black_duck requires non-empty service_endpoint_name, server_url, and api_token."
  }
}

# -----------------------------------------------------------------------------
# Checkmarx One
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_one" {
  description = "Checkmarx One service endpoint."
  type = object({
    service_endpoint_name = string
    server_url            = string
    authorization_url     = optional(string)
    api_key               = optional(string)
    client_id             = optional(string)
    client_secret         = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_checkmarx_one == null || (
      length(trimspace(var.serviceendpoint_checkmarx_one.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_one.server_url)) > 0
    )
    error_message = "serviceendpoint_checkmarx_one requires non-empty service_endpoint_name and server_url."
  }
}

# -----------------------------------------------------------------------------
# Checkmarx SAST
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_sast" {
  description = "Checkmarx SAST service endpoint."
  type = object({
    service_endpoint_name = string
    server_url            = string
    username              = string
    password              = string
    team                  = optional(string)
    preset                = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_checkmarx_sast == null || (
      length(trimspace(var.serviceendpoint_checkmarx_sast.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sast.server_url)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sast.username)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sast.password)) > 0
    )
    error_message = "serviceendpoint_checkmarx_sast requires non-empty service_endpoint_name, server_url, username, and password."
  }
}

# -----------------------------------------------------------------------------
# Checkmarx SCA
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_sca" {
  description = "Checkmarx SCA service endpoint."
  type = object({
    service_endpoint_name = string
    access_control_url    = string
    server_url            = string
    web_app_url           = string
    account               = string
    username              = string
    password              = string
    team                  = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_checkmarx_sca == null || (
      length(trimspace(var.serviceendpoint_checkmarx_sca.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sca.access_control_url)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sca.server_url)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sca.web_app_url)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sca.account)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sca.username)) > 0 &&
      length(trimspace(var.serviceendpoint_checkmarx_sca.password)) > 0
    )
    error_message = "serviceendpoint_checkmarx_sca requires non-empty service_endpoint_name, access_control_url, server_url, web_app_url, account, username, and password."
  }
}

# -----------------------------------------------------------------------------
# Docker Registry
# -----------------------------------------------------------------------------

variable "serviceendpoint_dockerregistry" {
  description = "Docker registry service endpoint."
  type = object({
    service_endpoint_name = string
    description           = optional(string)
    docker_registry       = optional(string)
    docker_username       = optional(string)
    docker_email          = optional(string)
    docker_password       = optional(string)
    registry_type         = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.serviceendpoint_dockerregistry == null || length(trimspace(var.serviceendpoint_dockerregistry.service_endpoint_name)) > 0
    error_message = "serviceendpoint_dockerregistry requires non-empty service_endpoint_name."
  }
}

# -----------------------------------------------------------------------------
# Dynamics Lifecycle Services
# -----------------------------------------------------------------------------

variable "serviceendpoint_dynamics_lifecycle_services" {
  description = "Dynamics Lifecycle Services service endpoint."
  type = object({
    service_endpoint_name           = string
    authorization_endpoint          = string
    lifecycle_services_api_endpoint = string
    client_id                       = string
    username                        = string
    password                        = string
    description                     = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_dynamics_lifecycle_services == null || (
      length(trimspace(var.serviceendpoint_dynamics_lifecycle_services.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_dynamics_lifecycle_services.authorization_endpoint)) > 0 &&
      length(trimspace(var.serviceendpoint_dynamics_lifecycle_services.lifecycle_services_api_endpoint)) > 0 &&
      length(trimspace(var.serviceendpoint_dynamics_lifecycle_services.client_id)) > 0 &&
      length(trimspace(var.serviceendpoint_dynamics_lifecycle_services.username)) > 0 &&
      length(trimspace(var.serviceendpoint_dynamics_lifecycle_services.password)) > 0
    )
    error_message = "serviceendpoint_dynamics_lifecycle_services requires non-empty service_endpoint_name, authorization_endpoint, lifecycle_services_api_endpoint, client_id, username, and password."
  }
}

# -----------------------------------------------------------------------------
# External TFS
# -----------------------------------------------------------------------------

variable "serviceendpoint_externaltfs" {
  description = "External TFS service endpoint."
  type = object({
    service_endpoint_name = string
    connection_url        = string
    description           = optional(string)
    auth_personal = object({
      personal_access_token = string
    })
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_externaltfs == null || (
      length(trimspace(var.serviceendpoint_externaltfs.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_externaltfs.connection_url)) > 0 &&
      length(trimspace(var.serviceendpoint_externaltfs.auth_personal.personal_access_token)) > 0
    )
    error_message = "serviceendpoint_externaltfs requires non-empty service_endpoint_name, connection_url, and auth_personal.personal_access_token."
  }
}

# -----------------------------------------------------------------------------
# GCP Terraform
# -----------------------------------------------------------------------------

variable "serviceendpoint_gcp_terraform" {
  description = "GCP Terraform service endpoint."
  type = object({
    service_endpoint_name = string
    private_key           = string
    token_uri             = string
    gcp_project_id        = string
    client_email          = optional(string)
    scope                 = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_gcp_terraform == null || (
      length(trimspace(var.serviceendpoint_gcp_terraform.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_gcp_terraform.private_key)) > 0 &&
      length(trimspace(var.serviceendpoint_gcp_terraform.token_uri)) > 0 &&
      length(trimspace(var.serviceendpoint_gcp_terraform.gcp_project_id)) > 0
    )
    error_message = "serviceendpoint_gcp_terraform requires non-empty service_endpoint_name, private_key, token_uri, and gcp_project_id."
  }
}

# -----------------------------------------------------------------------------
# Generic
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic" {
  description = "Generic service endpoint."
  type = object({
    service_endpoint_name = string
    server_url            = string
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_generic == null || (
      length(trimspace(var.serviceendpoint_generic.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_generic.server_url)) > 0
    )
    error_message = "serviceendpoint_generic requires non-empty service_endpoint_name and server_url."
  }
}

# -----------------------------------------------------------------------------
# Generic Git
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic_git" {
  description = "Generic Git service endpoint."
  type = object({
    service_endpoint_name   = string
    repository_url          = string
    username                = optional(string)
    password                = optional(string)
    enable_pipelines_access = optional(bool)
    description             = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_generic_git == null || (
      length(trimspace(var.serviceendpoint_generic_git.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_generic_git.repository_url)) > 0
    )
    error_message = "serviceendpoint_generic_git requires non-empty service_endpoint_name and repository_url."
  }
}

# -----------------------------------------------------------------------------
# Generic v2
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic_v2" {
  description = "Generic v2 service endpoint."
  type = object({
    name                     = string
    type                     = string
    server_url               = string
    authorization_scheme     = string
    shared_project_ids       = optional(list(string))
    description              = optional(string)
    authorization_parameters = optional(map(string))
    parameters               = optional(map(string))
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_generic_v2 == null || (
      length(trimspace(var.serviceendpoint_generic_v2.name)) > 0 &&
      length(trimspace(var.serviceendpoint_generic_v2.type)) > 0 &&
      length(trimspace(var.serviceendpoint_generic_v2.server_url)) > 0 &&
      length(trimspace(var.serviceendpoint_generic_v2.authorization_scheme)) > 0
    )
    error_message = "serviceendpoint_generic_v2 requires non-empty name, type, server_url, and authorization_scheme."
  }

  validation {
    condition = var.serviceendpoint_generic_v2 == null || (
      var.serviceendpoint_generic_v2.shared_project_ids == null || alltrue([
        for project_id in var.serviceendpoint_generic_v2.shared_project_ids : length(trimspace(project_id)) > 0
      ])
    )
    error_message = "serviceendpoint_generic_v2.shared_project_ids entries must be non-empty strings."
  }
}

# -----------------------------------------------------------------------------
# GitHub
# -----------------------------------------------------------------------------

variable "serviceendpoint_github" {
  description = "GitHub service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.serviceendpoint_github == null || length(trimspace(var.serviceendpoint_github.service_endpoint_name)) > 0
    error_message = "serviceendpoint_github requires non-empty service_endpoint_name."
  }

  validation {
    condition = var.serviceendpoint_github == null || (
      (
        (var.serviceendpoint_github.auth_personal != null || var.serviceendpoint_github.personal_access_token != null) !=
        (var.serviceendpoint_github.auth_oauth != null || var.serviceendpoint_github.oauth_configuration_id != null)
      ) &&
      (var.serviceendpoint_github.auth_personal == null || length(trimspace(var.serviceendpoint_github.auth_personal.personal_access_token)) > 0) &&
      (var.serviceendpoint_github.personal_access_token == null || length(trimspace(var.serviceendpoint_github.personal_access_token)) > 0) &&
      (var.serviceendpoint_github.auth_oauth == null || length(trimspace(var.serviceendpoint_github.auth_oauth.oauth_configuration_id)) > 0) &&
      (var.serviceendpoint_github.oauth_configuration_id == null || length(trimspace(var.serviceendpoint_github.oauth_configuration_id)) > 0)
    )
    error_message = "serviceendpoint_github requires exactly one of personal access token or OAuth configuration."
  }
}

# -----------------------------------------------------------------------------
# GitHub Enterprise
# -----------------------------------------------------------------------------

variable "serviceendpoint_github_enterprise" {
  description = "GitHub Enterprise service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.serviceendpoint_github_enterprise == null || length(trimspace(var.serviceendpoint_github_enterprise.service_endpoint_name)) > 0
    error_message = "serviceendpoint_github_enterprise requires non-empty service_endpoint_name."
  }

  validation {
    condition = var.serviceendpoint_github_enterprise == null || (
      (
        (var.serviceendpoint_github_enterprise.auth_personal != null || var.serviceendpoint_github_enterprise.personal_access_token != null) !=
        (var.serviceendpoint_github_enterprise.auth_oauth != null || var.serviceendpoint_github_enterprise.oauth_configuration_id != null)
      ) &&
      (var.serviceendpoint_github_enterprise.auth_personal == null || length(trimspace(var.serviceendpoint_github_enterprise.auth_personal.personal_access_token)) > 0) &&
      (var.serviceendpoint_github_enterprise.personal_access_token == null || length(trimspace(var.serviceendpoint_github_enterprise.personal_access_token)) > 0) &&
      (var.serviceendpoint_github_enterprise.auth_oauth == null || length(trimspace(var.serviceendpoint_github_enterprise.auth_oauth.oauth_configuration_id)) > 0) &&
      (var.serviceendpoint_github_enterprise.oauth_configuration_id == null || length(trimspace(var.serviceendpoint_github_enterprise.oauth_configuration_id)) > 0)
    )
    error_message = "serviceendpoint_github_enterprise requires exactly one of personal access token or OAuth configuration."
  }
}

# -----------------------------------------------------------------------------
# GitLab
# -----------------------------------------------------------------------------

variable "serviceendpoint_gitlab" {
  description = "GitLab service endpoint."
  type = object({
    service_endpoint_name = string
    url                   = string
    username              = string
    api_token             = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_gitlab == null || (
      length(trimspace(var.serviceendpoint_gitlab.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_gitlab.url)) > 0 &&
      length(trimspace(var.serviceendpoint_gitlab.username)) > 0 &&
      length(trimspace(var.serviceendpoint_gitlab.api_token)) > 0
    )
    error_message = "serviceendpoint_gitlab requires non-empty service_endpoint_name, url, username, and api_token."
  }
}

# -----------------------------------------------------------------------------
# Incoming Webhook
# -----------------------------------------------------------------------------

variable "serviceendpoint_incomingwebhook" {
  description = "Incoming webhook service endpoint."
  type = object({
    service_endpoint_name = string
    webhook_name          = string
    description           = optional(string)
    http_header           = optional(string)
    secret                = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_incomingwebhook == null || (
      length(trimspace(var.serviceendpoint_incomingwebhook.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_incomingwebhook.webhook_name)) > 0
    )
    error_message = "serviceendpoint_incomingwebhook requires non-empty service_endpoint_name and webhook_name."
  }
}

# -----------------------------------------------------------------------------
# Jenkins
# -----------------------------------------------------------------------------

variable "serviceendpoint_jenkins" {
  description = "Jenkins service endpoint."
  type = object({
    service_endpoint_name  = string
    url                    = string
    username               = string
    password               = string
    accept_untrusted_certs = optional(bool)
    description            = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_jenkins == null || (
      length(trimspace(var.serviceendpoint_jenkins.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_jenkins.url)) > 0 &&
      length(trimspace(var.serviceendpoint_jenkins.username)) > 0 &&
      length(trimspace(var.serviceendpoint_jenkins.password)) > 0
    )
    error_message = "serviceendpoint_jenkins requires non-empty service_endpoint_name, url, username, and password."
  }
}

# -----------------------------------------------------------------------------
# JFrog Artifactory v2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_artifactory_v2" {
  description = "JFrog Artifactory v2 service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_jfrog_artifactory_v2 == null || (
      length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.url)) > 0
    )
    error_message = "serviceendpoint_jfrog_artifactory_v2 requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_jfrog_artifactory_v2 == null || (
      (var.serviceendpoint_jfrog_artifactory_v2.authentication_token != null) != (var.serviceendpoint_jfrog_artifactory_v2.authentication_basic != null) &&
      (var.serviceendpoint_jfrog_artifactory_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.authentication_token.token)) > 0) &&
      (var.serviceendpoint_jfrog_artifactory_v2.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_jfrog_artifactory_v2.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_jfrog_artifactory_v2 requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# JFrog Distribution v2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_distribution_v2" {
  description = "JFrog Distribution v2 service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_jfrog_distribution_v2 == null || (
      length(trimspace(var.serviceendpoint_jfrog_distribution_v2.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_jfrog_distribution_v2.url)) > 0
    )
    error_message = "serviceendpoint_jfrog_distribution_v2 requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_jfrog_distribution_v2 == null || (
      (var.serviceendpoint_jfrog_distribution_v2.authentication_token != null) != (var.serviceendpoint_jfrog_distribution_v2.authentication_basic != null) &&
      (var.serviceendpoint_jfrog_distribution_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_distribution_v2.authentication_token.token)) > 0) &&
      (var.serviceendpoint_jfrog_distribution_v2.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_jfrog_distribution_v2.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_jfrog_distribution_v2.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_jfrog_distribution_v2 requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# JFrog Platform v2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_platform_v2" {
  description = "JFrog Platform v2 service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_jfrog_platform_v2 == null || (
      length(trimspace(var.serviceendpoint_jfrog_platform_v2.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_jfrog_platform_v2.url)) > 0
    )
    error_message = "serviceendpoint_jfrog_platform_v2 requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_jfrog_platform_v2 == null || (
      (var.serviceendpoint_jfrog_platform_v2.authentication_token != null) != (var.serviceendpoint_jfrog_platform_v2.authentication_basic != null) &&
      (var.serviceendpoint_jfrog_platform_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_platform_v2.authentication_token.token)) > 0) &&
      (var.serviceendpoint_jfrog_platform_v2.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_jfrog_platform_v2.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_jfrog_platform_v2.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_jfrog_platform_v2 requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# JFrog Xray v2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_xray_v2" {
  description = "JFrog Xray v2 service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_jfrog_xray_v2 == null || (
      length(trimspace(var.serviceendpoint_jfrog_xray_v2.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_jfrog_xray_v2.url)) > 0
    )
    error_message = "serviceendpoint_jfrog_xray_v2 requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_jfrog_xray_v2 == null || (
      (var.serviceendpoint_jfrog_xray_v2.authentication_token != null) != (var.serviceendpoint_jfrog_xray_v2.authentication_basic != null) &&
      (var.serviceendpoint_jfrog_xray_v2.authentication_token == null || length(trimspace(var.serviceendpoint_jfrog_xray_v2.authentication_token.token)) > 0) &&
      (var.serviceendpoint_jfrog_xray_v2.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_jfrog_xray_v2.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_jfrog_xray_v2.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_jfrog_xray_v2 requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes
# -----------------------------------------------------------------------------

variable "serviceendpoint_kubernetes" {
  description = "Kubernetes service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_kubernetes == null || (
      length(trimspace(var.serviceendpoint_kubernetes.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_kubernetes.apiserver_url)) > 0 &&
      contains(["AzureSubscription", "Kubeconfig", "ServiceAccount"], var.serviceendpoint_kubernetes.authorization_type)
    )
    error_message = "serviceendpoint_kubernetes requires non-empty service_endpoint_name, apiserver_url, and a valid authorization_type."
  }

  validation {
    condition = var.serviceendpoint_kubernetes == null || (
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

  validation {
    condition = var.serviceendpoint_kubernetes == null || (
      var.serviceendpoint_kubernetes.azure_subscription == null || (
        length(trimspace(var.serviceendpoint_kubernetes.azure_subscription.cluster_name)) > 0 &&
        length(trimspace(var.serviceendpoint_kubernetes.azure_subscription.subscription_id)) > 0 &&
        length(trimspace(var.serviceendpoint_kubernetes.azure_subscription.subscription_name)) > 0 &&
        length(trimspace(var.serviceendpoint_kubernetes.azure_subscription.tenant_id)) > 0 &&
        length(trimspace(var.serviceendpoint_kubernetes.azure_subscription.resourcegroup_id)) > 0
      )
    )
    error_message = "serviceendpoint_kubernetes.azure_subscription requires non-empty cluster_name, subscription_id, subscription_name, tenant_id, and resourcegroup_id."
  }

  validation {
    condition = var.serviceendpoint_kubernetes == null || (
      var.serviceendpoint_kubernetes.kubeconfig == null || length(trimspace(var.serviceendpoint_kubernetes.kubeconfig.kube_config)) > 0
    )
    error_message = "serviceendpoint_kubernetes.kubeconfig.kube_config must be a non-empty string when provided."
  }

  validation {
    condition = var.serviceendpoint_kubernetes == null || (
      var.serviceendpoint_kubernetes.service_account == null || (
        length(trimspace(var.serviceendpoint_kubernetes.service_account.token)) > 0 &&
        length(trimspace(var.serviceendpoint_kubernetes.service_account.ca_cert)) > 0
      )
    )
    error_message = "serviceendpoint_kubernetes.service_account requires non-empty token and ca_cert when provided."
  }
}

# -----------------------------------------------------------------------------
# Maven
# -----------------------------------------------------------------------------

variable "serviceendpoint_maven" {
  description = "Maven service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_maven == null || (
      length(trimspace(var.serviceendpoint_maven.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_maven.url)) > 0 &&
      length(trimspace(var.serviceendpoint_maven.repository_id)) > 0
    )
    error_message = "serviceendpoint_maven requires non-empty service_endpoint_name, url, and repository_id."
  }

  validation {
    condition = var.serviceendpoint_maven == null || (
      (var.serviceendpoint_maven.authentication_token != null) != (var.serviceendpoint_maven.authentication_basic != null) &&
      (var.serviceendpoint_maven.authentication_token == null || length(trimspace(var.serviceendpoint_maven.authentication_token.token)) > 0) &&
      (var.serviceendpoint_maven.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_maven.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_maven.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_maven requires exactly one authentication method with non-empty credentials."
  }
}

# -----------------------------------------------------------------------------
# Nexus
# -----------------------------------------------------------------------------

variable "serviceendpoint_nexus" {
  description = "Nexus service endpoint."
  type = object({
    service_endpoint_name = string
    url                   = string
    username              = string
    password              = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_nexus == null || (
      length(trimspace(var.serviceendpoint_nexus.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_nexus.url)) > 0 &&
      length(trimspace(var.serviceendpoint_nexus.username)) > 0 &&
      length(trimspace(var.serviceendpoint_nexus.password)) > 0
    )
    error_message = "serviceendpoint_nexus requires non-empty service_endpoint_name, url, username, and password."
  }
}

# -----------------------------------------------------------------------------
# NPM
# -----------------------------------------------------------------------------

variable "serviceendpoint_npm" {
  description = "NPM service endpoint."
  type = object({
    service_endpoint_name = string
    url                   = string
    access_token          = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_npm == null || (
      length(trimspace(var.serviceendpoint_npm.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_npm.url)) > 0 &&
      length(trimspace(var.serviceendpoint_npm.access_token)) > 0
    )
    error_message = "serviceendpoint_npm requires non-empty service_endpoint_name, url, and access_token."
  }
}

# -----------------------------------------------------------------------------
# NuGet
# -----------------------------------------------------------------------------

variable "serviceendpoint_nuget" {
  description = "NuGet service endpoint."
  type = object({
    service_endpoint_name = string
    feed_url              = string
    api_key               = optional(string)
    personal_access_token = optional(string)
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_nuget == null || (
      length(trimspace(var.serviceendpoint_nuget.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_nuget.feed_url)) > 0 &&
      (var.serviceendpoint_nuget.api_key == null || length(trimspace(var.serviceendpoint_nuget.api_key)) > 0) &&
      (var.serviceendpoint_nuget.personal_access_token == null || length(trimspace(var.serviceendpoint_nuget.personal_access_token)) > 0) &&
      (var.serviceendpoint_nuget.username == null || length(trimspace(var.serviceendpoint_nuget.username)) > 0) &&
      (var.serviceendpoint_nuget.password == null || length(trimspace(var.serviceendpoint_nuget.password)) > 0)
    )
    error_message = "serviceendpoint_nuget requires non-empty service_endpoint_name, feed_url, and non-empty credentials when provided."
  }

  validation {
    condition = var.serviceendpoint_nuget == null || (
      (var.serviceendpoint_nuget.username == null && var.serviceendpoint_nuget.password == null) ||
      (var.serviceendpoint_nuget.username != null && var.serviceendpoint_nuget.password != null)
    )
    error_message = "serviceendpoint_nuget requires both username and password when using basic auth."
  }

  validation {
    condition = var.serviceendpoint_nuget == null || length(compact([
      var.serviceendpoint_nuget.api_key != null ? "api_key" : "",
      var.serviceendpoint_nuget.personal_access_token != null ? "pat" : "",
      (var.serviceendpoint_nuget.username != null || var.serviceendpoint_nuget.password != null) ? "basic" : "",
    ])) <= 1
    error_message = "serviceendpoint_nuget allows only one authentication method (api_key, personal_access_token, or username/password)."
  }
}

# -----------------------------------------------------------------------------
# Octopus Deploy
# -----------------------------------------------------------------------------

variable "serviceendpoint_octopusdeploy" {
  description = "Octopus Deploy service endpoint."
  type = object({
    service_endpoint_name = string
    url                   = string
    api_key               = string
    ignore_ssl_error      = optional(bool)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_octopusdeploy == null || (
      length(trimspace(var.serviceendpoint_octopusdeploy.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_octopusdeploy.url)) > 0 &&
      length(trimspace(var.serviceendpoint_octopusdeploy.api_key)) > 0
    )
    error_message = "serviceendpoint_octopusdeploy requires non-empty service_endpoint_name, url, and api_key."
  }
}

# -----------------------------------------------------------------------------
# OpenShift
# -----------------------------------------------------------------------------

variable "serviceendpoint_openshift" {
  description = "OpenShift service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.serviceendpoint_openshift == null || length(trimspace(var.serviceendpoint_openshift.service_endpoint_name)) > 0
    error_message = "serviceendpoint_openshift requires non-empty service_endpoint_name."
  }

  validation {
    condition = var.serviceendpoint_openshift == null || length(compact([
      var.serviceendpoint_openshift.auth_basic != null ? "basic" : "",
      var.serviceendpoint_openshift.auth_token != null ? "token" : "",
      var.serviceendpoint_openshift.auth_none != null ? "none" : "",
    ])) == 1
    error_message = "serviceendpoint_openshift requires exactly one of auth_basic, auth_token, or auth_none."
  }

  validation {
    condition = var.serviceendpoint_openshift == null || (
      var.serviceendpoint_openshift.auth_basic == null || (
        length(trimspace(var.serviceendpoint_openshift.auth_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_openshift.auth_basic.password)) > 0
      )
    )
    error_message = "serviceendpoint_openshift.auth_basic requires non-empty username and password when provided."
  }

  validation {
    condition = var.serviceendpoint_openshift == null || (
      var.serviceendpoint_openshift.auth_token == null || length(trimspace(var.serviceendpoint_openshift.auth_token.token)) > 0
    )
    error_message = "serviceendpoint_openshift.auth_token.token must be non-empty when provided."
  }
}

# -----------------------------------------------------------------------------
# Permissions
# -----------------------------------------------------------------------------

variable "serviceendpoint_permissions" {
  description = "List of service endpoint permissions to assign."
  type = list(object({
    key                = optional(string)
    serviceendpoint_id = optional(string)
    principal          = string
    permissions        = map(string)
    replace            = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : (
        (permission.key == null || trimspace(permission.key) != "") &&
        trimspace(permission.principal) != "" &&
        (permission.serviceendpoint_id == null || trimspace(permission.serviceendpoint_id) != "")
      )
    ])
    error_message = "serviceendpoint_permissions.key, serviceendpoint_permissions.principal, and serviceendpoint_permissions.serviceendpoint_id must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : alltrue([
        for status in values(permission.permissions) : contains(["Allow", "Deny", "NotSet"], status)
      ])
    ])
    error_message = "serviceendpoint_permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length(var.serviceendpoint_permissions) == length(distinct([
      for permission in var.serviceendpoint_permissions : coalesce(permission.key, permission.principal)
    ]))
    error_message = "serviceendpoint_permissions entries must have unique keys (key or principal)."
  }
}

# -----------------------------------------------------------------------------
# Run pipeline
# -----------------------------------------------------------------------------

variable "serviceendpoint_runpipeline" {
  description = "Run pipeline service endpoint."
  type = object({
    service_endpoint_name = string
    organization_name     = string
    description           = optional(string)
    auth_personal = object({
      personal_access_token = string
    })
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_runpipeline == null || (
      length(trimspace(var.serviceendpoint_runpipeline.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_runpipeline.organization_name)) > 0 &&
      length(trimspace(var.serviceendpoint_runpipeline.auth_personal.personal_access_token)) > 0
    )
    error_message = "serviceendpoint_runpipeline requires non-empty service_endpoint_name, organization_name, and auth_personal.personal_access_token."
  }
}

# -----------------------------------------------------------------------------
# Service Fabric
# -----------------------------------------------------------------------------

variable "serviceendpoint_servicefabric" {
  description = "Service Fabric service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_servicefabric == null || (
      length(trimspace(var.serviceendpoint_servicefabric.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_servicefabric.cluster_endpoint)) > 0
    )
    error_message = "serviceendpoint_servicefabric requires non-empty service_endpoint_name and cluster_endpoint."
  }

  validation {
    condition = var.serviceendpoint_servicefabric == null || length(compact([
      var.serviceendpoint_servicefabric.certificate != null ? "certificate" : "",
      var.serviceendpoint_servicefabric.azure_active_directory != null ? "aad" : "",
      var.serviceendpoint_servicefabric.none != null ? "none" : "",
    ])) == 1
    error_message = "serviceendpoint_servicefabric requires exactly one of certificate, azure_active_directory, or none."
  }

  validation {
    condition = var.serviceendpoint_servicefabric == null || (
      var.serviceendpoint_servicefabric.certificate == null || (
        length(trimspace(var.serviceendpoint_servicefabric.certificate.server_certificate_lookup)) > 0 &&
        length(trimspace(var.serviceendpoint_servicefabric.certificate.client_certificate)) > 0
      )
    )
    error_message = "serviceendpoint_servicefabric.certificate requires non-empty server_certificate_lookup and client_certificate."
  }

  validation {
    condition = var.serviceendpoint_servicefabric == null || (
      var.serviceendpoint_servicefabric.azure_active_directory == null || (
        length(trimspace(var.serviceendpoint_servicefabric.azure_active_directory.server_certificate_lookup)) > 0 &&
        length(trimspace(var.serviceendpoint_servicefabric.azure_active_directory.username)) > 0 &&
        length(trimspace(var.serviceendpoint_servicefabric.azure_active_directory.password)) > 0
      )
    )
    error_message = "serviceendpoint_servicefabric.azure_active_directory requires non-empty server_certificate_lookup, username, and password."
  }
}

# -----------------------------------------------------------------------------
# Snyk
# -----------------------------------------------------------------------------

variable "serviceendpoint_snyk" {
  description = "Snyk service endpoint."
  type = object({
    service_endpoint_name = string
    server_url            = string
    api_token             = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_snyk == null || (
      length(trimspace(var.serviceendpoint_snyk.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_snyk.server_url)) > 0 &&
      length(trimspace(var.serviceendpoint_snyk.api_token)) > 0
    )
    error_message = "serviceendpoint_snyk requires non-empty service_endpoint_name, server_url, and api_token."
  }
}

# -----------------------------------------------------------------------------
# SonarCloud
# -----------------------------------------------------------------------------

variable "serviceendpoint_sonarcloud" {
  description = "SonarCloud service endpoint."
  type = object({
    service_endpoint_name = string
    token                 = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_sonarcloud == null || (
      length(trimspace(var.serviceendpoint_sonarcloud.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_sonarcloud.token)) > 0
    )
    error_message = "serviceendpoint_sonarcloud requires non-empty service_endpoint_name and token."
  }
}

# -----------------------------------------------------------------------------
# SonarQube
# -----------------------------------------------------------------------------

variable "serviceendpoint_sonarqube" {
  description = "SonarQube service endpoint."
  type = object({
    service_endpoint_name = string
    url                   = string
    token                 = string
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_sonarqube == null || (
      length(trimspace(var.serviceendpoint_sonarqube.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_sonarqube.url)) > 0 &&
      length(trimspace(var.serviceendpoint_sonarqube.token)) > 0
    )
    error_message = "serviceendpoint_sonarqube requires non-empty service_endpoint_name, url, and token."
  }
}

# -----------------------------------------------------------------------------
# SSH
# -----------------------------------------------------------------------------

variable "serviceendpoint_ssh" {
  description = "SSH service endpoint."
  type = object({
    service_endpoint_name = string
    host                  = string
    username              = string
    port                  = optional(number)
    password              = optional(string)
    private_key           = optional(string)
    description           = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_ssh == null || (
      length(trimspace(var.serviceendpoint_ssh.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_ssh.host)) > 0 &&
      length(trimspace(var.serviceendpoint_ssh.username)) > 0
    )
    error_message = "serviceendpoint_ssh requires non-empty service_endpoint_name, host, and username."
  }

  validation {
    condition = var.serviceendpoint_ssh == null || (
      (var.serviceendpoint_ssh.password != null) != (var.serviceendpoint_ssh.private_key != null)
    )
    error_message = "serviceendpoint_ssh requires exactly one of password or private_key."
  }

  validation {
    condition = var.serviceendpoint_ssh == null || (
      (var.serviceendpoint_ssh.password == null || length(trimspace(var.serviceendpoint_ssh.password)) > 0) &&
      (var.serviceendpoint_ssh.private_key == null || length(trimspace(var.serviceendpoint_ssh.private_key)) > 0)
    )
    error_message = "serviceendpoint_ssh password or private_key must be non-empty when provided."
  }
}

# -----------------------------------------------------------------------------
# Visual Studio Marketplace
# -----------------------------------------------------------------------------

variable "serviceendpoint_visualstudiomarketplace" {
  description = "Visual Studio Marketplace service endpoint."
  type = object({
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
  })
  default   = null
  sensitive = true

  validation {
    condition = var.serviceendpoint_visualstudiomarketplace == null || (
      length(trimspace(var.serviceendpoint_visualstudiomarketplace.service_endpoint_name)) > 0 &&
      length(trimspace(var.serviceendpoint_visualstudiomarketplace.url)) > 0
    )
    error_message = "serviceendpoint_visualstudiomarketplace requires non-empty service_endpoint_name and url."
  }

  validation {
    condition = var.serviceendpoint_visualstudiomarketplace == null || (
      (var.serviceendpoint_visualstudiomarketplace.authentication_token != null) != (var.serviceendpoint_visualstudiomarketplace.authentication_basic != null) &&
      (var.serviceendpoint_visualstudiomarketplace.authentication_token == null || length(trimspace(var.serviceendpoint_visualstudiomarketplace.authentication_token.token)) > 0) &&
      (var.serviceendpoint_visualstudiomarketplace.authentication_basic == null || (
        length(trimspace(var.serviceendpoint_visualstudiomarketplace.authentication_basic.username)) > 0 &&
        length(trimspace(var.serviceendpoint_visualstudiomarketplace.authentication_basic.password)) > 0
      ))
    )
    error_message = "serviceendpoint_visualstudiomarketplace requires exactly one authentication method with non-empty credentials."
  }
}
