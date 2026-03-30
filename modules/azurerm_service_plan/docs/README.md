# App Service Plan Module Documentation

## Overview

This module provisions a single Azure App Service Plan through
`azurerm_service_plan` and optionally manages inline diagnostic settings. The
module is atomic: it owns the hosting plan itself and avoids cross-resource
glue for apps, private networking, RBAC, and observability workspaces.

## Managed Resources

- `azurerm_service_plan`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- **Plan-wide hosting only**: This module creates the shared hosting plan, not
  the web apps, function apps, or logic apps that run on it.
- **ASE support**: Use `service_plan.app_service_environment_id` only with
  isolated v2 SKUs supported by App Service Environment v3.
- **Elastic scaling**: `service_plan.maximum_elastic_worker_count` is supported
  for Elastic Premium plans and Premium plans with
  `premium_plan_auto_scale_enabled = true`.
- **Premium autoscale flag**: `premium_plan_auto_scale_enabled` is only valid
  for Premium v2/v3/v4 SKUs.
- **Zone balancing**: Requires a supported SKU and `worker_count > 1`.
- **Diagnostics**: Use `diagnostic_settings` to export supported logs and
  metrics for `Microsoft.Web/serverfarms`.

## Out of Scope

The following are intentionally managed outside this module:

- Web apps, function apps, and deployment slots
- App-level TLS, authentication, app settings, and connection strings
- Private endpoints, Private DNS, and VNet glue
- Role assignments / RBAC / budgets
- Log Analytics workspaces, storage accounts, and Event Hub namespaces used as diagnostic destinations

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for module contribution guidance.
