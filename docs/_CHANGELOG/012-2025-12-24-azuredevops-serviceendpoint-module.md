# Filename: 012-2025-12-24-azuredevops-serviceendpoint-module.md

# 012. Azure DevOps Service Endpoints module

**Date:** 2025-12-24  
**Type:** Feature  
**Scope:** `modules/azuredevops_serviceendpoint/*`, `docs/_TASKS/*`  
**Tasks:** TASK-ADO-009

---

## Key Changes

- **New module:** added `modules/azuredevops_serviceendpoint` with Azure DevOps provider `1.12.2` for service connections.
- **Coverage:** implemented all service endpoint types plus permissions in a single area module.
- **Inputs:** organized per-endpoint input lists with consistent validation.
- **Examples:** added basic, complete, and secure configurations for common endpoints.
- **Tests:** updated fixtures, unit tests, and Terratest scaffolding for service endpoints.
