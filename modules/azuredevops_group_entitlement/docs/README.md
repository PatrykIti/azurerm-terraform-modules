# Azure DevOps Group Entitlement Module Documentation

## Overview

This module manages a single Azure DevOps group entitlement.

## Managed Resources

- `azuredevops_group_entitlement`

## Usage Notes

- Use `git::https://...//modules/azuredevops_group_entitlement?ref=ADOGEvX.Y.Z` for module source.
- Input supports exactly one selector mode: `display_name` or `origin+origin_id`.
- Set explicit `group_entitlement.key` for stable downstream composition.

## Outputs (Highlights)

- `group_entitlement_id`
- `group_entitlement_descriptor`
- `group_entitlement_key`

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.
