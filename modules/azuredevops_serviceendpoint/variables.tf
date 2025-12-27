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
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_argocd : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_argocd requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_argocd : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_argocd)
    error_message = "serviceendpoint_argocd keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Artifactory
# -----------------------------------------------------------------------------

variable "serviceendpoint_artifactory" {
  description = "List of Artifactory service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_artifactory : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_artifactory requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_artifactory : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_artifactory)
    error_message = "serviceendpoint_artifactory keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# AWS
# -----------------------------------------------------------------------------

variable "serviceendpoint_aws" {
  description = "List of AWS service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_aws : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_aws requires non-empty service_endpoint_name; key must be non-empty when provided."
  }

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_aws : (
        endpoint.use_oidc == true
        ? (
          endpoint.access_key_id == null &&
          endpoint.secret_access_key == null &&
          length(trimspace(coalesce(endpoint.role_to_assume, ""))) > 0 &&
          length(trimspace(coalesce(endpoint.role_session_name, ""))) > 0
        )
        : (
          length(trimspace(coalesce(endpoint.access_key_id, ""))) > 0 &&
          length(trimspace(coalesce(endpoint.secret_access_key, ""))) > 0
        )
      )
    ])
    error_message = "serviceendpoint_aws requires access_key_id/secret_access_key or OIDC with role_to_assume and role_session_name, but not both."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_aws : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_aws)
    error_message = "serviceendpoint_aws keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Azure Service Bus
# -----------------------------------------------------------------------------

variable "serviceendpoint_azure_service_bus" {
  description = "List of Azure Service Bus service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    queue_name            = string
    connection_string     = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_azure_service_bus : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.queue_name)) > 0 &&
        length(trimspace(endpoint.connection_string)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_azure_service_bus requires non-empty service_endpoint_name, queue_name, and connection_string; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_azure_service_bus : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_azure_service_bus)
    error_message = "serviceendpoint_azure_service_bus keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------

variable "serviceendpoint_azurecr" {
  description = "List of Azure Container Registry service endpoints."
  type = list(object({
    key                                   = optional(string)
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

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_azurecr : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.resource_group)) > 0 &&
        length(trimspace(endpoint.azurecr_spn_tenantid)) > 0 &&
        length(trimspace(endpoint.azurecr_name)) > 0 &&
        length(trimspace(endpoint.azurecr_subscription_id)) > 0 &&
        length(trimspace(endpoint.azurecr_subscription_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.credentials == null || length(trimspace(endpoint.credentials.serviceprincipalid)) > 0)
      )
    ])
    error_message = "serviceendpoint_azurecr requires non-empty service_endpoint_name, resource_group, tenant, registry, and subscription fields; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_azurecr : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_azurecr)
    error_message = "serviceendpoint_azurecr keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Azure Resource Manager
# -----------------------------------------------------------------------------

variable "serviceendpoint_azurerm" {
  description = "List of Azure Resource Manager service endpoints."
  type = list(object({
    key                                   = optional(string)
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
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_azurerm : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.azurerm_spn_tenantid)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.serviceprincipalid == null || length(trimspace(endpoint.serviceprincipalid)) > 0) &&
        (endpoint.serviceprincipalkey == null || length(trimspace(endpoint.serviceprincipalkey)) > 0) &&
        (endpoint.serviceprincipalcertificate == null || length(trimspace(endpoint.serviceprincipalcertificate)) > 0) &&
        (
          endpoint.credentials == null || (
            length(trimspace(endpoint.credentials.serviceprincipalid)) > 0 &&
            (endpoint.credentials.serviceprincipalkey == null || length(trimspace(endpoint.credentials.serviceprincipalkey)) > 0) &&
            (endpoint.credentials.serviceprincipalcertificate == null || length(trimspace(endpoint.credentials.serviceprincipalcertificate)) > 0)
          )
        ) &&
        (
          (endpoint.serviceprincipalid != null && length(trimspace(endpoint.serviceprincipalid)) > 0) ||
          (endpoint.credentials != null && length(trimspace(endpoint.credentials.serviceprincipalid)) > 0)
        )
      )
    ])
    error_message = "serviceendpoint_azurerm requires non-empty service_endpoint_name, azurerm_spn_tenantid, and a service principal ID (top-level or credentials); key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_azurerm : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_azurerm)
    error_message = "serviceendpoint_azurerm keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Bitbucket
# -----------------------------------------------------------------------------

variable "serviceendpoint_bitbucket" {
  description = "List of Bitbucket service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    username              = string
    password              = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_bitbucket : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.password)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_bitbucket requires non-empty service_endpoint_name, username, and password; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_bitbucket : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_bitbucket)
    error_message = "serviceendpoint_bitbucket keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Black Duck
# -----------------------------------------------------------------------------

variable "serviceendpoint_black_duck" {
  description = "List of Black Duck service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    server_url            = string
    api_token             = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_black_duck : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        length(trimspace(endpoint.api_token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_black_duck requires non-empty service_endpoint_name, server_url, and api_token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_black_duck : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_black_duck)
    error_message = "serviceendpoint_black_duck keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Checkmarx One
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_one" {
  description = "List of Checkmarx One service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    server_url            = string
    authorization_url     = optional(string)
    api_key               = optional(string)
    client_id             = optional(string)
    client_secret         = optional(string)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_checkmarx_one : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.authorization_url == null || length(trimspace(endpoint.authorization_url)) > 0) &&
        (endpoint.api_key == null || length(trimspace(endpoint.api_key)) > 0) &&
        (endpoint.client_id == null || length(trimspace(endpoint.client_id)) > 0) &&
        (endpoint.client_secret == null || length(trimspace(endpoint.client_secret)) > 0)
      )
    ])
    error_message = "serviceendpoint_checkmarx_one requires non-empty service_endpoint_name and server_url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_checkmarx_one : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_checkmarx_one)
    error_message = "serviceendpoint_checkmarx_one keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Checkmarx SAST
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_sast" {
  description = "List of Checkmarx SAST service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    server_url            = string
    username              = string
    password              = string
    team                  = optional(string)
    preset                = optional(string)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_checkmarx_sast : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.password)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.team == null || length(trimspace(endpoint.team)) > 0) &&
        (endpoint.preset == null || length(trimspace(endpoint.preset)) > 0)
      )
    ])
    error_message = "serviceendpoint_checkmarx_sast requires non-empty service_endpoint_name, server_url, username, and password; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_checkmarx_sast : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_checkmarx_sast)
    error_message = "serviceendpoint_checkmarx_sast keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Checkmarx SCA
# -----------------------------------------------------------------------------

variable "serviceendpoint_checkmarx_sca" {
  description = "List of Checkmarx SCA service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_checkmarx_sca : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.access_control_url)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        length(trimspace(endpoint.web_app_url)) > 0 &&
        length(trimspace(endpoint.account)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.password)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.team == null || length(trimspace(endpoint.team)) > 0)
      )
    ])
    error_message = "serviceendpoint_checkmarx_sca requires non-empty endpoints, account, username, and password; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_checkmarx_sca : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_checkmarx_sca)
    error_message = "serviceendpoint_checkmarx_sca keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Docker Registry
# -----------------------------------------------------------------------------

variable "serviceendpoint_dockerregistry" {
  description = "List of Docker registry service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    description           = optional(string)
    docker_registry       = optional(string)
    docker_username       = optional(string)
    docker_email          = optional(string)
    docker_password       = optional(string)
    registry_type         = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_dockerregistry : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.docker_registry == null || length(trimspace(endpoint.docker_registry)) > 0) &&
        (endpoint.docker_username == null || length(trimspace(endpoint.docker_username)) > 0) &&
        (endpoint.docker_email == null || length(trimspace(endpoint.docker_email)) > 0) &&
        (endpoint.docker_password == null || length(trimspace(endpoint.docker_password)) > 0) &&
        (endpoint.registry_type == null || length(trimspace(endpoint.registry_type)) > 0)
      )
    ])
    error_message = "serviceendpoint_dockerregistry requires non-empty service_endpoint_name; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_dockerregistry : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_dockerregistry)
    error_message = "serviceendpoint_dockerregistry keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Dynamics Lifecycle Services
# -----------------------------------------------------------------------------

variable "serviceendpoint_dynamics_lifecycle_services" {
  description = "List of Dynamics Lifecycle Services service endpoints."
  type = list(object({
    key                            = optional(string)
    service_endpoint_name           = string
    authorization_endpoint          = string
    lifecycle_services_api_endpoint = string
    client_id                       = string
    username                        = string
    password                        = string
    description                     = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_dynamics_lifecycle_services : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.authorization_endpoint)) > 0 &&
        length(trimspace(endpoint.lifecycle_services_api_endpoint)) > 0 &&
        length(trimspace(endpoint.client_id)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.password)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_dynamics_lifecycle_services requires non-empty service_endpoint_name, endpoints, client_id, username, and password; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_dynamics_lifecycle_services : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_dynamics_lifecycle_services)
    error_message = "serviceendpoint_dynamics_lifecycle_services keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# External TFS
# -----------------------------------------------------------------------------

variable "serviceendpoint_externaltfs" {
  description = "List of external TFS service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    connection_url        = string
    description           = optional(string)
    auth_personal = object({
      personal_access_token = string
    })
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_externaltfs : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.connection_url)) > 0 &&
        length(trimspace(endpoint.auth_personal.personal_access_token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_externaltfs requires non-empty service_endpoint_name, connection_url, and auth_personal.personal_access_token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_externaltfs : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_externaltfs)
    error_message = "serviceendpoint_externaltfs keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# GCP Terraform
# -----------------------------------------------------------------------------

variable "serviceendpoint_gcp_terraform" {
  description = "List of GCP Terraform service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    private_key           = string
    token_uri             = string
    gcp_project_id        = string
    client_email          = optional(string)
    scope                 = optional(string)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_gcp_terraform : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.private_key)) > 0 &&
        length(trimspace(endpoint.token_uri)) > 0 &&
        length(trimspace(endpoint.gcp_project_id)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.client_email == null || length(trimspace(endpoint.client_email)) > 0) &&
        (endpoint.scope == null || length(trimspace(endpoint.scope)) > 0)
      )
    ])
    error_message = "serviceendpoint_gcp_terraform requires non-empty service_endpoint_name, private_key, token_uri, and gcp_project_id; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_gcp_terraform : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_gcp_terraform)
    error_message = "serviceendpoint_gcp_terraform keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Generic
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic" {
  description = "List of generic service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    server_url            = string
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_generic : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.username == null || length(trimspace(endpoint.username)) > 0) &&
        (endpoint.password == null || length(trimspace(endpoint.password)) > 0)
      )
    ])
    error_message = "serviceendpoint_generic requires non-empty service_endpoint_name and server_url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_generic : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_generic)
    error_message = "serviceendpoint_generic keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Generic Git
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic_git" {
  description = "List of generic Git service endpoints."
  type = list(object({
    key                     = optional(string)
    service_endpoint_name   = string
    repository_url          = string
    username                = optional(string)
    password                = optional(string)
    enable_pipelines_access = optional(bool)
    description             = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_generic_git : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.repository_url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.username == null || length(trimspace(endpoint.username)) > 0) &&
        (endpoint.password == null || length(trimspace(endpoint.password)) > 0)
      )
    ])
    error_message = "serviceendpoint_generic_git requires non-empty service_endpoint_name and repository_url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_generic_git : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_generic_git)
    error_message = "serviceendpoint_generic_git keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Generic V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_generic_v2" {
  description = "List of generic v2 service endpoints."
  type = list(object({
    key                      = optional(string)
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

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_generic_v2 : (
        length(trimspace(endpoint.name)) > 0 &&
        length(trimspace(endpoint.type)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        length(trimspace(endpoint.authorization_scheme)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_generic_v2 requires non-empty name, type, server_url, and authorization_scheme; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_generic_v2 : coalesce(endpoint.key, endpoint.name)
    ])) == length(var.serviceendpoint_generic_v2)
    error_message = "serviceendpoint_generic_v2 keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# GitHub
# -----------------------------------------------------------------------------

variable "serviceendpoint_github" {
  description = "List of GitHub service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_github : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.personal_access_token == null || length(trimspace(endpoint.personal_access_token)) > 0) &&
        (endpoint.oauth_configuration_id == null || length(trimspace(endpoint.oauth_configuration_id)) > 0) &&
        (endpoint.auth_personal == null || length(trimspace(endpoint.auth_personal.personal_access_token)) > 0) &&
        (endpoint.auth_oauth == null || length(trimspace(endpoint.auth_oauth.oauth_configuration_id)) > 0)
      )
    ])
    error_message = "serviceendpoint_github requires non-empty service_endpoint_name; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_github : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_github)
    error_message = "serviceendpoint_github keys must be unique."
  }

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_github : (
        (endpoint.auth_personal != null || endpoint.personal_access_token != null) !=
        (endpoint.auth_oauth != null || endpoint.oauth_configuration_id != null)
      )
    ])
    error_message = "serviceendpoint_github requires exactly one of personal access token or OAuth configuration."
  }
}

# -----------------------------------------------------------------------------
# GitHub Enterprise
# -----------------------------------------------------------------------------

variable "serviceendpoint_github_enterprise" {
  description = "List of GitHub Enterprise service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_github_enterprise : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.url == null || length(trimspace(endpoint.url)) > 0) &&
        (endpoint.personal_access_token == null || length(trimspace(endpoint.personal_access_token)) > 0) &&
        (endpoint.oauth_configuration_id == null || length(trimspace(endpoint.oauth_configuration_id)) > 0) &&
        (endpoint.auth_personal == null || length(trimspace(endpoint.auth_personal.personal_access_token)) > 0) &&
        (endpoint.auth_oauth == null || length(trimspace(endpoint.auth_oauth.oauth_configuration_id)) > 0)
      )
    ])
    error_message = "serviceendpoint_github_enterprise requires non-empty service_endpoint_name; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_github_enterprise : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_github_enterprise)
    error_message = "serviceendpoint_github_enterprise keys must be unique."
  }

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_github_enterprise : (
        (endpoint.auth_personal != null || endpoint.personal_access_token != null) !=
        (endpoint.auth_oauth != null || endpoint.oauth_configuration_id != null)
      )
    ])
    error_message = "serviceendpoint_github_enterprise requires exactly one of personal access token or OAuth configuration."
  }
}

# -----------------------------------------------------------------------------
# GitLab
# -----------------------------------------------------------------------------

variable "serviceendpoint_gitlab" {
  description = "List of GitLab service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    url                   = string
    username              = string
    api_token             = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_gitlab : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.api_token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_gitlab requires non-empty service_endpoint_name, url, username, and api_token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_gitlab : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_gitlab)
    error_message = "serviceendpoint_gitlab keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Incoming Webhook
# -----------------------------------------------------------------------------

variable "serviceendpoint_incomingwebhook" {
  description = "List of incoming webhook service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    webhook_name          = string
    description           = optional(string)
    http_header           = optional(string)
    secret                = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_incomingwebhook : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.webhook_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.http_header == null || length(trimspace(endpoint.http_header)) > 0) &&
        (endpoint.secret == null || length(trimspace(endpoint.secret)) > 0)
      )
    ])
    error_message = "serviceendpoint_incomingwebhook requires non-empty service_endpoint_name and webhook_name; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_incomingwebhook : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_incomingwebhook)
    error_message = "serviceendpoint_incomingwebhook keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Jenkins
# -----------------------------------------------------------------------------

variable "serviceendpoint_jenkins" {
  description = "List of Jenkins service endpoints."
  type = list(object({
    key                    = optional(string)
    service_endpoint_name  = string
    url                    = string
    username               = string
    password               = string
    accept_untrusted_certs = optional(bool)
    description            = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_jenkins : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.password)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_jenkins requires non-empty service_endpoint_name, url, username, and password; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_jenkins : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_jenkins)
    error_message = "serviceendpoint_jenkins keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# JFrog Artifactory V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_artifactory_v2" {
  description = "List of JFrog Artifactory v2 service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_jfrog_artifactory_v2 : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_jfrog_artifactory_v2 requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_jfrog_artifactory_v2 : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_jfrog_artifactory_v2)
    error_message = "serviceendpoint_jfrog_artifactory_v2 keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# JFrog Distribution V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_distribution_v2" {
  description = "List of JFrog Distribution v2 service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_jfrog_distribution_v2 : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_jfrog_distribution_v2 requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_jfrog_distribution_v2 : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_jfrog_distribution_v2)
    error_message = "serviceendpoint_jfrog_distribution_v2 keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# JFrog Platform V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_platform_v2" {
  description = "List of JFrog Platform v2 service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_jfrog_platform_v2 : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_jfrog_platform_v2 requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_jfrog_platform_v2 : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_jfrog_platform_v2)
    error_message = "serviceendpoint_jfrog_platform_v2 keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# JFrog Xray V2
# -----------------------------------------------------------------------------

variable "serviceendpoint_jfrog_xray_v2" {
  description = "List of JFrog Xray v2 service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_jfrog_xray_v2 : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_jfrog_xray_v2 requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_jfrog_xray_v2 : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_jfrog_xray_v2)
    error_message = "serviceendpoint_jfrog_xray_v2 keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes
# -----------------------------------------------------------------------------

variable "serviceendpoint_kubernetes" {
  description = "List of Kubernetes service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_kubernetes : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.apiserver_url)) > 0 &&
        length(trimspace(endpoint.authorization_type)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (
          endpoint.azure_subscription == null || (
            length(trimspace(endpoint.azure_subscription.cluster_name)) > 0 &&
            length(trimspace(endpoint.azure_subscription.subscription_id)) > 0 &&
            length(trimspace(endpoint.azure_subscription.subscription_name)) > 0 &&
            length(trimspace(endpoint.azure_subscription.tenant_id)) > 0 &&
            length(trimspace(endpoint.azure_subscription.resourcegroup_id)) > 0 &&
            (endpoint.azure_subscription.azure_environment == null || length(trimspace(endpoint.azure_subscription.azure_environment)) > 0) &&
            (endpoint.azure_subscription.namespace == null || length(trimspace(endpoint.azure_subscription.namespace)) > 0)
          )
        ) &&
        (
          endpoint.kubeconfig == null || (
            length(trimspace(endpoint.kubeconfig.kube_config)) > 0 &&
            (endpoint.kubeconfig.cluster_context == null || length(trimspace(endpoint.kubeconfig.cluster_context)) > 0)
          )
        ) &&
        (
          endpoint.service_account == null || (
            length(trimspace(endpoint.service_account.token)) > 0 &&
            length(trimspace(endpoint.service_account.ca_cert)) > 0
          )
        )
      )
    ])
    error_message = "serviceendpoint_kubernetes requires non-empty service_endpoint_name, apiserver_url, and authorization_type; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_kubernetes : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_kubernetes)
    error_message = "serviceendpoint_kubernetes keys must be unique."
  }

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_kubernetes : (
        contains(["AzureSubscription", "Kubeconfig", "ServiceAccount"], endpoint.authorization_type) &&
        (
          endpoint.authorization_type == "AzureSubscription"
          ? (endpoint.azure_subscription != null && endpoint.kubeconfig == null && endpoint.service_account == null)
          : endpoint.authorization_type == "Kubeconfig"
          ? (endpoint.kubeconfig != null && endpoint.azure_subscription == null && endpoint.service_account == null)
          : endpoint.authorization_type == "ServiceAccount"
          ? (endpoint.service_account != null && endpoint.azure_subscription == null && endpoint.kubeconfig == null)
          : false
        )
      )
    ])
    error_message = "serviceendpoint_kubernetes requires the authorization_type-specific auth block and no other auth blocks."
  }
}

# -----------------------------------------------------------------------------
# Maven
# -----------------------------------------------------------------------------

variable "serviceendpoint_maven" {
  description = "List of Maven service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_maven : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.repository_id)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_maven requires non-empty service_endpoint_name, url, and repository_id; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_maven : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_maven)
    error_message = "serviceendpoint_maven keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Nexus
# -----------------------------------------------------------------------------

variable "serviceendpoint_nexus" {
  description = "List of Nexus service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    url                   = string
    username              = string
    password              = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_nexus : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        length(trimspace(endpoint.password)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_nexus requires non-empty service_endpoint_name, url, username, and password; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_nexus : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_nexus)
    error_message = "serviceendpoint_nexus keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# npm
# -----------------------------------------------------------------------------

variable "serviceendpoint_npm" {
  description = "List of npm service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    url                   = string
    access_token          = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_npm : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.access_token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_npm requires non-empty service_endpoint_name, url, and access_token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_npm : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_npm)
    error_message = "serviceendpoint_npm keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# NuGet
# -----------------------------------------------------------------------------

variable "serviceendpoint_nuget" {
  description = "List of NuGet service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    feed_url              = string
    api_key               = optional(string)
    personal_access_token = optional(string)
    username              = optional(string)
    password              = optional(string)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_nuget : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.feed_url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.api_key == null || length(trimspace(endpoint.api_key)) > 0) &&
        (endpoint.personal_access_token == null || length(trimspace(endpoint.personal_access_token)) > 0) &&
        (endpoint.username == null || length(trimspace(endpoint.username)) > 0) &&
        (endpoint.password == null || length(trimspace(endpoint.password)) > 0)
      )
    ])
    error_message = "serviceendpoint_nuget requires non-empty service_endpoint_name and feed_url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_nuget : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_nuget)
    error_message = "serviceendpoint_nuget keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Octopus Deploy
# -----------------------------------------------------------------------------

variable "serviceendpoint_octopusdeploy" {
  description = "List of Octopus Deploy service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    url                   = string
    api_key               = string
    ignore_ssl_error      = optional(bool)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_octopusdeploy : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.api_key)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_octopusdeploy requires non-empty service_endpoint_name, url, and api_key; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_octopusdeploy : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_octopusdeploy)
    error_message = "serviceendpoint_octopusdeploy keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# OpenShift
# -----------------------------------------------------------------------------

variable "serviceendpoint_openshift" {
  description = "List of OpenShift service endpoints."
  type = list(object({
    key                        = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_openshift : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.server_url == null || length(trimspace(endpoint.server_url)) > 0) &&
        (endpoint.certificate_authority_file == null || length(trimspace(endpoint.certificate_authority_file)) > 0) &&
        (
          endpoint.auth_basic == null || (
            length(trimspace(endpoint.auth_basic.username)) > 0 &&
            length(trimspace(endpoint.auth_basic.password)) > 0
          )
        ) &&
        (endpoint.auth_token == null || length(trimspace(endpoint.auth_token.token)) > 0) &&
        (endpoint.auth_none == null || endpoint.auth_none.kube_config == null || length(trimspace(endpoint.auth_none.kube_config)) > 0)
      )
    ])
    error_message = "serviceendpoint_openshift requires non-empty service_endpoint_name; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_openshift : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_openshift)
    error_message = "serviceendpoint_openshift keys must be unique."
  }

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_openshift : (
        length(compact([
          endpoint.auth_basic != null ? "basic" : "",
          endpoint.auth_token != null ? "token" : "",
          endpoint.auth_none != null ? "none" : "",
        ])) == 1
      )
    ])
    error_message = "serviceendpoint_openshift requires exactly one of auth_basic, auth_token, or auth_none."
  }
}

# -----------------------------------------------------------------------------
# Service Endpoint Permissions
# -----------------------------------------------------------------------------

variable "serviceendpoint_permissions" {
  description = "List of service endpoint permissions to assign."
  type = list(object({
    key                 = optional(string)
    serviceendpoint_id  = optional(string)
    serviceendpoint_type = optional(string)
    serviceendpoint_key = optional(string)
    principal           = string
    permissions         = map(string)
    replace             = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : (
        length(trimspace(permission.principal)) > 0 &&
        (permission.key == null || length(trimspace(permission.key)) > 0) &&
        (permission.serviceendpoint_id == null || length(trimspace(permission.serviceendpoint_id)) > 0) &&
        (permission.serviceendpoint_type == null || length(trimspace(permission.serviceendpoint_type)) > 0) &&
        (permission.serviceendpoint_key == null || length(trimspace(permission.serviceendpoint_key)) > 0)
      )
    ])
    error_message = "serviceendpoint_permissions requires non-empty principal; key and serviceendpoint fields must be non-empty when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : (
        permission.serviceendpoint_id != null
        ? (permission.serviceendpoint_type == null && permission.serviceendpoint_key == null)
        : (permission.serviceendpoint_type != null && permission.serviceendpoint_key != null)
      )
    ])
    error_message = "serviceendpoint_permissions must set serviceendpoint_id or serviceendpoint_type + serviceendpoint_key (exclusively)."
  }

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : (
        permission.serviceendpoint_type == null || contains([
          "argocd",
          "artifactory",
          "aws",
          "azure_service_bus",
          "azurecr",
          "azurerm",
          "bitbucket",
          "black_duck",
          "checkmarx_one",
          "checkmarx_sast",
          "checkmarx_sca",
          "dockerregistry",
          "dynamics_lifecycle_services",
          "externaltfs",
          "gcp_terraform",
          "generic",
          "generic_git",
          "generic_v2",
          "github",
          "github_enterprise",
          "gitlab",
          "incomingwebhook",
          "jenkins",
          "jfrog_artifactory_v2",
          "jfrog_distribution_v2",
          "jfrog_platform_v2",
          "jfrog_xray_v2",
          "kubernetes",
          "maven",
          "nexus",
          "npm",
          "nuget",
          "octopusdeploy",
          "openshift",
          "runpipeline",
          "servicefabric",
          "snyk",
          "sonarcloud",
          "sonarqube",
          "ssh",
          "visualstudiomarketplace",
        ], permission.serviceendpoint_type)
      )
    ])
    error_message = "serviceendpoint_permissions.serviceendpoint_type must match a supported endpoint type."
  }

  validation {
    condition = alltrue([
      for permission in var.serviceendpoint_permissions : alltrue([
        for value in values(permission.permissions) : contains(["Allow", "Deny", "NotSet"], value)
      ])
    ])
    error_message = "serviceendpoint_permissions.permissions values must be Allow, Deny, or NotSet."
  }

  validation {
    condition = length(distinct([
      for permission in var.serviceendpoint_permissions : try(
        coalesce(
          permission.key,
          format("%s:%s", coalesce(permission.serviceendpoint_type, permission.serviceendpoint_id), permission.principal)
        ),
        ""
      )
    ])) == length(var.serviceendpoint_permissions)
    error_message = "serviceendpoint_permissions keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Run Pipeline
# -----------------------------------------------------------------------------

variable "serviceendpoint_runpipeline" {
  description = "List of run pipeline service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    organization_name     = string
    description           = optional(string)
    auth_personal = object({
      personal_access_token = string
    })
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_runpipeline : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.organization_name)) > 0 &&
        length(trimspace(endpoint.auth_personal.personal_access_token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_runpipeline requires non-empty service_endpoint_name, organization_name, and auth_personal.personal_access_token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_runpipeline : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_runpipeline)
    error_message = "serviceendpoint_runpipeline keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Service Fabric
# -----------------------------------------------------------------------------

variable "serviceendpoint_servicefabric" {
  description = "List of Service Fabric service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_servicefabric : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.cluster_endpoint)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (
          endpoint.certificate == null || (
            length(trimspace(endpoint.certificate.server_certificate_lookup)) > 0 &&
            length(trimspace(endpoint.certificate.client_certificate)) > 0 &&
            (endpoint.certificate.server_certificate_thumbprint == null || length(trimspace(endpoint.certificate.server_certificate_thumbprint)) > 0) &&
            (endpoint.certificate.server_certificate_common_name == null || length(trimspace(endpoint.certificate.server_certificate_common_name)) > 0) &&
            (endpoint.certificate.client_certificate_password == null || length(trimspace(endpoint.certificate.client_certificate_password)) > 0)
          )
        ) &&
        (
          endpoint.azure_active_directory == null || (
            length(trimspace(endpoint.azure_active_directory.server_certificate_lookup)) > 0 &&
            length(trimspace(endpoint.azure_active_directory.username)) > 0 &&
            length(trimspace(endpoint.azure_active_directory.password)) > 0 &&
            (endpoint.azure_active_directory.server_certificate_thumbprint == null || length(trimspace(endpoint.azure_active_directory.server_certificate_thumbprint)) > 0) &&
            (endpoint.azure_active_directory.server_certificate_common_name == null || length(trimspace(endpoint.azure_active_directory.server_certificate_common_name)) > 0)
          )
        ) &&
        (
          endpoint.none == null || (
            endpoint.none.cluster_spn == null || length(trimspace(endpoint.none.cluster_spn)) > 0
          )
        )
      )
    ])
    error_message = "serviceendpoint_servicefabric requires non-empty service_endpoint_name and cluster_endpoint; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_servicefabric : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_servicefabric)
    error_message = "serviceendpoint_servicefabric keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# Snyk
# -----------------------------------------------------------------------------

variable "serviceendpoint_snyk" {
  description = "List of Snyk service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    server_url            = string
    api_token             = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_snyk : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.server_url)) > 0 &&
        length(trimspace(endpoint.api_token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_snyk requires non-empty service_endpoint_name, server_url, and api_token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_snyk : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_snyk)
    error_message = "serviceendpoint_snyk keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# SonarCloud
# -----------------------------------------------------------------------------

variable "serviceendpoint_sonarcloud" {
  description = "List of SonarCloud service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    token                 = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_sonarcloud : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_sonarcloud requires non-empty service_endpoint_name and token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_sonarcloud : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_sonarcloud)
    error_message = "serviceendpoint_sonarcloud keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# SonarQube
# -----------------------------------------------------------------------------

variable "serviceendpoint_sonarqube" {
  description = "List of SonarQube service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    url                   = string
    token                 = string
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_sonarqube : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        length(trimspace(endpoint.token)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_sonarqube requires non-empty service_endpoint_name, url, and token; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_sonarqube : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_sonarqube)
    error_message = "serviceendpoint_sonarqube keys must be unique."
  }
}

# -----------------------------------------------------------------------------
# SSH
# -----------------------------------------------------------------------------

variable "serviceendpoint_ssh" {
  description = "List of SSH service endpoints."
  type = list(object({
    key                   = optional(string)
    service_endpoint_name = string
    host                  = string
    username              = string
    port                  = optional(number)
    password              = optional(string)
    private_key           = optional(string)
    description           = optional(string)
  }))
  default = []
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_ssh : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.host)) > 0 &&
        length(trimspace(endpoint.username)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0) &&
        (endpoint.password == null || length(trimspace(endpoint.password)) > 0) &&
        (endpoint.private_key == null || length(trimspace(endpoint.private_key)) > 0)
      )
    ])
    error_message = "serviceendpoint_ssh requires non-empty service_endpoint_name, host, and username; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_ssh : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_ssh)
    error_message = "serviceendpoint_ssh keys must be unique."
  }

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_ssh : (
        (endpoint.password != null) != (endpoint.private_key != null)
      )
    ])
    error_message = "serviceendpoint_ssh requires exactly one of password or private_key."
  }
}

# -----------------------------------------------------------------------------
# Visual Studio Marketplace
# -----------------------------------------------------------------------------

variable "serviceendpoint_visualstudiomarketplace" {
  description = "List of Visual Studio Marketplace service endpoints."
  type = list(object({
    key                   = optional(string)
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
  sensitive = true

  validation {
    condition = alltrue([
      for endpoint in var.serviceendpoint_visualstudiomarketplace : (
        length(trimspace(endpoint.service_endpoint_name)) > 0 &&
        length(trimspace(endpoint.url)) > 0 &&
        (endpoint.key == null || length(trimspace(endpoint.key)) > 0)
      )
    ])
    error_message = "serviceendpoint_visualstudiomarketplace requires non-empty service_endpoint_name and url; key must be non-empty when provided."
  }

  validation {
    condition = length(distinct([
      for endpoint in var.serviceendpoint_visualstudiomarketplace : coalesce(endpoint.key, endpoint.service_endpoint_name)
    ])) == length(var.serviceendpoint_visualstudiomarketplace)
    error_message = "serviceendpoint_visualstudiomarketplace keys must be unique."
  }
}
