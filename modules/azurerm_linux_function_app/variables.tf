variable "name" {
  description = "The name of the Linux Function App. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,60}$", var.name))
    error_message = "The name must be 2-60 characters of lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Linux Function App."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Linux Function App should exist."
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the App Service Plan where this Linux Function App will be hosted."
  type        = string
}

variable "functions_extension_version" {
  description = "The runtime version associated with the Function App."
  type        = string
  default     = "~4"
}

variable "storage_account_name" {
  description = "The name of the Storage Account used by the Function App."
  type        = string
}

variable "storage_account_access_key" {
  description = "The access key for the Storage Account used by the Function App (required when storage_uses_managed_identity is false)."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage_uses_managed_identity" {
  description = "When true, the Function App will access the storage account using its managed identity."
  type        = bool
  default     = false

  validation {
    condition = var.storage_uses_managed_identity == false || (
      var.identity != null && var.storage_account_access_key == null
    )
    error_message = "When storage_uses_managed_identity is true, identity must be configured and storage_account_access_key must be null."
  }
}

variable "content_share_force_disabled" {
  description = "Should the settings for linking the Function App to storage be suppressed."
  type        = bool
  default     = false
}

variable "app_settings" {
  description = "A map of key-value pairs for App Settings."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "connection_strings" {
  description = "Connection strings for the Function App."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default   = []
  sensitive = true

  validation {
    condition = alltrue([
      for cs in var.connection_strings : contains(["Custom", "MySql", "PostgreSQL", "SQLAzure", "SQLServer"], cs.type)
    ])
    error_message = "connection_strings.type must be one of Custom, MySql, PostgreSQL, SQLAzure, SQLServer."
  }
}

variable "storage_accounts" {
  description = "Optional storage mount configurations for the Function App."
  type = list(object({
    name         = string
    account_name = string
    access_key   = string
    share_name   = string
    type         = string
    mount_path   = optional(string)
  }))
  default   = []
  sensitive = true

  validation {
    condition     = alltrue([for sa in var.storage_accounts : contains(["AzureFiles", "AzureBlob"], sa.type)])
    error_message = "storage_accounts.type must be AzureFiles or AzureBlob."
  }
}

variable "zip_deploy_file" {
  description = "The path to the ZIP file to deploy to the Function App."
  type        = string
  default     = null
}

variable "builtin_logging_enabled" {
  description = "Should built-in logging be enabled?"
  type        = bool
  default     = true
}

variable "enabled" {
  description = "Is the Function App enabled?"
  type        = bool
  default     = true
}

variable "https_only" {
  description = "Should the Function App only be accessible over HTTPS?"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Should public network access be enabled for the Function App?"
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Should the Function App use client certificates?"
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "The mode of the Function App's client certificates requirement."
  type        = string
  default     = null

  validation {
    condition     = var.client_certificate_mode == null || contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "client_certificate_exclusion_paths" {
  description = "Paths to exclude when using client certificates, separated by ';'."
  type        = string
  default     = null
}

variable "daily_memory_time_quota" {
  description = "The amount of memory in gigabyte-seconds allowed per day."
  type        = number
  default     = null
}

variable "ftp_publish_basic_authentication_enabled" {
  description = "Should the default FTP Basic Authentication publishing profile be enabled?"
  type        = bool
  default     = false
}

variable "key_vault_reference_identity_id" {
  description = "The User Assigned Identity ID used for accessing KeyVault secrets."
  type        = string
  default     = null
}

variable "virtual_network_subnet_id" {
  description = "The subnet ID for regional virtual network integration."
  type        = string
  default     = null
}

variable "application_insights_connection_string" {
  description = "The Application Insights connection string."
  type        = string
  default     = null
  sensitive   = true
}

variable "application_insights_key" {
  description = "The Application Insights instrumentation key."
  type        = string
  default     = null
  sensitive   = true
}

variable "identity" {
  description = "The managed identity configuration for the Function App."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned"], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned,UserAssigned."
  }
}

variable "auth_settings" {
  description = "Authentication/Authorization settings (v1)."
  type = object({
    enabled                        = bool
    additional_login_parameters    = optional(map(string))
    allowed_external_redirect_urls = optional(list(string))
    default_provider               = optional(string)
    issuer                         = optional(string)
    runtime_version                = optional(string)
    token_refresh_extension_hours  = optional(number)
    token_store_enabled            = optional(bool)
    unauthenticated_client_action  = optional(string)
    active_directory = optional(object({
      client_id         = string
      client_secret     = string
      allowed_audiences = optional(list(string))
    }))
    facebook = optional(object({
      app_id       = string
      app_secret   = string
      oauth_scopes = optional(list(string))
    }))
    github = optional(object({
      client_id     = string
      client_secret = string
      oauth_scopes  = optional(list(string))
    }))
    google = optional(object({
      client_id     = string
      client_secret = string
      oauth_scopes  = optional(list(string))
    }))
    microsoft = optional(object({
      client_id     = string
      client_secret = string
      oauth_scopes  = optional(list(string))
    }))
    twitter = optional(object({
      consumer_key    = string
      consumer_secret = string
    }))
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.auth_settings == null || var.auth_settings_v2 == null
    error_message = "auth_settings and auth_settings_v2 are mutually exclusive."
  }
}

variable "auth_settings_v2" {
  description = "Authentication/Authorization settings (v2)."
  type = object({
    auth_enabled                      = optional(bool)
    runtime_version                   = optional(string)
    config_file_path                  = optional(string)
    require_authentication            = optional(bool)
    unauthenticated_action            = optional(string)
    default_provider                  = optional(string)
    excluded_paths                    = optional(list(string))
    require_https                     = optional(bool)
    http_route_api_prefix             = optional(string)
    forward_proxy_convention          = optional(string)
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)

    login = optional(object({
      token_store_enabled               = optional(bool)
      token_refresh_extension_time      = optional(number)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      preserve_url_fragments_for_logins = optional(bool)
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string)
      cookie_expiration_time            = optional(string)
      validate_nonce                    = optional(bool)
      nonce_expiration_time             = optional(string)
    }))

    apple_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = string
      login_scopes               = optional(list(string))
    }))

    active_directory_v2 = optional(object({
      client_id                  = string
      tenant_auth_endpoint       = string
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    }))

    custom_oidc_v2 = optional(list(object({
      name                         = string
      client_id                    = string
      openid_configuration_endpoint = string
      client_secret_setting_name   = optional(string)
      allowed_audiences            = optional(list(string))
      login_scopes                 = optional(list(string))
    })))

    facebook_v2 = optional(object({
      app_id                  = string
      app_secret_setting_name = string
      login_scopes            = optional(list(string))
    }))

    github_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = string
      login_scopes               = optional(list(string))
    }))

    google_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = string
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    }))

    microsoft_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = string
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    }))

    twitter_v2 = optional(object({
      consumer_key               = string
      consumer_secret_setting_name = string
    }))
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.auth_settings_v2 == null || var.auth_settings == null
    error_message = "auth_settings and auth_settings_v2 are mutually exclusive."
  }
}

variable "site_config" {
  description = "Site configuration for the Linux Function App."
  type = object({
    always_on                              = optional(bool)
    api_definition_url                     = optional(string)
    api_management_api_id                  = optional(string)
    app_command_line                       = optional(string)
    app_scale_limit                        = optional(number)
    application_insights_connection_string = optional(string)
    application_insights_key               = optional(string)
    application_stack = optional(object({
      docker = optional(object({
        registry_url      = string
        image_name        = string
        image_tag         = string
        registry_username = optional(string)
        registry_password = optional(string)
      }))
      dotnet_version              = optional(string)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      python_version              = optional(string)
      use_custom_runtime          = optional(bool)
      use_dotnet_isolated_runtime = optional(bool)
    }))
    app_service_logs = optional(object({
      disk_quota_mb         = optional(number)
      retention_period_days = optional(number)
      azure_blob_storage = optional(object({
        level             = string
        sas_url           = string
        retention_in_days = optional(number)
      }))
    }))
    auto_swap_slot_name                    = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    cors = optional(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool)
    }))
    default_documents               = optional(list(string))
    elastic_instance_minimum        = optional(number)
    ftps_state                      = optional(string)
    health_check_path               = optional(string)
    health_check_eviction_time_in_min = optional(number)
    http2_enabled                   = optional(bool)
    ip_restriction = optional(list(object({
      action                    = optional(string)
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      description               = optional(string)
      headers = optional(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string))
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      }))
    })))
    ip_restriction_default_action = optional(string)
    load_balancing_mode           = optional(string)
    managed_pipeline_mode         = optional(string)
    minimum_tls_version           = optional(string)
    pre_warmed_instance_count     = optional(number)
    remote_debugging_enabled      = optional(bool)
    remote_debugging_version      = optional(string)
    runtime_scale_monitoring_enabled = optional(bool)
    scm_ip_restriction = optional(list(object({
      action                    = optional(string)
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      description               = optional(string)
      headers = optional(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string))
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      }))
    })))
    scm_ip_restriction_default_action = optional(string)
    scm_minimum_tls_version           = optional(string)
    scm_use_main_ip_restriction       = optional(bool)
    use_32_bit_worker                 = optional(bool)
    vnet_route_all_enabled            = optional(bool)
    websockets_enabled                = optional(bool)
    worker_count                      = optional(number)
  })

  validation {
    condition     = var.site_config.ftps_state == null || contains(["AllAllowed", "FtpsOnly", "Disabled"], var.site_config.ftps_state)
    error_message = "site_config.ftps_state must be AllAllowed, FtpsOnly, or Disabled."
  }

  validation {
    condition     = var.site_config.minimum_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], var.site_config.minimum_tls_version)
    error_message = "site_config.minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }

  validation {
    condition     = var.site_config.scm_minimum_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], var.site_config.scm_minimum_tls_version)
    error_message = "site_config.scm_minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }

  validation {
    condition     = var.site_config.ip_restriction_default_action == null || contains(["Allow", "Deny"], var.site_config.ip_restriction_default_action)
    error_message = "site_config.ip_restriction_default_action must be Allow or Deny."
  }

  validation {
    condition     = var.site_config.scm_ip_restriction_default_action == null || contains(["Allow", "Deny"], var.site_config.scm_ip_restriction_default_action)
    error_message = "site_config.scm_ip_restriction_default_action must be Allow or Deny."
  }

  validation {
    condition     = var.site_config.managed_pipeline_mode == null || contains(["Integrated", "Classic"], var.site_config.managed_pipeline_mode)
    error_message = "site_config.managed_pipeline_mode must be Integrated or Classic."
  }

  validation {
    condition = var.site_config.load_balancing_mode == null || contains([
      "WeightedRoundRobin",
      "LeastRequests",
      "LeastResponseTime",
      "WeightedTotalTraffic",
      "RequestHash",
      "PerSiteRoundRobin"
    ], var.site_config.load_balancing_mode)
    error_message = "site_config.load_balancing_mode contains an unsupported value."
  }

  validation {
    condition     = var.site_config.remote_debugging_version == null || contains(["VS2017", "VS2019", "VS2022"], var.site_config.remote_debugging_version)
    error_message = "site_config.remote_debugging_version must be VS2017, VS2019, or VS2022."
  }

  validation {
    condition = var.site_config.application_stack != null && (
      (var.site_config.application_stack.docker != null ? 1 : 0) +
      (var.site_config.application_stack.dotnet_version != null ? 1 : 0) +
      (var.site_config.application_stack.java_version != null ? 1 : 0) +
      (var.site_config.application_stack.node_version != null ? 1 : 0) +
      (var.site_config.application_stack.powershell_core_version != null ? 1 : 0) +
      (var.site_config.application_stack.python_version != null ? 1 : 0) +
      (try(var.site_config.application_stack.use_custom_runtime, false) ? 1 : 0)
    ) == 1
    error_message = "site_config.application_stack must be set with exactly one runtime (docker or a single language runtime or custom runtime)."
  }
}

variable "backup" {
  description = "Optional backup configuration."
  type = object({
    name                = string
    storage_account_url = string
    enabled             = optional(bool, true)
    schedule = object({
      frequency_interval       = number
      frequency_unit           = string
      keep_at_least_one_backup = optional(bool)
      retention_period_days    = number
      start_time               = optional(string)
    })
  })
  default = null
}

variable "timeouts" {
  description = "Timeouts for create/update/read/delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "slots" {
  description = "Linux Function App slots configuration."
  type = list(object({
    name                                = string
    app_settings                        = optional(map(string))
    connection_strings                  = optional(list(object({
      name  = string
      type  = string
      value = string
    })))
    storage_accounts = optional(list(object({
      name         = string
      account_name = string
      access_key   = string
      share_name   = string
      type         = string
      mount_path   = optional(string)
    })))
    functions_extension_version         = optional(string)
    builtin_logging_enabled             = optional(bool)
    enabled                             = optional(bool)
    https_only                          = optional(bool)
    public_network_access_enabled       = optional(bool)
    client_certificate_enabled          = optional(bool)
    client_certificate_mode             = optional(string)
    client_certificate_exclusion_paths  = optional(string)
    ftp_publish_basic_authentication_enabled = optional(bool)
    key_vault_reference_identity_id     = optional(string)
    virtual_network_subnet_id           = optional(string)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    auth_settings = optional(object({
      enabled                        = bool
      additional_login_parameters    = optional(map(string))
      allowed_external_redirect_urls = optional(list(string))
      default_provider               = optional(string)
      issuer                         = optional(string)
      runtime_version                = optional(string)
      token_refresh_extension_hours  = optional(number)
      token_store_enabled            = optional(bool)
      unauthenticated_client_action  = optional(string)
      active_directory = optional(object({
        client_id         = string
        client_secret     = string
        allowed_audiences = optional(list(string))
      }))
      facebook = optional(object({
        app_id       = string
        app_secret   = string
        oauth_scopes = optional(list(string))
      }))
      github = optional(object({
        client_id     = string
        client_secret = string
        oauth_scopes  = optional(list(string))
      }))
      google = optional(object({
        client_id     = string
        client_secret = string
        oauth_scopes  = optional(list(string))
      }))
      microsoft = optional(object({
        client_id     = string
        client_secret = string
        oauth_scopes  = optional(list(string))
      }))
      twitter = optional(object({
        consumer_key    = string
        consumer_secret = string
      }))
    }))
    auth_settings_v2 = optional(object({
      auth_enabled                      = optional(bool)
      runtime_version                   = optional(string)
      config_file_path                  = optional(string)
      require_authentication            = optional(bool)
      unauthenticated_action            = optional(string)
      default_provider                  = optional(string)
      excluded_paths                    = optional(list(string))
      require_https                     = optional(bool)
      http_route_api_prefix             = optional(string)
      forward_proxy_convention          = optional(string)
      forward_proxy_custom_host_header_name   = optional(string)
      forward_proxy_custom_scheme_header_name = optional(string)

      login = optional(object({
        token_store_enabled               = optional(bool)
        token_refresh_extension_time      = optional(number)
        token_store_path                  = optional(string)
        token_store_sas_setting_name      = optional(string)
        preserve_url_fragments_for_logins = optional(bool)
        allowed_external_redirect_urls    = optional(list(string))
        cookie_expiration_convention      = optional(string)
        cookie_expiration_time            = optional(string)
        validate_nonce                    = optional(bool)
        nonce_expiration_time             = optional(string)
      }))

      apple_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = string
        login_scopes               = optional(list(string))
      }))

      active_directory_v2 = optional(object({
        client_id                  = string
        tenant_auth_endpoint       = string
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      }))

      custom_oidc_v2 = optional(list(object({
        name                         = string
        client_id                    = string
        openid_configuration_endpoint = string
        client_secret_setting_name   = optional(string)
        allowed_audiences            = optional(list(string))
        login_scopes                 = optional(list(string))
      })))

      facebook_v2 = optional(object({
        app_id                  = string
        app_secret_setting_name = string
        login_scopes            = optional(list(string))
      }))

      github_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = string
        login_scopes               = optional(list(string))
      }))

      google_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = string
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      }))

      microsoft_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = string
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      }))

      twitter_v2 = optional(object({
        consumer_key               = string
        consumer_secret_setting_name = string
      }))
    }))
    site_config = object({
      always_on                              = optional(bool)
      api_definition_url                     = optional(string)
      api_management_api_id                  = optional(string)
      app_command_line                       = optional(string)
      app_scale_limit                        = optional(number)
      application_insights_connection_string = optional(string)
      application_insights_key               = optional(string)
      application_stack = optional(object({
        docker = optional(object({
          registry_url      = string
          image_name        = string
          image_tag         = string
          registry_username = optional(string)
          registry_password = optional(string)
        }))
        dotnet_version              = optional(string)
        java_version                = optional(string)
        node_version                = optional(string)
        powershell_core_version     = optional(string)
        python_version              = optional(string)
        use_custom_runtime          = optional(bool)
        use_dotnet_isolated_runtime = optional(bool)
      }))
      app_service_logs = optional(object({
        disk_quota_mb         = optional(number)
        retention_period_days = optional(number)
        azure_blob_storage = optional(object({
          level             = string
          sas_url           = string
          retention_in_days = optional(number)
        }))
      }))
      auto_swap_slot_name                    = optional(string)
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      cors = optional(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool)
      }))
      default_documents               = optional(list(string))
      elastic_instance_minimum        = optional(number)
      ftps_state                      = optional(string)
      health_check_path               = optional(string)
      health_check_eviction_time_in_min = optional(number)
      http2_enabled                   = optional(bool)
      ip_restriction = optional(list(object({
        action                    = optional(string)
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        description               = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string))
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        }))
      })))
      ip_restriction_default_action = optional(string)
      load_balancing_mode           = optional(string)
      managed_pipeline_mode         = optional(string)
      minimum_tls_version           = optional(string)
      pre_warmed_instance_count     = optional(number)
      remote_debugging_enabled      = optional(bool)
      remote_debugging_version      = optional(string)
      runtime_scale_monitoring_enabled = optional(bool)
      scm_ip_restriction = optional(list(object({
        action                    = optional(string)
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        description               = optional(string)
        headers = optional(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string))
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        }))
      })))
      scm_ip_restriction_default_action = optional(string)
      scm_minimum_tls_version           = optional(string)
      scm_use_main_ip_restriction       = optional(bool)
      use_32_bit_worker                 = optional(bool)
      vnet_route_all_enabled            = optional(bool)
      websockets_enabled                = optional(bool)
      worker_count                      = optional(number)
    })
    tags = optional(map(string))
  }))
  default = []

  validation {
    condition     = length(distinct([for slot in var.slots : slot.name])) == length(var.slots)
    error_message = "Each slot name must be unique."
  }
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for logs and metrics."
  type = list(object({
    name                           = string
    areas                          = optional(list(string))
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per resource."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic setting must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic setting must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null || (ds.eventhub_name != null && ds.eventhub_name != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
