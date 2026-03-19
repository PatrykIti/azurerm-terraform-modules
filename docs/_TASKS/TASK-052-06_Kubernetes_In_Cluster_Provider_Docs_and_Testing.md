# TASK-052-06: Kubernetes in-cluster provider docs and testing alignment
# FileName: TASK-052-06_Kubernetes_In_Cluster_Provider_Docs_and_Testing.md

**Priority:** High  
**Category:** Documentation / Testing / Provider Model  
**Estimated Effort:** Medium  
**Dependencies:** TASK-052-01, TASK-052-02, TASK-052-03, TASK-052-04, TASK-052-05  
**Status:** Planned

---

## Cel

Ujednolicic docs, examples i test harness dla modulow in-cluster Kubernetes,
tak aby byly zgodne z repo, ale jednoczesnie jasno opisywaly odmienny model
providera i apply lifecycle.

---

## Zakres

- README / docs/README dla kazdego nowego modulu
- IMPORT docs tam, gdzie ma to sens dla provider `kubernetes`
- pattern provider auth:
  - kubeconfig
  - host/token/cluster_ca_certificate
- testing pattern:
  - `terraform test` dla rendering/validation
  - Terratest / fixtures tylko tam, gdzie to ma sens i jest wykonalne
- guidance dla dwuetapowego apply po AKS creation

---

## Deliverables

- Spójna sekcja w docs wyjaśniająca:
  - dlaczego moduly maja prefix `azurerm_`, mimo ze uzywaja providera `kubernetes`
  - kiedy używać osobnego stanu/workspace
  - jak mapować Entra users/groups do Kubernetes subjects
- Updated repo indexes po wdrozeniu
- Changelog entry dla nowej fali modulow

---

## Acceptance Criteria

- README nowych modulow nie sugeruja, ze tworza sam AKS
- Docs jasno tlumacza dependency na live cluster
- Tests i fixtures nie ukrywaja tego ograniczenia
