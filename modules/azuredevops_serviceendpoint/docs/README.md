# Azure DevOps Service Endpoint Module Documentation

## Overview

This module manages a single generic Azure DevOps service endpoint and optional strict-child permissions.

## Managed Resources

- `azuredevops_serviceendpoint_generic`
- `azuredevops_serviceendpoint_permissions`

## Usage Notes

- The module creates exactly one generic service endpoint per instance.
- Permissions in `serviceendpoint_permissions` are always attached to the endpoint created by this module.
- Use module-level `for_each` in consumer configuration for multiple endpoints.

## Inputs (Highlights)

- Required: `project_id`, `serviceendpoint_generic`
- Optional: `serviceendpoint_permissions`

## Outputs (Highlights)

- `serviceendpoint_id`
- `serviceendpoint_name`
- `permissions`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.
