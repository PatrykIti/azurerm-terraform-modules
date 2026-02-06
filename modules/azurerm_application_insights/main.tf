locals {
  api_keys_by_name        = { for key in var.api_keys : key.name => key }
  analytics_items_by_name = { for item in var.analytics_items : item.name => item }
  web_tests_by_name       = { for test in var.web_tests : test.name => test }
  standard_web_tests_by_name = {
    for test in var.standard_web_tests : test.name => merge(test, {
      request = merge(test.request, {
        header = (
          try(length(test.request.header), 0) > 0 ? test.request.header :
          try(length(keys(test.request.headers)), 0) > 0 ? [
            for name, value in test.request.headers : {
              name  = name
              value = value
            }
          ] : []
        )
      })
    })
  }
  smart_detection_rules_by_name = { for rule in var.smart_detection_rules : rule.name => rule }
  hidden_link_tag               = { "hidden-link:${azurerm_application_insights.application_insights.id}" = "Resource" }
}

resource "azurerm_application_insights" "application_insights" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = var.application_type

  workspace_id                          = var.workspace_id
  retention_in_days                     = var.retention_in_days
  sampling_percentage                   = var.sampling_percentage
  daily_data_cap_in_gb                  = var.daily_data_cap_in_gb
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled
  internet_ingestion_enabled            = var.internet_ingestion_enabled
  internet_query_enabled                = var.internet_query_enabled
  local_authentication_disabled         = var.local_authentication_disabled
  disable_ip_masking                    = var.disable_ip_masking

  tags = var.tags

  dynamic "timeouts" {
    for_each = (
      var.timeouts.create != null ||
      var.timeouts.update != null ||
      var.timeouts.delete != null ||
      var.timeouts.read != null
    ) ? [var.timeouts] : []

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}

resource "azurerm_application_insights_api_key" "application_insights_api_key" {
  for_each = local.api_keys_by_name

  name                    = each.value.name
  application_insights_id = azurerm_application_insights.application_insights.id
  read_permissions        = try(each.value.read_permissions, [])
  write_permissions       = try(each.value.write_permissions, [])
}

resource "azurerm_application_insights_analytics_item" "application_insights_analytics_item" {
  for_each = local.analytics_items_by_name

  name                    = each.value.name
  application_insights_id = azurerm_application_insights.application_insights.id
  content                 = each.value.content
  scope                   = each.value.scope
  type                    = each.value.type
}

resource "azurerm_application_insights_web_test" "application_insights_web_test" {
  for_each = local.web_tests_by_name

  name                    = each.value.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.application_insights.id
  kind                    = try(each.value.kind, "ping")
  description             = try(each.value.description, null)
  frequency               = try(each.value.frequency, 300)
  timeout                 = try(each.value.timeout, 30)
  enabled                 = try(each.value.enabled, true)
  retry_enabled           = try(each.value.retry_enabled, null)
  geo_locations           = each.value.geo_locations
  configuration           = each.value.web_test_xml

  tags = merge(var.tags, try(each.value.tags, {}), local.hidden_link_tag)
}

resource "azurerm_application_insights_standard_web_test" "application_insights_standard_web_test" {
  for_each = local.standard_web_tests_by_name

  name                    = each.value.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.application_insights.id
  description             = try(each.value.description, null)
  geo_locations           = each.value.geo_locations
  retry_enabled           = try(each.value.retry_enabled, null)
  frequency               = try(each.value.frequency, 300)
  timeout                 = try(each.value.timeout, 30)
  enabled                 = try(each.value.enabled, true)

  request {
    url                              = each.value.request.url
    body                             = try(each.value.request.body, null)
    http_verb                        = try(each.value.request.http_verb, null)
    follow_redirects_enabled         = try(each.value.request.follow_redirects_enabled, null)
    parse_dependent_requests_enabled = try(each.value.request.parse_dependent_requests_enabled, null)

    dynamic "header" {
      for_each = try(each.value.request.header, [])
      content {
        name  = header.value.name
        value = header.value.value
      }
    }
  }

  dynamic "validation_rules" {
    for_each = each.value.validation_rules != null ? [each.value.validation_rules] : []
    content {
      expected_status_code        = try(validation_rules.value.expected_status_code, null)
      ssl_check_enabled           = try(validation_rules.value.ssl_check_enabled, null)
      ssl_cert_remaining_lifetime = try(validation_rules.value.ssl_cert_remaining_lifetime, null)

      dynamic "content" {
        for_each = try(validation_rules.value.content, null) != null ? [validation_rules.value.content] : []
        content {
          content_match      = content.value.content_match
          ignore_case        = try(content.value.ignore_case, null)
          pass_if_text_found = try(content.value.pass_if_text_found, null)
        }
      }
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}), local.hidden_link_tag)
}

resource "azurerm_application_insights_smart_detection_rule" "application_insights_smart_detection_rule" {
  for_each = local.smart_detection_rules_by_name

  name                    = each.value.name
  application_insights_id = azurerm_application_insights.application_insights.id
  enabled                 = try(each.value.enabled, true)
}
