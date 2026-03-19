# TASK-052-02: Kubernetes Role module
# FileName: TASK-052-02_Kubernetes_Role_Module.md

**Priority:** High  
**Category:** New Module / Kubernetes RBAC  
**Estimated Effort:** Medium  
**Dependencies:** TASK-052, TASK-052-01  
**Status:** Planned

---

## Cel

Stworzyc `modules/kubernetes_role` dla namespace-scoped Kubernetes RBAC role.

---

## Resource Scope

**Primary:**
- `kubernetes_role_v1`

**Use cases:**
- read access do `pods`, `services`, `endpoints`
- `pods/portforward`
- least-privilege namespace-scoped permissions

---

## Scaffold

```bash
./scripts/create-new-module.sh \
  kubernetes_role \
  "Kubernetes Role" \
  KROLE \
  kubernetes-role \
  "Kubernetes Role Terraform module for managing a single namespace-scoped RBAC role"
```

---

## Deliverables

- Inputs:
  - `name`
  - `namespace`
  - `rules`
  - optional labels/annotations
- Walidacje:
  - co najmniej jedna rule
  - `verbs` niepuste
  - `resources` niepuste
- Examples:
  - read-only namespace role
  - port-forward role
  - mixed read + portforward role
- Tests:
  - rule rendering
  - validation pustych rules/verbs/resources

---

## Acceptance Criteria

- Modul odwzorowuje pojedynczy `Role`
- `pods/portforward` jest wspierane przez schema inputow
- Examples pokazuja dokładnie namespace read i port-forward use case
