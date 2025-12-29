# Filename: 018-2025-12-24-nsg-observability-and-docs.md

# 018. NSG observability + docs alignment

**Date:** 2025-12-24  
**Type:** Feature / Enhancement  
**Scope:** `modules/azurerm_network_security_group/`, `docs/`  
**Tasks:** TASK-006

---

## Key Changes

- **Observability support:** added diagnostic settings (multi-destination) and Network Watcher flow logs with traffic analytics.
- **Examples expanded and aligned:** updated `basic`, `complete`, `secure`, added `diagnostic-settings` + `flow-logs`, and switched example `source` to `../..` for local testing.
- **Flow logs guarded:** added `enable_flow_log` and Network Watcher data sources to avoid subscription limits and retired flow log creation.
- **Event Hub diagnostics fix:** use namespace authorization rule ID and `namespace_id` for event hub resources.
- **Docs alignment:** clarified AKS as baseline in repo guides and added NSG import and security documentation.
- **Tests updated:** new unit tests for diagnostics/flow logs, new observability fixture, and renamed fixtures to `basic`/`secure`.

## Validation

- `modules/azurerm_network_security_group`: `terraform init -backend=false`, `terraform validate`, `terraform test -test-directory=tests/unit` (33 passed)
- `examples/basic`: `terraform init`, `terraform apply -auto-approve`, `terraform destroy -auto-approve`
- `examples/complete`: `terraform init`, `terraform apply -auto-approve`, `terraform destroy -auto-approve` (`enable_flow_log=false`, `NetworkWatcherRG/NetworkWatcher_westeurope`)
- `examples/secure`: `terraform init`, `terraform apply -auto-approve`, `terraform destroy -auto-approve` (`enable_flow_log=false`, `NetworkWatcherRG/NetworkWatcher_westeurope`)
- `examples/diagnostic-settings`: `terraform init`, `terraform apply -auto-approve`, `terraform destroy -auto-approve`
- `examples/flow-logs`: `terraform init`, `terraform apply -auto-approve`, `terraform destroy -auto-approve` (`enable_flow_log=false`, flow log creation retired after 2025-06-30)

## Follow-up

- Flow log support was removed later due to Azure deprecation (see `docs/_CHANGELOG/019-2025-12-25-nsg-flow-logs-removal.md`).
