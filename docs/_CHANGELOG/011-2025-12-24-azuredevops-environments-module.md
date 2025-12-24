# Filename: 011-2025-12-24-azuredevops-environments-module.md

# 011. Azure DevOps Environments module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_environments/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-008

---

## Key Changes

- **New module:** added `modules/azuredevops_environments` with Azure DevOps provider `1.12.2` for environments.
- **Resources:** implemented environment and Kubernetes resource management with keyed inputs.
- **Checks:** added approval, branch control, business hours, exclusive lock, required template, and REST API checks.
- **Examples:** added basic, complete, and secure scenarios with environment checks.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding for environments.
