# Azure Monitor Private Link Scope Module

## Overview

This module manages an Azure Monitor Private Link Scope (AMPLS) and optional scoped services. It supports configuring ingestion/query access modes and attaching Azure Monitor resources (Log Analytics, Application Insights, DCE, etc.) to the scope.

## Managed Resources

- `azurerm_monitor_private_link_scope`
- `azurerm_monitor_private_link_scoped_service`
- `azurerm_monitor_diagnostic_setting`

## Usage Notes

- AMPLS itself does **not** create private endpoints or DNS zones. Those are out of scope and must be created outside this module.
- Use `scoped_services` to link resources like Log Analytics workspaces, Application Insights, or Data Collection Endpoints to the scope.
- Diagnostic settings are optional and require explicit log/metric categories.

## Out of Scope

- Private endpoints and Private DNS zones
- VNet links and network rules
- RBAC/role assignments
- Resource creation for Log Analytics, Application Insights, DCE, etc.
