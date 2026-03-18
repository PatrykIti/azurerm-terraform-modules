# Azure DevOps Group Module Documentation

## Overview

This module manages Azure DevOps groups and strict-child memberships.

## Managed Resources

- `azuredevops_group`
- `azuredevops_group_membership` (only for module-managed group)

## Usage Notes

- Use `git::https://...//modules/azuredevops_group?ref=ADOGvX.Y.Z` for module source.
- `group_memberships` always targets the module-managed group descriptor.
- Use stable, unique membership keys to avoid address churn.
- Group entitlement scope is managed separately by `modules/azuredevops_group_entitlement`.

## Outputs (Highlights)

- `group_id`
- `group_descriptor`
- `group_membership_ids`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.
