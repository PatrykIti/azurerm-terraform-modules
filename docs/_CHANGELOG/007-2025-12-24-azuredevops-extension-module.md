# Filename: 007-2025-12-24-azuredevops-extension-module.md

# 007. Azure DevOps Extension module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_extension/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-005

---

## Key Changes

- **New module:** added `modules/azuredevops_extension` for managing Marketplace extensions with Azure DevOps provider `1.12.2`.
- **Inputs/outputs:** implemented extension list input with validation and map output of extension IDs.
- **Examples:** added basic, complete, and secure examples focused on extension installation and allowlists.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding with AZDO extension env requirements.
- **Docs:** refreshed security guidance and task tracking.
