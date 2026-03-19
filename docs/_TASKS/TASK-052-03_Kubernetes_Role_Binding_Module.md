# TASK-052-03: Kubernetes Role Binding module
# FileName: TASK-052-03_Kubernetes_Role_Binding_Module.md

**Priority:** High  
**Category:** New Module / Kubernetes RBAC  
**Estimated Effort:** Medium  
**Dependencies:** TASK-052, TASK-052-02  
**Status:** Planned

---

## Cel

Stworzyc `modules/kubernetes_role_binding` do przypisywania namespace-scoped
Role do subjects (`User`, `Group`, `ServiceAccount`).

---

## Resource Scope

**Primary:**
- `kubernetes_role_binding_v1`

---

## Scaffold

```bash
./scripts/create-new-module.sh \
  kubernetes_role_binding \
  "Kubernetes Role Binding" \
  KRB \
  kubernetes-role-binding \
  "Kubernetes RoleBinding Terraform module for binding a namespace-scoped role to subjects"
```

---

## Deliverables

- Inputs:
  - `name`
  - `namespace`
  - `role_ref`
  - `subjects`
- Walidacje:
  - co najmniej jeden subject
  - `subject.kind` tylko `User`, `Group`, `ServiceAccount`
  - `ServiceAccount` wymaga namespace, jesli provider schema tego wymaga
- Examples:
  - bind read role do dwoch Entra users
  - bind role do group
  - bind role do service account

---

## Acceptance Criteria

- Modul obsluguje wiele subjects
- Modul jest namespace-scoped i nie miesza ClusterRoleBinding semantics
- Example pokrywa user access dla namespace `intent-resolver`
