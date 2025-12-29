# Filename: 025-2025-12-25-azuredevops-agent-pools-refactor.md

# 025. Azure DevOps Agent Pools module refactor

**Date:** 2025-12-25  
**Type:** Breaking Change / Maintenance  
**Scope:** `modules/azuredevops_agent_pools/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-015

---

## Key Changes

- **Inputs flattened:** replaced `agent_pools` map with flat pool inputs (`name`, `auto_provision`, `auto_update`, `pool_type`).
- **Queues aligned:** switched to `agent_queues` list with stable keys, proper name/agent_pool_id rules, and module pool defaults.
- **Elastic pool model:** replaced list with single optional `elastic_pool` object including full provider parameters.
- **Outputs updated:** replaced pool/elastic maps with `agent_pool_id` and `elastic_pool_id`.
- **Docs & tests:** refreshed examples, fixtures, unit tests, and import guidance for the new interface.
