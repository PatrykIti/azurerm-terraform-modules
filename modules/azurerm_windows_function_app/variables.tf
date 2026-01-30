variable "name" {
  description = "The name of the Windows Function App."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Windows Function App."
  type        = string
}

variable "location" {
  description = "The Azure region where the Windows Function App should exist."
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the App Service plan for the Function App."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account used by the Function App."
  type        = string
  default     = null
}

variable "storage_account_access_key" {
  description = "The access key for the storage account. Required unless storage_uses_managed_identity is true."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage_key_vault_secret_id" {
  description = "The Key Vault Secret ID containing the storage connection string."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage_uses_managed_identity" {
  description = "Whether the Function App uses managed identity to access the storage account."
  type        = bool
  default     = false

  validation {
    condition     = var.storage_uses_managed_identity ? (var.storage_account_access_key == null || var.storage_account_access_key == "") : true
    error_message = "When storage_uses_managed_identity is true, storage_account_access_key must be null."
  }

  validation {
    condition     = var.storage_uses_managed_identity ? var.identity != null : true
    error_message = "When storage_uses_managed_identity is true, identity must be configured."
  }
}

variable "functions_extension_version" {
  description = "The Functions runtime version for the Function App."
  type        = string
  default     = null
}

variable "builtin_logging_enabled" {
  description = "Whether to enable built-in logging."
  type        = bool
  default     = true
}

variable "enabled" {
  description = "Whether the Function App is enabled."
  type        = bool
  default     = true
}

variable "https_only" {
  description = "Whether HTTPS-only is enabled for the Function App."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Function App."
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Whether client certificate authentication is enabled."
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "Client certificate mode. Possible values include Required and Optional."
  type        = string
  default     = null

  validation {
    condition     = var.client_certificate_mode == null || contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }

  validation {
    condition     = var.client_certificate_mode == null || var.client_certificate_enabled == true
    error_message = "client_certificate_mode requires client_certificate_enabled to be true."
  }
}

variable "client_certificate_exclusion_paths" {
  description = "Paths excluded from client certificate authentication."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "App settings for the Function App."
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
  nullable  = false
  sensitive = true

  validation {
    condition     = length(distinct([for cs in var.connection_strings : cs.name])) == length(var.connection_strings)
    error_message = "Each connection string must have a unique name."
  }

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

variable "sticky_settings" {
  description = "Slot sticky settings for app settings and connection strings."
  type = object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
  })
  default = null
}

variable "content_share_force_disabled" {
  description = "Whether the content share is forced disabled."
  type        = bool
  default     = null
}

variable "daily_memory_time_quota" {
  description = "Daily memory time quota in MB-seconds."
  type        = number
  default     = null
}

variable "application_insights_connection_string" {
  description = "Application Insights connection string."
  type        = string
  default     = null
  sensitive   = true
}

variable "application_insights_key" {
  description = "Application Insights instrumentation key."
  type        = string
  default     = null
  sensitive   = true
}

variable "key_vault_reference_identity_id" {
  description = "The user-assigned identity ID used for Key Vault references."
  type        = string
  default     = null
}

variable "virtual_network_subnet_id" {
  description = "The subnet ID for VNet integration."
  type        = string
  default     = null
}

variable "virtual_network_backup_restore_enabled" {
  description = "Whether backup and restore operations over the linked virtual network are enabled."
  type        = bool
  default     = false
}

variable "vnet_image_pull_enabled" {
  description = "Whether image pull over VNet is enabled."
  type        = bool
  default     = false
}

variable "ftp_publish_basic_authentication_enabled" {
  description = "Whether FTP basic authentication for publishing is enabled."
  type        = bool
  default     = false
}

variable "webdeploy_publish_basic_authentication_enabled" {
  description = "Whether basic authentication for WebDeploy is enabled."
  type        = bool
  default     = false
}

variable "zip_deploy_file" {
  description = "Path to a zip file to deploy."
  type        = string
  default     = null
}

variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = var.identity == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned",
      "SystemAssigned,UserAssigned"
    ], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "auth_settings" {
  description = "Authentication settings (v1). Mutually exclusive with auth_settings_v2."
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
      client_id                  = string
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
    }))

    facebook = optional(object({
      app_id                  = string
      app_secret              = optional(string)
      app_secret_setting_name = optional(string)
      oauth_scopes            = optional(list(string))
    }))

    github = optional(object({
      client_id                  = string
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    }))

    google = optional(object({
      client_id                  = string
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    }))

    microsoft = optional(object({
      client_id                  = string
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    }))

    twitter = optional(object({
      consumer_key               = string
      consumer_secret            = optional(string)
      consumer_secret_setting_name = optional(string)
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
  description = "Authentication settings (v2). Mutually exclusive with auth_settings."
  type = object({
    auth_enabled                            = optional(bool)
    config_file_path                        = optional(string)
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string))
    forward_proxy_convention                = optional(string)
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)
    http_route_api_prefix                   = optional(string)
    require_authentication                  = optional(bool)
    require_https                           = optional(bool)
    runtime_version                         = optional(string)
    unauthenticated_action                  = optional(string)

    active_directory_v2 = optional(object({
      client_id                       = string
      tenant_auth_endpoint            = string
      client_secret_setting_name      = optional(string)
      allowed_audiences               = optional(list(string))
      allowed_applications            = optional(list(string))
      allowed_groups                  = optional(list(string))
      allowed_identities              = optional(list(string))
      jwt_allowed_client_applications = optional(list(string))
      jwt_allowed_groups              = optional(list(string))
      login_parameters                = optional(map(string))
      www_authentication_disabled     = optional(bool)
    }))

    apple_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    }))

    azure_static_web_app_v2 = optional(object({
      client_id = string
    }))

    custom_oidc_v2 = optional(list(object({
      name                          = string
      client_id                     = string
      openid_configuration_endpoint = string
      client_credential_method      = optional(string)
      client_secret_setting_name    = optional(string)
      scopes                        = optional(list(string))
    })))

    facebook_v2 = optional(object({
      app_id                  = string
      app_secret_setting_name = optional(string)
      graph_api_version       = optional(string)
      login_scopes            = optional(list(string))
    }))

    github_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    }))

    google_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    }))

    microsoft_v2 = optional(object({
      client_id                  = string
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    }))

    twitter_v2 = optional(object({
      consumer_key                = string
      consumer_secret_setting_name = optional(string)
    }))

    login = optional(object({
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string)
      cookie_expiration_time            = optional(string)
      logout_endpoint                   = optional(string)
      nonce_expiration_time             = optional(string)
      preserve_url_fragments_for_logins = optional(bool)
      token_refresh_extension_time      = optional(string)
      token_store_enabled               = optional(bool)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      validate_nonce                    = optional(bool)
    }))
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.auth_settings_v2 == null || var.auth_settings == null
    error_message = "auth_settings_v2 and auth_settings are mutually exclusive."
  }
}

variable "backup" {
  description = "Backup configuration for the Function App."
  type = object({
    name                = string
    storage_account_url = string
    schedule = object({
      frequency_interval       = number
      frequency_unit           = string
      keep_at_least_one_backup = optional(bool)
      retention_period_in_days = optional(number)
      start_time               = optional(string)
    })
  })
  default = null
}

variable "site_config" {
  description = "Site configuration for the Function App."
  type = object({
    always_on                             = optional(bool)
    api_definition_url                    = optional(string)
    api_management_api_id                 = optional(string)
    app_command_line                      = optional(string)
    app_scale_limit                       = optional(number)
    application_stack = optional(object({
      dotnet_version              = optional(string)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
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
    condition     = var.site_config.minimum_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], var.site_config.minimum_tls_version)
    error_message = "site_config.minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }

  validation {
    condition     = var.site_config.scm_minimum_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], var.site_config.scm_minimum_tls_version)
    error_message = "site_config.scm_minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }

  validation {
    condition     = var.site_config.remote_debugging_version == null || contains(["VS2017", "VS2019", "VS2022"], var.site_config.remote_debugging_version)
    error_message = "site_config.remote_debugging_version must be VS2017, VS2019, or VS2022."
  }

  validation {
    condition = var.site_config.application_stack != null && (
      (var.site_config.application_stack.dotnet_version != null ? 1 : 0) +
      (var.site_config.application_stack.java_version != null ? 1 : 0) +
      (var.site_config.application_stack.node_version != null ? 1 : 0) +
      (var.site_config.application_stack.powershell_core_version != null ? 1 : 0) +
      (try(var.site_config.application_stack.use_custom_runtime, false) ? 1 : 0)
    ) == 1
    error_message = "site_config.application_stack must be set with exactly one runtime (dotnet, java, node, powershell, or custom runtime)."
  }

  validation {
    condition     = var.site_config.health_check_eviction_time_in_min == null || (var.site_config.health_check_eviction_time_in_min >= 2 && var.site_config.health_check_eviction_time_in_min <= 10)
    error_message = "site_config.health_check_eviction_time_in_min must be between 2 and 10."
  }

  validation {
    condition     = var.site_config.application_stack == null || var.site_config.application_stack.dotnet_version == null || contains(["v3.0", "v4.0", "v6.0", "v7.0", "v8.0", "v9.0", "v10.0"], var.site_config.application_stack.dotnet_version)
    error_message = "site_config.application_stack.dotnet_version must be one of v3.0, v4.0, v6.0, v7.0, v8.0, v9.0, v10.0."
  }

  validation {
    condition     = var.site_config.application_stack == null || var.site_config.application_stack.node_version == null || contains(["~12", "~14", "~16", "~18", "~20", "~22"], var.site_config.application_stack.node_version)
    error_message = "site_config.application_stack.node_version must be one of ~12, ~14, ~16, ~18, ~20, or ~22."
  }

  validation {
    condition     = var.site_config.application_stack == null || var.site_config.application_stack.java_version == null || contains(["1.8", "11", "17", "21"], var.site_config.application_stack.java_version)
    error_message = "site_config.application_stack.java_version must be one of 1.8, 11, 17, or 21."
  }

  validation {
    condition     = var.site_config.application_stack == null || var.site_config.application_stack.powershell_core_version == null || contains(["7", "7.2", "7.4"], var.site_config.application_stack.powershell_core_version)
    error_message = "site_config.application_stack.powershell_core_version must be 7, 7.2, or 7.4."
  }

  validation {
    condition     = var.site_config.application_stack == null || !try(var.site_config.application_stack.use_dotnet_isolated_runtime, false) || var.site_config.application_stack.dotnet_version != null
    error_message = "site_config.application_stack.use_dotnet_isolated_runtime requires dotnet_version to be set."
  }
}

variable "slots" {
  description = "Slot configurations for the Function App."
  type = list(object({
    name                              = string
    app_settings                      = optional(map(string))
    connection_strings                = optional(list(object({
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
    storage_account_name              = optional(string)
    storage_account_access_key        = optional(string)
    storage_key_vault_secret_id       = optional(string)
    storage_uses_managed_identity     = optional(bool)
    functions_extension_version       = optional(string)
    builtin_logging_enabled           = optional(bool)
    enabled                           = optional(bool)
    https_only                        = optional(bool)
    public_network_access_enabled     = optional(bool)
    client_certificate_enabled        = optional(bool)
    client_certificate_mode           = optional(string)
    client_certificate_exclusion_paths = optional(string)
    content_share_force_disabled      = optional(bool)
    daily_memory_time_quota           = optional(number)
    ftp_publish_basic_authentication_enabled = optional(bool)
    key_vault_reference_identity_id   = optional(string)
    zip_deploy_file                   = optional(string)
    service_plan_id                   = optional(string)
    virtual_network_subnet_id         = optional(string)
    virtual_network_backup_restore_enabled = optional(bool)
    tags                              = optional(map(string))

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
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
      }))

      facebook = optional(object({
        app_id                  = string
        app_secret              = optional(string)
        app_secret_setting_name = optional(string)
        oauth_scopes            = optional(list(string))
      }))

      github = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      }))

      google = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      }))

      microsoft = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      }))

      twitter = optional(object({
        consumer_key                = string
        consumer_secret             = optional(string)
        consumer_secret_setting_name = optional(string)
      }))
    }))

    auth_settings_v2 = optional(object({
      auth_enabled                            = optional(bool)
      config_file_path                        = optional(string)
      default_provider                        = optional(string)
      excluded_paths                          = optional(list(string))
      forward_proxy_convention                = optional(string)
      forward_proxy_custom_host_header_name   = optional(string)
      forward_proxy_custom_scheme_header_name = optional(string)
      http_route_api_prefix                   = optional(string)
      require_authentication                  = optional(bool)
      require_https                           = optional(bool)
      runtime_version                         = optional(string)
      unauthenticated_action                  = optional(string)

      active_directory_v2 = optional(object({
        client_id                       = string
        tenant_auth_endpoint            = string
        client_secret_setting_name      = optional(string)
        allowed_audiences               = optional(list(string))
        allowed_applications            = optional(list(string))
        allowed_groups                  = optional(list(string))
        allowed_identities              = optional(list(string))
        jwt_allowed_client_applications = optional(list(string))
        jwt_allowed_groups              = optional(list(string))
        login_parameters                = optional(map(string))
        www_authentication_disabled     = optional(bool)
      }))

      apple_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = optional(string)
        login_scopes               = optional(list(string))
      }))

      azure_static_web_app_v2 = optional(object({
        client_id = string
      }))

      custom_oidc_v2 = optional(list(object({
        name                          = string
        client_id                     = string
        openid_configuration_endpoint = string
        client_credential_method      = optional(string)
        client_secret_setting_name    = optional(string)
        scopes                        = optional(list(string))
      })))

      facebook_v2 = optional(object({
        app_id                  = string
        app_secret_setting_name = optional(string)
        graph_api_version       = optional(string)
        login_scopes            = optional(list(string))
      }))

      github_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = optional(string)
        login_scopes               = optional(list(string))
      }))

      google_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      }))

      microsoft_v2 = optional(object({
        client_id                  = string
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      }))

      twitter_v2 = optional(object({
        consumer_key                = string
        consumer_secret_setting_name = optional(string)
      }))

      login = optional(object({
        allowed_external_redirect_urls    = optional(list(string))
        cookie_expiration_convention      = optional(string)
        cookie_expiration_time            = optional(string)
        logout_endpoint                   = optional(string)
        nonce_expiration_time             = optional(string)
        preserve_url_fragments_for_logins = optional(bool)
        token_refresh_extension_time      = optional(string)
        token_store_enabled               = optional(bool)
        token_store_path                  = optional(string)
        token_store_sas_setting_name      = optional(string)
        validate_nonce                    = optional(bool)
      }))
    }))

    backup = optional(object({
      name                = string
      storage_account_url = string
      schedule = object({
        frequency_interval       = number
        frequency_unit           = string
        keep_at_least_one_backup = optional(bool)
        retention_period_in_days = optional(number)
        start_time               = optional(string)
      })
    }))

    site_config = object({
      always_on                             = optional(bool)
      api_definition_url                    = optional(string)
      api_management_api_id                 = optional(string)
      app_command_line                      = optional(string)
      app_scale_limit                       = optional(number)
      application_stack = optional(object({
        dotnet_version           = optional(string)
        java_version             = optional(string)
        node_version             = optional(string)
        powershell_core_version  = optional(string)
        use_custom_runtime       = optional(bool)
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
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct([for slot in var.slots : slot.name])) == length(var.slots)
    error_message = "Each slot must have a unique name."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : !(slot.auth_settings != null && slot.auth_settings_v2 != null)
    ])
    error_message = "Slot auth_settings and auth_settings_v2 are mutually exclusive."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : slot.client_certificate_mode == null || slot.client_certificate_enabled == true
    ])
    error_message = "Slot client_certificate_mode requires client_certificate_enabled to be true."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : slot.client_certificate_mode == null ||
      contains(["Required", "Optional", "OptionalInteractiveUser"], slot.client_certificate_mode)
    ])
    error_message = "Slot client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.connection_strings == null || length(distinct([for cs in slot.connection_strings : cs.name])) == length(slot.connection_strings)
    ])
    error_message = "Slot connection strings must have unique names."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.connection_strings == null || alltrue([
        for cs in slot.connection_strings : contains(["Custom", "MySql", "PostgreSQL", "SQLAzure", "SQLServer"], cs.type)
      ])
    ])
    error_message = "Slot connection_strings.type must be one of Custom, MySql, PostgreSQL, SQLAzure, SQLServer."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.storage_accounts == null || alltrue([for sa in slot.storage_accounts : contains(["AzureFiles", "AzureBlob"], sa.type)])
    ])
    error_message = "Slot storage_accounts.type must be AzureFiles or AzureBlob."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.site_config.application_stack != null && (
        (slot.site_config.application_stack.dotnet_version != null ? 1 : 0) +
        (slot.site_config.application_stack.java_version != null ? 1 : 0) +
        (slot.site_config.application_stack.node_version != null ? 1 : 0) +
        (slot.site_config.application_stack.powershell_core_version != null ? 1 : 0) +
        (try(slot.site_config.application_stack.use_custom_runtime, false) ? 1 : 0)
      ) == 1
    ])
    error_message = "slot.site_config.application_stack must be set with exactly one runtime (dotnet, java, node, powershell, or custom runtime)."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.site_config.application_stack == null || slot.site_config.application_stack.dotnet_version == null ||
      contains(["v3.0", "v4.0", "v6.0", "v7.0", "v8.0", "v9.0", "v10.0"], slot.site_config.application_stack.dotnet_version)
    ])
    error_message = "slot.site_config.application_stack.dotnet_version must be one of v3.0, v4.0, v6.0, v7.0, v8.0, v9.0, v10.0."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.site_config.application_stack == null || slot.site_config.application_stack.node_version == null ||
      contains(["~12", "~14", "~16", "~18", "~20", "~22"], slot.site_config.application_stack.node_version)
    ])
    error_message = "slot.site_config.application_stack.node_version must be one of ~12, ~14, ~16, ~18, ~20, or ~22."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.site_config.application_stack == null || slot.site_config.application_stack.java_version == null ||
      contains(["1.8", "11", "17", "21"], slot.site_config.application_stack.java_version)
    ])
    error_message = "slot.site_config.application_stack.java_version must be one of 1.8, 11, 17, or 21."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.site_config.application_stack == null || slot.site_config.application_stack.powershell_core_version == null ||
      contains(["7", "7.2", "7.4"], slot.site_config.application_stack.powershell_core_version)
    ])
    error_message = "slot.site_config.application_stack.powershell_core_version must be 7, 7.2, or 7.4."
  }

  validation {
    condition = alltrue([
      for slot in var.slots :
      slot.site_config.application_stack == null || !try(slot.site_config.application_stack.use_dotnet_isolated_runtime, false) ||
      slot.site_config.application_stack.dotnet_version != null
    ])
    error_message = "slot.site_config.application_stack.use_dotnet_isolated_runtime requires dotnet_version to be set."
  }
}

variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for the Function App. Provide log and/or metric categories or use areas = ["all"].
  EOT

  type = list(object({
    name                           = string
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    areas                          = optional(list(string))
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
    error_message = "Each diagnostic settings entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic settings entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
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
    error_message = "log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }
}

variable "timeouts" {
  description = "Resource timeouts."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the Function App."
  type        = map(string)
  default     = {}
}
