# Terraform Azure Application Insights Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Application Insights with related monitoring resources

## Usage

```hcl
module "azurerm_application_insights" {
  source = "path/to/azurerm_application_insights"

  # Required variables
  name                = "example-azurerm_application_insights"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Analytics Items](examples/analytics-items) - This example demonstrates how to define analytics items (queries) for
- [Api Keys](examples/api-keys) - This example demonstrates how to create Application Insights API keys with
- [Basic](examples/basic) - This example demonstrates a basic Application Insights configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Application Insights with all available features and configurations.
- [Secure](examples/secure) - This example demonstrates a maximum-security Application Insights configuration suitable for highly sensitive data and regulated environments.
- [Smart Detection Rules](examples/smart-detection-rules) - This example demonstrates how to configure smart detection rules for
- [Standard Web Tests](examples/standard-web-tests) - This example demonstrates standard Application Insights web tests with request
- [Web Tests](examples/web-tests) - This example demonstrates classic (XML-based) Application Insights web tests.
- [Workbooks](examples/workbooks) - This example demonstrates how to create Application Insights workbooks.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.application_insights](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights) | resource |
| [azurerm_application_insights_analytics_item.analytics_items](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_analytics_item) | resource |
| [azurerm_application_insights_api_key.api_keys](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_api_key) | resource |
| [azurerm_application_insights_smart_detection_rule.smart_detection_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_standard_web_test.standard_web_tests](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_standard_web_test) | resource |
| [azurerm_application_insights_web_test.web_tests](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_web_test) | resource |
| [azurerm_application_insights_workbook.workbooks](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/application_insights_workbook) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_analytics_items"></a> [analytics\_items](#input\_analytics\_items) | Analytics items for Application Insights. | <pre>list(object({<br/>    name    = string<br/>    content = string<br/>    scope   = string<br/>    type    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_api_keys"></a> [api\_keys](#input\_api\_keys) | Application Insights API keys. | <pre>list(object({<br/>    name             = string<br/>    read_permissions = optional(list(string), [])<br/>    write_permissions = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | The type of Application Insights. Valid values are web or other. | `string` | `"web"` | no |
| <a name="input_daily_data_cap_in_gb"></a> [daily\_data\_cap\_in\_gb](#input\_daily\_data\_cap\_in\_gb) | Daily data cap in GB for Application Insights. | `number` | `null` | no |
| <a name="input_daily_data_cap_notifications_disabled"></a> [daily\_data\_cap\_notifications\_disabled](#input\_daily\_data\_cap\_notifications\_disabled) | Whether daily data cap notifications are disabled. | `bool` | `false` | no |
| <a name="input_disable_ip_masking"></a> [disable\_ip\_masking](#input\_disable\_ip\_masking) | Whether IP masking is disabled. | `bool` | `false` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Whether ingestion over the public internet is enabled. | `bool` | `true` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Whether query over the public internet is enabled. | `bool` | `true` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Whether local authentication is disabled. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where Application Insights should exist. | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for Application Insights diagnostics.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Application Insights component. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create Application Insights. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Retention period (in days) for Application Insights data. | `number` | `null` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | Sampling percentage for data ingestion (0-100). | `number` | `null` | no |
| <a name="input_smart_detection_rules"></a> [smart\_detection\_rules](#input\_smart\_detection\_rules) | Smart detection rules for Application Insights. | <pre>list(object({<br/>    name    = string<br/>    enabled = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_standard_web_tests"></a> [standard\_web\_tests](#input\_standard\_web\_tests) | Standard Application Insights web tests. | <pre>list(object({<br/>    name          = string<br/>    description   = optional(string)<br/>    frequency     = optional(number, 300)<br/>    timeout       = optional(number, 30)<br/>    enabled       = optional(bool, true)<br/>    geo_locations = list(string)<br/>    request = object({<br/>      url                              = string<br/>      http_verb                        = optional(string, "GET")<br/>      request_body                     = optional(string)<br/>      follow_redirects_enabled         = optional(bool, true)<br/>      parse_dependent_requests_enabled = optional(bool, true)<br/>      headers                          = optional(map(string))<br/>    })<br/>    validation = optional(object({<br/>      expected_status_code        = optional(number)<br/>      ssl_check_enabled           = optional(bool)<br/>      ssl_cert_remaining_lifetime = optional(number)<br/>      content_match = optional(object({<br/>        content            = string<br/>        ignore_case        = optional(bool, true)<br/>        pass_if_text_found = optional(bool, true)<br/>      }))<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for Application Insights. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_web_tests"></a> [web\_tests](#input\_web\_tests) | Classic Application Insights web tests. | <pre>list(object({<br/>    name          = string<br/>    kind          = optional(string, "ping")<br/>    frequency     = optional(number, 300)<br/>    timeout       = optional(number, 30)<br/>    enabled       = optional(bool, true)<br/>    geo_locations = list(string)<br/>    web_test_xml  = string<br/>    tags          = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_workbooks"></a> [workbooks](#input\_workbooks) | Application Insights workbooks. | <pre>list(object({<br/>    name         = string<br/>    display_name = string<br/>    data_json    = string<br/>    description  = optional(string)<br/>    category     = optional(string)<br/>    source_id    = optional(string)<br/>    tags         = optional(map(string), {})<br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | The Log Analytics workspace ID for workspace-based Application Insights. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_analytics_items"></a> [analytics\_items](#output\_analytics\_items) | Analytics items created for Application Insights. |
| <a name="output_api_keys"></a> [api\_keys](#output\_api\_keys) | API keys created for Application Insights. |
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The Application Insights app ID. |
| <a name="output_application_type"></a> [application\_type](#output\_application\_type) | The application type for Application Insights. |
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | The Application Insights connection string. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Application Insights resource. |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | The Application Insights instrumentation key. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where Application Insights is deployed. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Application Insights resource. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name for Application Insights. |
| <a name="output_smart_detection_rules"></a> [smart\_detection\_rules](#output\_smart\_detection\_rules) | Smart detection rules created for Application Insights. |
| <a name="output_standard_web_tests"></a> [standard\_web\_tests](#output\_standard\_web\_tests) | Standard web tests created for Application Insights. |
| <a name="output_web_tests"></a> [web\_tests](#output\_web\_tests) | Classic web tests created for Application Insights. |
| <a name="output_workbooks"></a> [workbooks](#output\_workbooks) | Workbooks created for Application Insights. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The workspace ID linked to Application Insights (if workspace-based). |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
