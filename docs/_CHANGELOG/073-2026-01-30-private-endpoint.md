# 072 - 2026-01-30 - Private Endpoint module

## Summary

Introduced the `azurerm_private_endpoint` module for managing Azure Private Endpoints with optional DNS zone group attachment.

## Changes

- Added `modules/azurerm_private_endpoint` with full provider schema coverage.
- Added examples: basic, complete, secure.
- Added module documentation: README, SECURITY, and IMPORT guides.
- Added unit tests and Terratest fixtures for DNS zone group and IP configuration scenarios.

## Impact

- New module only; no breaking changes.
