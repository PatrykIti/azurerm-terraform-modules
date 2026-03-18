# 101 - 2026-03-18 - Managed Redis module

## Summary

Added a new `modules/azurerm_managed_redis` module with Managed Redis support,
optional geo-replication membership management, diagnostic settings, examples,
and test coverage aligned to repo standards.

## Changes

- Added `modules/azurerm_managed_redis` with full `azurerm_managed_redis`
  coverage for SKU, HA, public network access, default database, identity,
  CMK, timeouts, and tags.
- Added optional `azurerm_managed_redis_geo_replication` support while keeping
  additional Managed Redis instances outside the module boundary.
- Added inline diagnostic settings targeting the default database resource.
- Added basic, complete, secure, diagnostic-settings, customer-managed-key, and
  geo-replication examples.
- Added `terraform test` coverage and Terratest scaffolding/fixtures for core
  scenarios.
- Added module documentation covering scope, import flow, and security notes.

## Impact

- New AzureRM module available in development: `azurerm_managed_redis`.
- Legacy Redis Enterprise resources remain out of scope for this module.
