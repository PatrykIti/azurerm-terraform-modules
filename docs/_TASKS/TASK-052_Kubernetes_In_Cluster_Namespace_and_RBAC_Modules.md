# TASK-052: Kubernetes in-cluster namespace and RBAC modules
# FileName: TASK-052_Kubernetes_In_Cluster_Namespace_and_RBAC_Modules.md

**Priority:** High  
**Category:** New Modules / Kubernetes In-Cluster Access  
**Estimated Effort:** Large  
**Dependencies:** TASK-003 (module scaffold generator baseline), existing `azurerm_kubernetes_secrets` patterns  
**Status:** Done (2026-03-20)

---

## Cel

Dodac do repo zestaw atomowych modulow do zarzadzania obiektami **wewnatrz**
klastra Kubernetes z poziomu Terraform, przy uzyciu providerow
`kubernetes` / opcjonalnie `helm` tam, gdzie ma to sens.

Docelowy zestaw modulow tej fali:

- `modules/kubernetes_namespace`
- `modules/kubernetes_role`
- `modules/kubernetes_role_binding`
- `modules/kubernetes_cluster_role`
- `modules/kubernetes_cluster_role_binding`

Te moduly maja pokryc namespace-scoped i cluster-scoped RBAC potrzebny do:

- tworzenia namespace'ow
- tworzenia Role / ClusterRole
- przypinania uprawnien do `User`, `Group`, `ServiceAccount`
- namespace-level access typu read pods/services/endpoints
- namespace-level access do `pods/portforward`

---

## Scope Boundary

### In scope

- Namespace lifecycle
- Namespace-scoped RBAC
- Cluster-scoped RBAC
- Subjects: `User`, `Group`, `ServiceAccount`
- `kubernetes_manifest` tylko jesli jest absolutnie wymagany dla stabilnego
  odwzorowania resource schema; preferowane natywne `kubernetes_*_v1`

### Out of scope

- Generic workload modules dla `Pod`, `Deployment`, `StatefulSet`, `DaemonSet`
- Helm chart wrappers niezwiązane z RBAC
- AKS cluster provisioning (`azurerm_kubernetes_cluster`)
- Azure RBAC role definitions / Azure role assignments
- Flux/GitOps deployment model

### Decision note

Nie tworzymy w tej fali modułu typu `azurerm_kubernetes_pod`, bo to nie jest
atomowy building block dla access-control scope. Dla workloadow preferowane beda
osobne moduly `Deployment` / `StatefulSet` / `helm_release`, jesli kiedys
wejda do backlogu.

---

## Naming and Scaffold Rules

Repo naming convention zostaje rozszerzona o:

- `kubernetes_<resource>`

dla modulow, ktorych primary scope jest obiektem in-cluster zarzadzanym przez
provider `kubernetes`.

Nazwy katalogow w tej fali:

- `kubernetes_namespace`
- `kubernetes_role`
- `kubernetes_role_binding`
- `kubernetes_cluster_role`
- `kubernetes_cluster_role_binding`

Kazdy modul ma byc scaffoldowany przez `scripts/create-new-module.sh`, a dopiero
potem dostosowany z template generatora do rzeczywistego providera `kubernetes`.

---

## Shared Implementation Rules

1) **Atomic scope**  
   Jeden primary resource per modul:
   - namespace
   - role
   - role binding
   - cluster role
   - cluster role binding

2) **Provider ownership**  
   Te moduly zarzadzaja obiektami in-cluster, nie zasobami Azure Resource
   Manager. To musi byc jawnie opisane w README i docs/README.

3) **Apply model**  
   Modul AKS i moduly in-cluster nie powinny byc traktowane jako jeden,
   nierozdzielny apply. Trzeba jasno opisac, ze:
   - klaster musi juz istniec
   - provider `kubernetes` musi miec dzialajacy kubeconfig / host+token
   - dla swiezo tworzonego AKS preferowany jest osobny stan albo 2-step apply

4) **Inputs and validation**  
   - walidacje unikalnosci nazw
   - walidacje enumow dla `subject.kind`
   - cross-field validation dla namespace vs cluster scope
   - brak sekretow / tokenow jako inputow do obiektow RBAC

5) **Pattern source**  
   Wzorcem dla in-cluster usage jest `modules/azurerm_kubernetes_secrets/`,
   ale bez kopiowania jego nienatywnego scope. On pokazuje, jak repo obsluguje
   provider `kubernetes` i dwustopniowy model apply.

---

## Physical Task Files

- `docs/_TASKS/TASK-052-01_Kubernetes_Namespace_Module.md`
- `docs/_TASKS/TASK-052-02_Kubernetes_Role_Module.md`
- `docs/_TASKS/TASK-052-03_Kubernetes_Role_Binding_Module.md`
- `docs/_TASKS/TASK-052-04_Kubernetes_Cluster_Role_Module.md`
- `docs/_TASKS/TASK-052-05_Kubernetes_Cluster_Role_Binding_Module.md`
- `docs/_TASKS/TASK-052-06_Kubernetes_In_Cluster_Provider_Docs_and_Testing.md`

---

## Acceptance Criteria

- Wszystkie 5 modulow istnieje i przechodzi repo-level checks adekwatne do scope.
- Kazdy modul ma pelny scaffold repo + README/docs/examples/tests.
- Zrodla prawdy sa spojne: `module.json`, README, docs/README, tests.
- Moduly sa atomic i nie mieszaja Azure RBAC z Kubernetes RBAC.
- Dokumentacja jasno opisuje model provider `kubernetes` oraz wymog istniejacego klastra.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md`
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/<new-entry>.md`
- `modules/README.md`
- `README.md`

---

## Completion Notes

- Added:
  - `modules/kubernetes_namespace`
  - `modules/kubernetes_role`
  - `modules/kubernetes_role_binding`
  - `modules/kubernetes_cluster_role`
  - `modules/kubernetes_cluster_role_binding`
- All five modules now use the `kubernetes` provider with repo-standard
  scaffold, examples, docs, unit tests, fixtures, and Terratest harness.
- Repo naming/documentation tooling was extended so `kubernetes_*` is handled as
  a first-class module family in guides, generators, and README indexes.
