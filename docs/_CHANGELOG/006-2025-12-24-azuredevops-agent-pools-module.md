# Filename: 006-2025-12-24-azuredevops-agent-pools-module.md

# 006. Azure DevOps Agent Pools module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_agent_pools/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-004

---

## Key Changes

- **New module:** added `modules/azuredevops_agent_pools` with Azure DevOps provider `1.12.2` and agent pool resources.
- **Queue mapping:** implemented agent queues with `agent_pool_key` or `agent_pool_id` selection and input validations.
- **Elastic pools:** added optional elastic pool support with capacity guards.
- **Examples:** refreshed basic, complete, and secure scenarios for Azure DevOps agent pools.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding for AZDO environments.
- **Docs:** updated task tracking and changelog entries.
