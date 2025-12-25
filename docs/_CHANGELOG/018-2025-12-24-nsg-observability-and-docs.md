# Filename: 018-2025-12-24-nsg-observability-and-docs.md

# 018. NSG observability + docs alignment

**Date:** 2025-12-24  
**Type:** Feature / Enhancement  
**Scope:** `modules/azurerm_network_security_group/`, `docs/`  
**Tasks:** TASK-006

---

## Key Changes

- **Observability support:** added diagnostic settings (multi-destination) and Network Watcher flow logs with traffic analytics.
- **Examples expanded:** updated `basic`, `complete`, `secure` and added `diagnostic-settings` + `flow-logs`.
- **Docs alignment:** clarified AKS as baseline in repo guides and added NSG import and security documentation.
- **Tests updated:** new unit tests for diagnostics/flow logs, new observability fixture, and renamed fixtures to `basic`/`secure`.

## Validation

- Pending (to be filled after running init/validate, unit tests, and example applies).
