# Application Insights Workbook Module Documentation

## Overview

The `azurerm_application_insights_workbook` module provisions a single Azure
Workbook resource. It is atomic and does not bundle networking, RBAC, or other
cross-resource glue.

## Managed Resources

- `azurerm_application_insights_workbook`

## In-Scope Workbook Capabilities

The module supports workbook-native properties exposed by the provider,
including `source_id`, `identity`, and `storage_container_id`.

## Out of Scope

The following must be handled outside the module:

- Application Insights components and Log Analytics workspaces
- RBAC/role assignments for workbook identities
- Private endpoints, firewall rules, or networking glue

## Usage Notes

- `name` must be a UUID (GUID) and known at plan time.
- `data_json` must be valid workbook JSON; use `jsonencode()` in Terraform.
- The module keeps a flat input surface for workbook fields to mirror the
  provider schema, while `identity` and `timeouts` remain object inputs because
  they map to nested provider blocks.
- When using `identity` + `source_id`, grant the identity least-privilege access
  to the source resource (Reader is a common baseline).
- `storage_container_id` is an optional workbook capability; this module only
  accepts the container resource ID and does not manage storage RBAC/networking.

## Additional References

- See `SECURITY.md` for security hardening guidance.
- See `IMPORT.md` for import instructions.
