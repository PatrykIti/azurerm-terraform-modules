# Terraform Azure App Service Plan Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure App Service Plan Terraform module covering the full `azurerm_service_plan`
surface in AzureRM 4.57.0, including inline diagnostic settings and plan-level
scaling options for Windows, Linux, Windows Container, Elastic Premium, and
ASE-backed isolated plans.

## Usage

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-app-service-plan-example"
  location = "westeurope"
}

module "service_plan" {
  source = "path/to/azurerm_service_plan"

  name                = "asp-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan = {
    os_type      = "Linux"
    sku_name     = "S1"
    worker_count = 1
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal App Service Plan deployment using a shared
- [Complete](examples/complete) - This example demonstrates a Standard Linux App Service Plan with explicit
- [Elastic Premium](examples/elastic-premium) - This example demonstrates an Elastic Premium Linux App Service Plan with a
- [Secure](examples/secure) - This example demonstrates an operationally hardened App Service Plan baseline
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
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_service_plan.service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the App Service Plan.<br/><br/>Supported categories for Microsoft.Web/serverfarms used by this module:<br/>- log\_categories: AppServiceConsoleLogs<br/>- metric\_categories: AllMetrics<br/><br/>Entries with no log or metric categories are skipped and reported in<br/>diagnostic\_settings\_skipped. | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    partner_solution_id            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the App Service Plan is created.<br/>Typically match the resource group location. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the App Service Plan.<br/>Provide a non-empty plan name that is unique within the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the App Service Plan is created.<br/>The resource group must already exist. | `string` | n/a | yes |
| <a name="input_service_plan"></a> [service\_plan](#input\_service\_plan) | Core App Service Plan configuration.<br/><br/>os\_type: Operating system type for workloads hosted by the plan.<br/>sku\_name: App Service Plan SKU supported by azurerm 4.57.0.<br/>app\_service\_environment\_id: Optional App Service Environment v3 ID for isolated plans.<br/>premium\_plan\_auto\_scale\_enabled: Enable autoscale support on Premium v2/v3/v4 plans.<br/>maximum\_elastic\_worker\_count: Maximum number of elastic workers for Elastic Premium or Premium autoscale plans.<br/>worker\_count: Number of workers allocated to the plan.<br/>per\_site\_scaling\_enabled: Enable per-site scaling across apps hosted on the plan.<br/>zone\_balancing\_enabled: Balance workers across availability zones when supported.<br/>timeouts: Optional custom create/read/update/delete timeouts. | <pre>object({<br/>    os_type                    = string<br/>    sku_name                   = string<br/>    app_service_environment_id = optional(string)<br/><br/>    premium_plan_auto_scale_enabled = optional(bool, false)<br/>    maximum_elastic_worker_count    = optional(number)<br/>    worker_count                    = optional(number)<br/>    per_site_scaling_enabled        = optional(bool, false)<br/>    zone_balancing_enabled          = optional(bool, false)<br/><br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the App Service Plan.<br/>Provide a map of string keys and values. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_environment_id"></a> [app\_service\_environment\_id](#output\_app\_service\_environment\_id) | The App Service Environment ID assigned to the App Service Plan, if any. |
| <a name="output_diagnostic_settings"></a> [diagnostic\_settings](#output\_diagnostic\_settings) | Map of diagnostic settings keyed by name. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the App Service Plan. |
| <a name="output_kind"></a> [kind](#output\_kind) | The kind of the App Service Plan. |
| <a name="output_location"></a> [location](#output\_location) | The location of the App Service Plan. |
| <a name="output_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#output\_maximum\_elastic\_worker\_count) | The configured maximum elastic worker count for the App Service Plan. |
| <a name="output_name"></a> [name](#output\_name) | The name of the App Service Plan. |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | The configured operating system type for the App Service Plan. |
| <a name="output_per_site_scaling_enabled"></a> [per\_site\_scaling\_enabled](#output\_per\_site\_scaling\_enabled) | Whether per-site scaling is enabled for the App Service Plan. |
| <a name="output_premium_plan_auto_scale_enabled"></a> [premium\_plan\_auto\_scale\_enabled](#output\_premium\_plan\_auto\_scale\_enabled) | Whether Premium autoscale is enabled for the App Service Plan. |
| <a name="output_reserved"></a> [reserved](#output\_reserved) | Whether the App Service Plan is reserved for Linux workloads. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the App Service Plan. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The configured SKU name for the App Service Plan. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the App Service Plan. |
| <a name="output_worker_count"></a> [worker\_count](#output\_worker\_count) | The configured worker count for the App Service Plan. |
| <a name="output_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#output\_zone\_balancing\_enabled) | Whether zone balancing is enabled for the App Service Plan. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security considerations and hardening guidance
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Extended scope and usage notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing App Service Plans
