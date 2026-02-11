# 070 - 2026-01-30 - Private DNS Zone module

## Summary

Introduced the `azurerm_private_dns_zone` module with full example and test coverage.

## Changes

- Added `modules/azurerm_private_dns_zone` with SOA record and timeouts support.
- Added examples: basic, complete, secure, and soa-record.
- Added documentation: README, SECURITY, and IMPORT guides.
- Added unit tests and Terratest fixtures.

## Impact

- New module only; no breaking changes.
