# Azure DevOps Variable Groups Module Documentation

## Overview

This module manages a single Azure DevOps variable group and optional strict-child variable-group permissions.

## Managed Resources

- `azuredevops_variable_group`
- `azuredevops_variable_group_permissions`

## Usage Notes

- The module creates exactly one variable group per instance.
- `variable_group_permissions` are always applied to the variable group created by this module.
- Library permissions are outside this module scope.

## Inputs (Highlights)

- Required: `project_id`, `name`, `variables`
- Optional: `description`, `allow_access`, `key_vault`, `variable_group_permissions`

## Outputs (Highlights)

- `variable_group_id`
- `variable_group_name`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.
