# 060 - 2026-01-27 - PostgreSQL Flexible Server public network access toggle

## Summary

Relaxed network validation so `public_network_access_enabled = false` no longer
forces delegated subnet/private DNS inputs, enabling private endpoint scenarios
managed outside the module.

## Changes

- Updated network validations to allow disabling public access without delegated
  subnet/DNS while still requiring both values together when delegated
  networking is used (`modules/azurerm_postgresql_flexible_server/variables.tf`).
- Updated module docs and security guidance to describe the new private endpoint
  scenario (`modules/azurerm_postgresql_flexible_server/README.md`,
  `modules/azurerm_postgresql_flexible_server/docs/README.md`,
  `modules/azurerm_postgresql_flexible_server/SECURITY.md`).
- Added unit test for the private-endpoint-only scenario
  (`modules/azurerm_postgresql_flexible_server/tests/unit/defaults.tftest.hcl`).
- Added task tracking for the change (`docs/_TASKS/TASK-021_PostgreSQL_Flexible_Server_Public_Network_Access.md`,
  `docs/_TASKS/README.md`).

## Impact

- Public access can be disabled without delegated subnet/DNS inputs.
- Delegated subnet private access still requires both subnet and DNS IDs.
