# 061 - 2026-01-27 - AKS monitoring add-on AMPLS patch via AzAPI

## Summary

Added an AzAPI-based patch path to configure AKS OMS/Container Insights with
Azure Monitor Private Link Scope (AMPLS) and curated data collection profiles,
plus expanded unit and integration test coverage.

## Changes

- Added AzAPI patch resource that injects AMPLS settings and
  `dataCollectionSettings` for OMS agent when `oms_agent.ampls_settings.id` is
  provided (`modules/azurerm_kubernetes_cluster/azapi_patch.tf`).
- Extended `oms_agent` inputs with `ampls_settings.id` (and optional `enabled`)
  plus `collection_profile` (default `basic`) and added validations
  (`modules/azurerm_kubernetes_cluster/variables.tf`).
- Added AzAPI provider pin for the AKS module (`modules/azurerm_kubernetes_cluster/versions.tf`).
- Expanded unit tests with AzAPI mocks and OMS agent patch assertions
  (`modules/azurerm_kubernetes_cluster/tests/unit/*.tftest.hcl`).
- Updated complete fixture to provision AMPLS + scoped service and verify add-on
  config in integration tests
  (`modules/azurerm_kubernetes_cluster/tests/fixtures/complete/*`,
  `modules/azurerm_kubernetes_cluster/tests/kubernetes_cluster_test.go`).
- Documented the task for the change
  (`docs/_TASKS/TASK-020_AKS_Monitoring_Addon_AMPLS_AzAPI.md`,
  `docs/_TASKS/README.md`).

## Impact

- Container Insights can be wired to AMPLS automatically when
  `oms_agent.ampls_settings.id` is set, without requiring custom JSON input.
- Data collection defaults to the `basic` profile, with an `advanced` option
  for expanded streams.
- Tests now cover AMPLS configuration, AzAPI patching behavior, and data
  collection stream expectations.
