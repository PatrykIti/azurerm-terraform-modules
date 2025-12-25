# Filename: 019-2025-12-25-nsg-flow-logs-removal.md

# 019. NSG flow logs removal (Azure deprecation)

**Date:** 2025-12-25  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azurerm_network_security_group/`, `docs/`  
**Tasks:** TASK-006

---

## Key Changes

- **Flow logs removed:** dropped `azurerm_network_watcher_flow_log` support due to Azure retirement (no new NSG flow logs after 2025-07-30).
- **Inputs/outputs simplified:** removed `flow_log` variable and output from the module.
- **Examples + tests updated:** removed flow-logs example, cleaned secure/complete examples and observability fixtures to rely on diagnostic settings only.
- **Docs aligned:** updated README, SECURITY, and IMPORT guides to reflect diagnostics-only observability.

## Validation

- Not run (change removes resources and tests; re-run module validation/tests if needed).
