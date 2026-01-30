resource "azurerm_windows_function_app" "windows_function_app" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = var.service_plan_id

  storage_account_name          = local.storage_account_name_effective
  storage_account_access_key    = local.storage_account_access_key_effective
  storage_uses_managed_identity = var.storage_uses_managed_identity
  storage_key_vault_secret_id   = var.storage_key_vault_secret_id

  functions_extension_version = var.functions_extension_version
  builtin_logging_enabled      = var.builtin_logging_enabled
  enabled                      = var.enabled

  https_only                   = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  client_certificate_enabled   = var.client_certificate_enabled
  client_certificate_mode      = var.client_certificate_mode
  client_certificate_exclusion_paths = var.client_certificate_exclusion_paths

  app_settings        = var.app_settings
  content_share_force_disabled = var.content_share_force_disabled
  daily_memory_time_quota      = var.daily_memory_time_quota
  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled

  application_insights_connection_string = var.application_insights_connection_string
  application_insights_key               = var.application_insights_key

  key_vault_reference_identity_id = var.key_vault_reference_identity_id
  virtual_network_backup_restore_enabled = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id       = var.virtual_network_subnet_id
  vnet_image_pull_enabled         = var.vnet_image_pull_enabled

  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file

  tags = var.tags

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "auth_settings" {
    for_each = var.auth_settings == null ? [] : [var.auth_settings]
    content {
      enabled                        = auth_settings.value.enabled
      additional_login_parameters    = auth_settings.value.additional_login_parameters
      allowed_external_redirect_urls = auth_settings.value.allowed_external_redirect_urls
      default_provider               = auth_settings.value.default_provider
      issuer                         = auth_settings.value.issuer
      runtime_version                = auth_settings.value.runtime_version
      token_refresh_extension_hours  = auth_settings.value.token_refresh_extension_hours
      token_store_enabled            = auth_settings.value.token_store_enabled
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action

      dynamic "active_directory" {
        for_each = auth_settings.value.active_directory == null ? [] : [auth_settings.value.active_directory]
        content {
          client_id                  = active_directory.value.client_id
          client_secret              = active_directory.value.client_secret
          client_secret_setting_name = active_directory.value.client_secret_setting_name
          allowed_audiences          = active_directory.value.allowed_audiences
        }
      }

      dynamic "facebook" {
        for_each = auth_settings.value.facebook == null ? [] : [auth_settings.value.facebook]
        content {
          app_id                  = facebook.value.app_id
          app_secret              = facebook.value.app_secret
          app_secret_setting_name = facebook.value.app_secret_setting_name
          oauth_scopes            = facebook.value.oauth_scopes
        }
      }

      dynamic "github" {
        for_each = auth_settings.value.github == null ? [] : [auth_settings.value.github]
        content {
          client_id                  = github.value.client_id
          client_secret              = github.value.client_secret
          client_secret_setting_name = github.value.client_secret_setting_name
          oauth_scopes               = github.value.oauth_scopes
        }
      }

      dynamic "google" {
        for_each = auth_settings.value.google == null ? [] : [auth_settings.value.google]
        content {
          client_id                  = google.value.client_id
          client_secret              = google.value.client_secret
          client_secret_setting_name = google.value.client_secret_setting_name
          oauth_scopes               = google.value.oauth_scopes
        }
      }

      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft == null ? [] : [auth_settings.value.microsoft]
        content {
          client_id                  = microsoft.value.client_id
          client_secret              = microsoft.value.client_secret
          client_secret_setting_name = microsoft.value.client_secret_setting_name
          oauth_scopes               = microsoft.value.oauth_scopes
        }
      }

      dynamic "twitter" {
        for_each = auth_settings.value.twitter == null ? [] : [auth_settings.value.twitter]
        content {
          consumer_key              = twitter.value.consumer_key
          consumer_secret           = twitter.value.consumer_secret
          consumer_secret_setting_name = twitter.value.consumer_secret_setting_name
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2 == null ? [] : [var.auth_settings_v2]
    content {
      auth_enabled                             = auth_settings_v2.value.auth_enabled
      config_file_path                         = auth_settings_v2.value.config_file_path
      default_provider                         = auth_settings_v2.value.default_provider
      excluded_paths                           = auth_settings_v2.value.excluded_paths
      forward_proxy_convention                 = auth_settings_v2.value.forward_proxy_convention
      forward_proxy_custom_host_header_name    = auth_settings_v2.value.forward_proxy_custom_host_header_name
      forward_proxy_custom_scheme_header_name  = auth_settings_v2.value.forward_proxy_custom_scheme_header_name
      http_route_api_prefix                    = auth_settings_v2.value.http_route_api_prefix
      require_authentication                   = auth_settings_v2.value.require_authentication
      require_https                            = auth_settings_v2.value.require_https
      runtime_version                          = auth_settings_v2.value.runtime_version
      unauthenticated_action                   = auth_settings_v2.value.unauthenticated_action

      dynamic "active_directory_v2" {
        for_each = auth_settings_v2.value.active_directory_v2 == null ? [] : [auth_settings_v2.value.active_directory_v2]
        content {
          client_id                       = active_directory_v2.value.client_id
          tenant_auth_endpoint            = active_directory_v2.value.tenant_auth_endpoint
          client_secret_setting_name      = active_directory_v2.value.client_secret_setting_name
          allowed_audiences               = active_directory_v2.value.allowed_audiences
          allowed_applications            = active_directory_v2.value.allowed_applications
          allowed_groups                  = active_directory_v2.value.allowed_groups
          allowed_identities              = active_directory_v2.value.allowed_identities
          jwt_allowed_client_applications = active_directory_v2.value.jwt_allowed_client_applications
          jwt_allowed_groups              = active_directory_v2.value.jwt_allowed_groups
          login_parameters                = active_directory_v2.value.login_parameters
          www_authentication_disabled     = active_directory_v2.value.www_authentication_disabled
        }
      }

      dynamic "apple_v2" {
        for_each = auth_settings_v2.value.apple_v2 == null ? [] : [auth_settings_v2.value.apple_v2]
        content {
          client_id                  = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
          login_scopes               = apple_v2.value.login_scopes
        }
      }

      dynamic "azure_static_web_app_v2" {
        for_each = auth_settings_v2.value.azure_static_web_app_v2 == null ? [] : [auth_settings_v2.value.azure_static_web_app_v2]
        content {
          client_id = azure_static_web_app_v2.value.client_id
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = auth_settings_v2.value.custom_oidc_v2 == null ? [] : auth_settings_v2.value.custom_oidc_v2
        content {
          name                          = custom_oidc_v2.value.name
          client_id                     = custom_oidc_v2.value.client_id
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          client_credential_method      = custom_oidc_v2.value.client_credential_method
          client_secret_setting_name    = custom_oidc_v2.value.client_secret_setting_name
          scopes                        = custom_oidc_v2.value.scopes
        }
      }

      dynamic "facebook_v2" {
        for_each = auth_settings_v2.value.facebook_v2 == null ? [] : [auth_settings_v2.value.facebook_v2]
        content {
          app_id                  = facebook_v2.value.app_id
          app_secret_setting_name = facebook_v2.value.app_secret_setting_name
          graph_api_version       = facebook_v2.value.graph_api_version
          login_scopes            = facebook_v2.value.login_scopes
        }
      }

      dynamic "github_v2" {
        for_each = auth_settings_v2.value.github_v2 == null ? [] : [auth_settings_v2.value.github_v2]
        content {
          client_id                  = github_v2.value.client_id
          client_secret_setting_name = github_v2.value.client_secret_setting_name
          login_scopes               = github_v2.value.login_scopes
        }
      }

      dynamic "google_v2" {
        for_each = auth_settings_v2.value.google_v2 == null ? [] : [auth_settings_v2.value.google_v2]
        content {
          client_id                  = google_v2.value.client_id
          client_secret_setting_name = google_v2.value.client_secret_setting_name
          allowed_audiences          = google_v2.value.allowed_audiences
          login_scopes               = google_v2.value.login_scopes
        }
      }

      dynamic "microsoft_v2" {
        for_each = auth_settings_v2.value.microsoft_v2 == null ? [] : [auth_settings_v2.value.microsoft_v2]
        content {
          client_id                  = microsoft_v2.value.client_id
          client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
          allowed_audiences          = microsoft_v2.value.allowed_audiences
          login_scopes               = microsoft_v2.value.login_scopes
        }
      }

      dynamic "twitter_v2" {
        for_each = auth_settings_v2.value.twitter_v2 == null ? [] : [auth_settings_v2.value.twitter_v2]
        content {
          consumer_key               = twitter_v2.value.consumer_key
          consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }

      dynamic "login" {
        for_each = auth_settings_v2.value.login == null ? [] : [auth_settings_v2.value.login]
        content {
          allowed_external_redirect_urls    = login.value.allowed_external_redirect_urls
          cookie_expiration_convention      = login.value.cookie_expiration_convention
          cookie_expiration_time            = login.value.cookie_expiration_time
          logout_endpoint                   = login.value.logout_endpoint
          nonce_expiration_time             = login.value.nonce_expiration_time
          preserve_url_fragments_for_logins = login.value.preserve_url_fragments_for_logins
          token_refresh_extension_time      = login.value.token_refresh_extension_time
          token_store_enabled               = login.value.token_store_enabled
          token_store_path                  = login.value.token_store_path
          token_store_sas_setting_name      = login.value.token_store_sas_setting_name
          validate_nonce                    = login.value.validate_nonce
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]
    content {
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      dynamic "schedule" {
        for_each = backup.value.schedule == null ? [] : [backup.value.schedule]
        content {
          frequency_interval       = schedule.value.frequency_interval
          frequency_unit           = schedule.value.frequency_unit
          keep_at_least_one_backup = schedule.value.keep_at_least_one_backup
          retention_period_in_days = schedule.value.retention_period_in_days
          start_time               = schedule.value.start_time
        }
      }
    }
  }

  site_config {
    always_on                             = var.site_config.always_on
    api_definition_url                    = var.site_config.api_definition_url
    api_management_api_id                 = var.site_config.api_management_api_id
    app_command_line                      = var.site_config.app_command_line
    app_scale_limit                       = var.site_config.app_scale_limit
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    default_documents                     = var.site_config.default_documents
    elastic_instance_minimum              = var.site_config.elastic_instance_minimum
    ftps_state                            = var.site_config.ftps_state
    health_check_path                     = var.site_config.health_check_path
    health_check_eviction_time_in_min     = var.site_config.health_check_eviction_time_in_min
    http2_enabled                         = var.site_config.http2_enabled
    ip_restriction_default_action         = var.site_config.ip_restriction_default_action
    load_balancing_mode                   = var.site_config.load_balancing_mode
    managed_pipeline_mode                 = var.site_config.managed_pipeline_mode
    minimum_tls_version                   = var.site_config.minimum_tls_version
    pre_warmed_instance_count             = var.site_config.pre_warmed_instance_count
    remote_debugging_enabled              = var.site_config.remote_debugging_enabled
    remote_debugging_version              = var.site_config.remote_debugging_version
    runtime_scale_monitoring_enabled      = var.site_config.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action     = var.site_config.scm_ip_restriction_default_action
    scm_minimum_tls_version               = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction           = var.site_config.scm_use_main_ip_restriction
    use_32_bit_worker                     = var.site_config.use_32_bit_worker
    vnet_route_all_enabled                = var.site_config.vnet_route_all_enabled
    websockets_enabled                    = var.site_config.websockets_enabled
    worker_count                          = var.site_config.worker_count

    dynamic "application_stack" {
      for_each = var.site_config.application_stack == null ? [] : [var.site_config.application_stack]
      content {
        dotnet_version              = application_stack.value.dotnet_version
        java_version                = application_stack.value.java_version
        node_version                = application_stack.value.node_version
        powershell_core_version     = application_stack.value.powershell_core_version
        use_custom_runtime          = application_stack.value.use_custom_runtime
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
      }
    }

    dynamic "app_service_logs" {
      for_each = var.site_config.app_service_logs == null ? [] : [var.site_config.app_service_logs]
      content {
        disk_quota_mb         = app_service_logs.value.disk_quota_mb
        retention_period_days = app_service_logs.value.retention_period_days

        dynamic "azure_blob_storage" {
          for_each = app_service_logs.value.azure_blob_storage == null ? [] : [app_service_logs.value.azure_blob_storage]
          content {
            level             = azure_blob_storage.value.level
            sas_url           = azure_blob_storage.value.sas_url
            retention_in_days = azure_blob_storage.value.retention_in_days
          }
        }
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors == null ? [] : [var.site_config.cors]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restriction == null ? [] : var.site_config.ip_restriction
      content {
        action                    = ip_restriction.value.action
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        description               = ip_restriction.value.description

        dynamic "headers" {
          for_each = ip_restriction.value.headers == null ? [] : [ip_restriction.value.headers]
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.site_config.scm_ip_restriction == null ? [] : var.site_config.scm_ip_restriction
      content {
        action                    = scm_ip_restriction.value.action
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        description               = scm_ip_restriction.value.description

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers == null ? [] : [scm_ip_restriction.value.headers]
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_accounts
    content {
      name         = storage_account.value.name
      account_name = storage_account.value.account_name
      access_key   = storage_account.value.access_key
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = storage_account.value.mount_path
    }
  }

  dynamic "sticky_settings" {
    for_each = var.sticky_settings == null ? [] : [var.sticky_settings]
    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = var.service_plan_id != null && var.service_plan_id != ""
      error_message = "service_plan_id is required."
    }

    precondition {
      condition     = local.storage_key_vault_secret_id_set || (var.storage_account_name != null && var.storage_account_name != "")
      error_message = "Either storage_account_name or storage_key_vault_secret_id must be set."
    }

    precondition {
      condition     = !local.storage_key_vault_secret_id_set || (var.storage_account_name == null || var.storage_account_name == "")
      error_message = "storage_key_vault_secret_id cannot be used with storage_account_name."
    }

    precondition {
      condition     = !local.storage_key_vault_secret_id_set || (var.storage_account_access_key == null || var.storage_account_access_key == "")
      error_message = "storage_key_vault_secret_id cannot be used with storage_account_access_key."
    }

    precondition {
      condition     = !local.storage_key_vault_secret_id_set || var.storage_uses_managed_identity == false
      error_message = "storage_key_vault_secret_id cannot be used with storage_uses_managed_identity."
    }

    precondition {
      condition = local.storage_key_vault_secret_id_set ? true : (
        var.storage_uses_managed_identity ? (
          var.identity != null &&
          (var.storage_account_access_key == null || var.storage_account_access_key == "")
        ) : (
          var.storage_account_access_key != null && var.storage_account_access_key != ""
        )
      )
      error_message = "When storage_uses_managed_identity is true, identity must be configured and storage_account_access_key must be null. When false, storage_account_access_key is required."
    }

    precondition {
      condition     = !(var.auth_settings != null && var.auth_settings_v2 != null)
      error_message = "auth_settings and auth_settings_v2 are mutually exclusive."
    }

    precondition {
      condition     = var.client_certificate_mode == null || var.client_certificate_enabled
      error_message = "client_certificate_mode requires client_certificate_enabled to be true."
    }

    precondition {
      condition     = var.site_config.application_stack != null && local.application_stack_count == 1
      error_message = "site_config.application_stack must be set with exactly one runtime (dotnet, java, node, powershell, or custom runtime)."
    }

    precondition {
      condition     = var.site_config.health_check_eviction_time_in_min == null || var.site_config.health_check_path != null
      error_message = "health_check_eviction_time_in_min requires health_check_path to be set."
    }
  }
}
