# 083 - 2026-01-30 - Windows Virtual Machine module

## Summary

Introduced the `azurerm_windows_virtual_machine` module for managing Azure
Windows Virtual Machines with managed data disks, extensions, and diagnostics.

## Changes

- Added `modules/azurerm_windows_virtual_machine` with full schema coverage.
- Added examples: basic, complete, secure, and feature-focused examples.
- Added module documentation: README, SECURITY, and IMPORT guides.
- Added unit tests and Terratest fixtures for core scenarios.

## Impact

- New module only; no breaking changes.
