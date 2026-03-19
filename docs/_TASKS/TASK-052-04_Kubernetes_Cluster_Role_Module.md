# TASK-052-04: Kubernetes Cluster Role module
# FileName: TASK-052-04_Kubernetes_Cluster_Role_Module.md

**Priority:** Medium  
**Category:** New Module / Kubernetes RBAC  
**Estimated Effort:** Medium  
**Dependencies:** TASK-052  
**Status:** Planned

---

## Cel

Stworzyc `modules/kubernetes_cluster_role` dla cluster-scoped RBAC role.

---

## Resource Scope

**Primary:**
- `kubernetes_cluster_role_v1`

**Use cases:**
- readonly cluster-wide discovery
- shared cluster-level permissions

---

## Scaffold

```bash
./scripts/create-new-module.sh \
  kubernetes_cluster_role \
  "Kubernetes Cluster Role" \
  KCR \
  kubernetes-cluster-role \
  "Kubernetes ClusterRole Terraform module for managing a single cluster-scoped RBAC role"
```

---

## Deliverables

- Inputs analogiczne do `kubernetes_role`, ale bez namespace
- Tests dla cluster-scoped rules
- Examples:
  - cluster-wide read role
  - discovery role

---

## Acceptance Criteria

- Modul odwzorowuje pojedynczy `ClusterRole`
- Nie wymaga namespace
- Docs jasno odrozniaja go od namespace-scoped `Role`
