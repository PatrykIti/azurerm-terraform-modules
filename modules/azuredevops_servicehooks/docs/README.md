# Azure DevOps Service Hooks Module Documentation

## Overview

This module manages a single Azure DevOps webhook service hook.

## Managed Resources

- `azuredevops_servicehook_webhook_tfs`

## Usage Notes

- The module creates exactly one webhook per instance.
- Use module-level `for_each` in consumer configuration for multiple webhooks.
- Storage queue hooks and service-hook permissions are outside this module scope.

## Inputs (Highlights)

- Required: `project_id`, `webhook`

## Outputs (Highlights)

- `webhook_id`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.
