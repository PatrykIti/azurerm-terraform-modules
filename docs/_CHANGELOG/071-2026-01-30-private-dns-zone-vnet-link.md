# 071 - 2026-01-30 - Private DNS Zone VNet Link module

## Summary

Introduced the `azurerm_private_dns_zone_virtual_network_link` module for linking Private DNS Zones to VNets.

## Changes

- Added `modules/azurerm_private_dns_zone_virtual_network_link` with registration and resolution policy support.
- Added examples: basic, complete, secure, and registration-enabled.
- Added documentation: README, SECURITY, and IMPORT guides.
- Added unit tests and Terratest fixtures.

## Impact

- New module only; no breaking changes.
