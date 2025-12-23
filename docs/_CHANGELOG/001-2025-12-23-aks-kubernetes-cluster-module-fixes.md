# Filename: 001-2025-12-23-aks-kubernetes-cluster-module-fixes.md

# 001. AKS module fixes (identity/SP UX, node pools, docs, provider bump)

**Date:** 2025-12-23  
**Type:** Fix / Enhancement  
**Scope:** `modules/azurerm_kubernetes_cluster/`  
**Tasks:** TASK-001

---

## Key Changes

- **Terraform constraint:** kept `required_version = ">= 1.12.2"`.
- **Provider bump:** updated `hashicorp/azurerm` to `4.57.0` (module + examples; fixtures aligned to `>= 4.57.0`).
- **Identity vs service principal UX:** `identity` defaults to `null`; module applies **SystemAssigned** identity when neither `identity` nor `service_principal` is set; validation prevents setting both explicitly.
- **Node pools correctness:** added validations for `node_count` vs autoscaling; added `min_count <= max_count` checks; defaulted `node_count` to `min_count` when autoscaling enabled and `node_count` omitted (default + additional pools).
- **DNS validation:** fixed `dns_prefix` regex to allow 1-character prefixes and match the error message.
- **Docs & versioning:** README field fix (`auto_scaling_enabled`), VERSIONING matrix update, and small readability comments where logic is non-obvious.
- **Tests:** updated/added `terraform test` unit coverage for the new defaults and validations.

