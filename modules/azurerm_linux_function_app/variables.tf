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

  validation {
    condition     = length(trimspace(var.service_plan_id)) > 0
    error_message = "service_plan_id must be a non-empty string."
  }
}

variable "storage_configuration" {
  description = <<-EOT
    Storage configuration for the Function App.

    account_name: Name of the Storage Account used by the Function App.
    account_access_key: Access key for the storage account (required when not using managed identity and not using key_vault_secret_id).
    key_vault_secret_id: Key Vault Secret ID containing a storage connection string; mutually exclusive with account_name.
    uses_managed_identity: When true, storage access uses managed identity (requires identity configuration).
    content_share_force_disabled: Suppresses platform content share settings.
    mounts: Optional storage mounts exposed as `storage_account` blocks.
  EOT

  type = object({
    account_name                 = optional(string)
    account_access_key           = optional(string)
    key_vault_secret_id          = optional(string)
    uses_managed_identity        = optional(bool, false)
    content_share_force_disabled = optional(bool, false)
    mounts = optional(list(object({
      name         = string
      account_name = string
      access_key   = string
      share_name   = string
      type         = string
      mount_path   = optional(string)
    })), [])
  })
  default   = {}
  nullable  = false
  sensitive = true

  validation {
    condition     = try(var.storage_configuration.account_name, null) == null || trimspace(var.storage_configuration.account_name) != ""
    error_message = "storage_configuration.account_name must not be empty or whitespace when set."
  }

  validation {
    condition     = try(var.storage_configuration.account_access_key, null) == null || trimspace(var.storage_configuration.account_access_key) != ""
    error_message = "storage_configuration.account_access_key must not be empty or whitespace when set."
  }

  validation {
    condition     = try(var.storage_configuration.key_vault_secret_id, null) == null || trimspace(var.storage_configuration.key_vault_secret_id) != ""
    error_message = "storage_configuration.key_vault_secret_id must not be empty or whitespace when set."
  }

  validation {
    condition = (
      (try(var.storage_configuration.key_vault_secret_id, null) != null && trimspace(var.storage_configuration.key_vault_secret_id) != "") ||
      (try(var.storage_configuration.account_name, null) != null && trimspace(var.storage_configuration.account_name) != "")
    )
    error_message = "Either storage_configuration.account_name or storage_configuration.key_vault_secret_id must be set."
  }

  validation {
    condition = (
      try(var.storage_configuration.key_vault_secret_id, null) == null ||
      trimspace(var.storage_configuration.key_vault_secret_id) == "" ||
      try(var.storage_configuration.account_name, null) == null ||
      trimspace(var.storage_configuration.account_name) == ""
    )
    error_message = "storage_configuration.key_vault_secret_id cannot be used with storage_configuration.account_name."
  }

  validation {
    condition = try(var.storage_configuration.uses_managed_identity, false) == false || (
      (try(var.storage_configuration.key_vault_secret_id, null) == null || trimspace(var.storage_configuration.key_vault_secret_id) == "") &&
      var.identity != null
    )
    error_message = "When storage_configuration.uses_managed_identity is true, identity must be configured and storage_configuration.key_vault_secret_id must not be set."
  }

  validation {
    condition = (
      try(var.storage_configuration.key_vault_secret_id, null) != null && trimspace(var.storage_configuration.key_vault_secret_id) != "" ? (
        try(var.storage_configuration.account_access_key, null) == null || trimspace(var.storage_configuration.account_access_key) == ""
        ) : (
        try(var.storage_configuration.uses_managed_identity, false) ? (
          try(var.storage_configuration.account_access_key, null) == null || trimspace(var.storage_configuration.account_access_key) == ""
          ) : (
          try(var.storage_configuration.account_access_key, null) != null && trimspace(var.storage_configuration.account_access_key) != ""
        )
      )
    )
    error_message = "When storage_configuration.uses_managed_identity is true, account_access_key must be null/empty. When false, account_access_key is required unless key_vault_secret_id is set."
  }

  validation {
    condition     = alltrue([for mount in try(var.storage_configuration.mounts, []) : contains(["AzureFiles", "AzureBlob"], mount.type)])
    error_message = "storage_configuration.mounts[*].type must be AzureFiles or AzureBlob."
  }
}

variable "application_configuration" {
  description = <<-EOT
    Application-level configuration for the Function App runtime.

    functions_extension_version: Runtime version (defaults to "~4").
    app_settings: App settings map.
    connection_strings: Connection string definitions.
    sticky_settings: Slot sticky settings for app settings and connection strings.
    zip_deploy_file: Path to ZIP package for zip deploy.
    builtin_logging_enabled: Enables built-in logging.
    enabled: Enables or disables the Function App.
    daily_memory_time_quota: Daily memory quota in GB-seconds.
    application_insights_connection_string/application_insights_key: Optional insights values used in site configuration.
  EOT

  type = object({
    functions_extension_version = optional(string, "~4")
    app_settings                = optional(map(string), {})
    connection_strings = optional(list(object({
      name  = string
      type  = string
      value = string
    })), [])
    sticky_settings = optional(object({
      app_setting_names       = optional(list(string))
      connection_string_names = optional(list(string))
    }))
    zip_deploy_file                        = optional(string)
    builtin_logging_enabled                = optional(bool, true)
    enabled                                = optional(bool, true)
    daily_memory_time_quota                = optional(number)
    application_insights_connection_string = optional(string)
    application_insights_key               = optional(string)
  })
  default   = {}
  nullable  = false
  sensitive = true

  validation {
    condition = alltrue([
      for cs in try(var.application_configuration.connection_strings, []) : contains(["Custom", "MySql", "PostgreSQL", "SQLAzure", "SQLServer"], cs.type)
    ])
    error_message = "application_configuration.connection_strings[*].type must be one of Custom, MySql, PostgreSQL, SQLAzure, SQLServer."
  }
}

variable "access_configuration" {
  description = <<-EOT
    Access, networking, and publishing configuration for the Function App.

    https_only/public_network_access_enabled: Controls public access surface.
    client_certificate_*: Client certificate behavior.
    ftp_publish_basic_authentication_enabled/webdeploy_publish_basic_authentication_enabled: Publishing profile auth settings.
    key_vault_reference_identity_id: User-assigned identity used for Key Vault references.
    virtual_network_subnet_id/virtual_network_backup_restore_enabled/vnet_image_pull_enabled: VNet integration settings.
  EOT

  type = object({
    https_only                                     = optional(bool, true)
    public_network_access_enabled                  = optional(bool, false)
    client_certificate_enabled                     = optional(bool, false)
    client_certificate_mode                        = optional(string)
    client_certificate_exclusion_paths             = optional(string)
    ftp_publish_basic_authentication_enabled       = optional(bool, false)
    webdeploy_publish_basic_authentication_enabled = optional(bool, false)
    key_vault_reference_identity_id                = optional(string)
    virtual_network_subnet_id                      = optional(string)
    virtual_network_backup_restore_enabled         = optional(bool, false)
    vnet_image_pull_enabled                        = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition     = try(var.access_configuration.client_certificate_mode, null) == null || contains(["Required", "Optional", "OptionalInteractiveUser"], var.access_configuration.client_certificate_mode)
    error_message = "access_configuration.client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }

  validation {
    condition     = try(var.access_configuration.client_certificate_mode, null) == null || try(var.access_configuration.client_certificate_enabled, false)
    error_message = "access_configuration.client_certificate_mode can only be set when access_configuration.client_certificate_enabled is true."
  }
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
    auth_enabled                            = optional(bool)
    runtime_version                         = optional(string)
    config_file_path                        = optional(string)
    require_authentication                  = optional(bool)
    unauthenticated_action                  = optional(string)
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string))
    require_https                           = optional(bool)
    http_route_api_prefix                   = optional(string)
    forward_proxy_convention                = optional(string)
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
      name                          = string
      client_id                     = string
      openid_configuration_endpoint = string
      client_secret_setting_name    = optional(string)
      allowed_audiences             = optional(list(string))
      login_scopes                  = optional(list(string))
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
      consumer_key                 = string
      consumer_secret_setting_name = string
    }))
  })
  default   = null
  sensitive = true
}

variable "site_configuration" {
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
    auto_swap_slot_name                           = optional(string)
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    cors = optional(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool)
    }))
    default_documents                 = optional(list(string))
    elastic_instance_minimum          = optional(number)
    ftps_state                        = optional(string)
    health_check_path                 = optional(string)
    health_check_eviction_time_in_min = optional(number)
    http2_enabled                     = optional(bool)
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
    ip_restriction_default_action    = optional(string)
    load_balancing_mode              = optional(string)
    managed_pipeline_mode            = optional(string)
    minimum_tls_version              = optional(string)
    pre_warmed_instance_count        = optional(number)
    remote_debugging_enabled         = optional(bool)
    remote_debugging_version         = optional(string)
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
  default = null

  validation {
    condition     = var.site_configuration == null || var.site_configuration.ftps_state == null || contains(["AllAllowed", "FtpsOnly", "Disabled"], var.site_configuration.ftps_state)
    error_message = "site_configuration.ftps_state must be AllAllowed, FtpsOnly, or Disabled."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.minimum_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], var.site_configuration.minimum_tls_version)
    error_message = "site_configuration.minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.scm_minimum_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], var.site_configuration.scm_minimum_tls_version)
    error_message = "site_configuration.scm_minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.ip_restriction_default_action == null || contains(["Allow", "Deny"], var.site_configuration.ip_restriction_default_action)
    error_message = "site_configuration.ip_restriction_default_action must be Allow or Deny."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.scm_ip_restriction_default_action == null || contains(["Allow", "Deny"], var.site_configuration.scm_ip_restriction_default_action)
    error_message = "site_configuration.scm_ip_restriction_default_action must be Allow or Deny."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.managed_pipeline_mode == null || contains(["Integrated", "Classic"], var.site_configuration.managed_pipeline_mode)
    error_message = "site_configuration.managed_pipeline_mode must be Integrated or Classic."
  }

  validation {
    condition = var.site_configuration == null || var.site_configuration.load_balancing_mode == null || contains([
      "WeightedRoundRobin",
      "LeastRequests",
      "LeastResponseTime",
      "WeightedTotalTraffic",
      "RequestHash",
      "PerSiteRoundRobin"
    ], var.site_configuration.load_balancing_mode)
    error_message = "site_configuration.load_balancing_mode contains an unsupported value."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.remote_debugging_version == null || contains(["VS2017", "VS2019", "VS2022"], var.site_configuration.remote_debugging_version)
    error_message = "site_configuration.remote_debugging_version must be VS2017, VS2019, or VS2022."
  }

  validation {
    condition = var.site_configuration == null || (
      var.site_configuration.application_stack != null && (
        (var.site_configuration.application_stack.docker != null ? 1 : 0) +
        (var.site_configuration.application_stack.dotnet_version != null ? 1 : 0) +
        (var.site_configuration.application_stack.java_version != null ? 1 : 0) +
        (var.site_configuration.application_stack.node_version != null ? 1 : 0) +
        (var.site_configuration.application_stack.powershell_core_version != null ? 1 : 0) +
        (var.site_configuration.application_stack.python_version != null ? 1 : 0) +
        (coalesce(try(var.site_configuration.application_stack.use_custom_runtime, null), false) ? 1 : 0)
      ) == 1
    )
    error_message = "site_configuration.application_stack must be set with exactly one runtime (docker or a single language runtime or custom runtime)."
  }

  validation {
    condition     = var.site_configuration == null || var.site_configuration.health_check_eviction_time_in_min == null || var.site_configuration.health_check_path != null
    error_message = "health_check_eviction_time_in_min requires health_check_path to be set."
  }

  validation {
    condition = var.site_configuration == null || var.site_configuration.application_stack == null || var.site_configuration.application_stack.docker == null || (
      try(var.site_configuration.container_registry_use_managed_identity, false) ||
      (
        try(var.site_configuration.application_stack.docker.registry_username, null) != null &&
        try(var.site_configuration.application_stack.docker.registry_password, null) != null
      )
    )
    error_message = "Docker registry_username and registry_password are required when container_registry_use_managed_identity is false."
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
    name         = string
    app_settings = optional(map(string))
    connection_strings = optional(list(object({
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
    functions_extension_version              = optional(string)
    builtin_logging_enabled                  = optional(bool)
    enabled                                  = optional(bool)
    https_only                               = optional(bool)
    public_network_access_enabled            = optional(bool)
    client_certificate_enabled               = optional(bool)
    client_certificate_mode                  = optional(string)
    client_certificate_exclusion_paths       = optional(string)
    ftp_publish_basic_authentication_enabled = optional(bool)
    key_vault_reference_identity_id          = optional(string)
    storage_key_vault_secret_id              = optional(string)
    virtual_network_subnet_id                = optional(string)
    virtual_network_backup_restore_enabled   = optional(bool)
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
      auth_enabled                            = optional(bool)
      runtime_version                         = optional(string)
      config_file_path                        = optional(string)
      require_authentication                  = optional(bool)
      unauthenticated_action                  = optional(string)
      default_provider                        = optional(string)
      excluded_paths                          = optional(list(string))
      require_https                           = optional(bool)
      http_route_api_prefix                   = optional(string)
      forward_proxy_convention                = optional(string)
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
        name                          = string
        client_id                     = string
        openid_configuration_endpoint = string
        client_secret_setting_name    = optional(string)
        allowed_audiences             = optional(list(string))
        login_scopes                  = optional(list(string))
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
        consumer_key                 = string
        consumer_secret_setting_name = string
      }))
    }))
    site_configuration = optional(object({
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
      auto_swap_slot_name                           = optional(string)
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      cors = optional(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool)
      }))
      default_documents                 = optional(list(string))
      elastic_instance_minimum          = optional(number)
      ftps_state                        = optional(string)
      health_check_path                 = optional(string)
      health_check_eviction_time_in_min = optional(number)
      http2_enabled                     = optional(bool)
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
      ip_restriction_default_action    = optional(string)
      load_balancing_mode              = optional(string)
      managed_pipeline_mode            = optional(string)
      minimum_tls_version              = optional(string)
      pre_warmed_instance_count        = optional(number)
      remote_debugging_enabled         = optional(bool)
      remote_debugging_version         = optional(string)
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
    }))
    tags = optional(map(string))
  }))
  default = []

  validation {
    condition     = length(distinct([for slot in var.slots : slot.name])) == length(var.slots)
    error_message = "Each slot name must be unique."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : slot.auth_settings == null || slot.auth_settings_v2 == null
    ])
    error_message = "auth_settings and auth_settings_v2 are mutually exclusive for slots."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : slot.client_certificate_mode == null || try(slot.client_certificate_enabled, false)
    ])
    error_message = "client_certificate_mode can only be set when client_certificate_enabled is true."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : slot.site_configuration == null || (
        slot.site_configuration.application_stack != null && (
          (slot.site_configuration.application_stack.docker != null ? 1 : 0) +
          (slot.site_configuration.application_stack.dotnet_version != null ? 1 : 0) +
          (slot.site_configuration.application_stack.java_version != null ? 1 : 0) +
          (slot.site_configuration.application_stack.node_version != null ? 1 : 0) +
          (slot.site_configuration.application_stack.powershell_core_version != null ? 1 : 0) +
          (slot.site_configuration.application_stack.python_version != null ? 1 : 0) +
          (coalesce(try(slot.site_configuration.application_stack.use_custom_runtime, null), false) ? 1 : 0)
        ) == 1
      )
    ])
    error_message = "slot.site_configuration.application_stack must be set with exactly one runtime (docker or a single language runtime or custom runtime)."
  }

  validation {
    condition = alltrue([
      for slot in var.slots : slot.site_configuration == null || slot.site_configuration.health_check_eviction_time_in_min == null || slot.site_configuration.health_check_path != null
    ])
    error_message = "slot.site_configuration.health_check_eviction_time_in_min requires health_check_path to be set."
  }
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for logs and metrics."
  type = list(object({
    name                           = string
    log_categories                 = optional(list(string))
    log_category_groups            = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    partner_solution_id            = optional(string)
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
      trimspace(ds.name) != ""
    ])
    error_message = "Each diagnostic setting name must not be empty or whitespace."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      (
        (ds.log_analytics_workspace_id != null && trimspace(ds.log_analytics_workspace_id) != "") ||
        (ds.storage_account_id != null && trimspace(ds.storage_account_id) != "") ||
        (ds.eventhub_authorization_rule_id != null && trimspace(ds.eventhub_authorization_rule_id) != "") ||
        (ds.partner_solution_id != null && trimspace(ds.partner_solution_id) != "")
      )
    ])
    error_message = "Each diagnostic setting must specify at least one destination: log_analytics_workspace_id, storage_account_id, eventhub_authorization_rule_id, or partner_solution_id."
  }

  validation {
    condition = alltrue(flatten([
      for ds in var.diagnostic_settings : [
        ds.log_analytics_workspace_id == null || trimspace(ds.log_analytics_workspace_id) != "",
        ds.storage_account_id == null || trimspace(ds.storage_account_id) != "",
        ds.eventhub_authorization_rule_id == null || trimspace(ds.eventhub_authorization_rule_id) != "",
        ds.partner_solution_id == null || trimspace(ds.partner_solution_id) != "",
        ds.eventhub_name == null || trimspace(ds.eventhub_name) != ""
      ]
    ]))
    error_message = "Diagnostic setting destination and eventhub_name values must not be empty or whitespace."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null || trimspace(ds.eventhub_authorization_rule_id) == "" || (ds.eventhub_name != null && trimspace(ds.eventhub_name) != "")
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

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      (length(coalesce(ds.log_categories, [])) + length(coalesce(ds.log_category_groups, [])) + length(coalesce(ds.metric_categories, []))) > 0
    ])
    error_message = "Each diagnostic setting must include at least one log category, log category group, or metric category."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
