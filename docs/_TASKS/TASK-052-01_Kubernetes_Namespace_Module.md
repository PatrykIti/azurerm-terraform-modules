# TASK-052-01: Kubernetes Namespace module
# FileName: TASK-052-01_Kubernetes_Namespace_Module.md

**Priority:** High  
**Category:** New Module / Kubernetes In-Cluster  
**Estimated Effort:** Medium  
**Dependencies:** TASK-052  
**Status:** Done (2026-03-20)

---

## Cel

Stworzyc nowy modul `modules/kubernetes_namespace` do zarzadzania
jednym namespace'em w istniejacym klastrze Kubernetes.

---

## Resource Scope

**Primary:**
- `kubernetes_namespace_v1`

**Out of scope:**
- ResourceQuota
- LimitRange
- NetworkPolicy
- Role / RoleBinding

---

## Scaffold

Utworzyc przez:

```bash
./scripts/create-new-module.sh \
  kubernetes_namespace \
  "Kubernetes Namespace" \
  KNS \
  kubernetes-namespace \
  "Kubernetes namespace Terraform module for managing a single namespace in an existing cluster"
```

Po scaffoldzie:
- zamienic provider requirement z `azurerm` na `kubernetes`
- wywalic generiki niepasujace do in-cluster scope
- dopisac docs o wymaganym kubeconfig/provider auth

---

## Deliverables

- `main.tf` z `kubernetes_namespace_v1`
- `variables.tf` z inputami typu:
  - `name`
  - `labels`
  - `annotations`
  - `timeouts` jesli provider wspiera
- `outputs.tf` z `name`, `uid`, `resource_version`
- examples: `basic`, `complete`, `secure`
- unit tests: defaults, naming, outputs, validation

---

## Acceptance Criteria

- Modul zarzadza dokładnie jednym namespace'em
- README i docs/README jasno mowia, ze klaster musi istniec
- Examples sa runnable po skonfigurowaniu providera `kubernetes`
