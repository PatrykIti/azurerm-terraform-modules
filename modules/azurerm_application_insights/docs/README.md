# Application Insights Module Documentation

## Overview

The `azurerm_application_insights` module provisions an Azure Application Insights
component and optional sub-resources commonly used for monitoring and observability.
The module is atomic: it manages a single Application Insights instance and related
features without bundling networking or RBAC glue.

## Managed Resources

- `azurerm_application_insights`
- `azurerm_application_insights_api_key`
- `azurerm_application_insights_analytics_item`
- `azurerm_application_insights_web_test`
- `azurerm_application_insights_standard_web_test`
- `azurerm_application_insights_workbook`
- `azurerm_application_insights_smart_detection_rule`
- `azurerm_monitor_diagnostic_setting`

## Out of Scope

The following must be handled outside the module:

- Private endpoints and Private DNS zones
- RBAC/role assignments
- Virtual network integration or firewall rules
- Log Analytics workspace provisioning (pass the ID via `workspace_id`)

## Usage Notes

- For workspace-based Application Insights, set `workspace_id`.
- Use `monitoring` to configure diagnostic settings with explicit categories.
- API keys are sensitive outputs; avoid logging them and rotate regularly.

## Additional References

- See `SECURITY.md` for security hardening guidance.
- See `IMPORT.md` for import instructions.
