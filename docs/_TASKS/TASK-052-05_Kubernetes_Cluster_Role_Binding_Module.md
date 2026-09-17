# TASK-052-05: Kubernetes Cluster Role Binding module
# FileName: TASK-052-05_Kubernetes_Cluster_Role_Binding_Module.md

**Priority:** Medium  
**Category:** New Module / Kubernetes RBAC  
**Estimated Effort:** Medium  
**Dependencies:** TASK-052, TASK-052-04  
**Status:** Done (2026-03-20)

---

## Cel

Stworzyc `modules/kubernetes_cluster_role_binding` do przypisywania
`ClusterRole` do subjects na poziomie calego klastra.

---

## Resource Scope

**Primary:**
- `kubernetes_cluster_role_binding_v1`

---

## Scaffold

```bash
./scripts/create-new-module.sh \
  kubernetes_cluster_role_binding \
  "Kubernetes Cluster Role Binding" \
  KCRB \
  kubernetes-cluster-role-binding \
  "Kubernetes ClusterRoleBinding Terraform module for binding a cluster role to subjects"
```

---

## Deliverables

- Inputs:
  - `name`
  - `role_ref`
  - `subjects`
- Walidacje:
  - co najmniej jeden subject
  - poprawne kinds
- Examples:
  - bind cluster role do group
  - bind cluster role do service account

---

## Acceptance Criteria

- Modul odwzorowuje pojedynczy `ClusterRoleBinding`
- Nie ma inputu `namespace`
- Docs i tests wyraznie rozrozniaja go od `RoleBinding`
