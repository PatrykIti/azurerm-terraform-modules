# TASK-005: AKS import documentation (Terraform import blocks)
# FileName: TASK-005_AKS_Import_Documentation.md

**Priority:** Medium  
**Category:** AKS / Documentation  
**Estimated Effort:** Small  
**Dependencies:** TASK-001, TASK-004 (resource addresses and diagnostics)  
**Status:** Done (2025-12-23)

---

## Cel

Dodac **dodatkowa dokumentacje** w module `azurerm_kubernetes_cluster` opisujaca **import istniejacego AKS** z uzyciem **Terraform import blocks** (`import {}`), tak aby mozna bylo przejac istniejacy klaster i dopasowac konfiguracje modulu.

---

## Kontekst

Terraform wspiera import przez **import blocks** (>= 1.5).  
Modul AKS zarzadza kilkoma typami zasobow i uzywa `for_each` dla dodatkowych node pooli, extensions oraz diagnostic settings.

Dokumentacja ma pokazac:
- jakie adresy zasobow w module trzeba importowac,
- jak wygladaja poprawne **ID** dla kazdego zasobu,
- jak przygotowac konfiguracje, zeby po imporcie `plan` byl clean.

---

## Zakres

1) Utworzyc dokumentacje modulowa:  
   `modules/azurerm_kubernetes_cluster/docs/IMPORT.md`.

2) Zaktualizowac `modules/azurerm_kubernetes_cluster/README.md` o link do nowej dokumentacji (np. sekcja **Importing existing AKS**).

3) Opisac import **wszystkich** zasobow zarzadzanych przez modul:
   - `azurerm_kubernetes_cluster.kubernetes_cluster`
   - `azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["<name>"]` (dodatkowe pule)
   - `azurerm_kubernetes_cluster_extension.kubernetes_cluster_extension["<name>"]`
   - `azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["<name>"]`

4) Wskazac co **nie** jest zarzadzane przez modul (np. RG/VNet/Subnet) i musi byc osobno zdefiniowane / zaimportowane.

---

## Wymagania / wymagane zrodla

- Terraform `import {}` (>= 1.5).  
- Modul wymaga `required_version` zgodnie z repo (`>= 1.12.2`).
- Dokumentacje Terraform (import blocks) i Azure resource IDs:  
  - `azurerm_kubernetes_cluster`
  - `azurerm_kubernetes_cluster_node_pool`
  - `azurerm_kubernetes_cluster_extension`
  - `azurerm_monitor_diagnostic_setting`

---

## Zawartosc doca (IMPORT.md)

### 1) Szybki TL;DR
- przygotuj konfiguracje modulu zgodna z istniejacym AKS,
- dodaj `import {}` dla wszystkich zasobow,
- uruchom `terraform plan` i dopasuj inputy,
- po imporcie usun bloki import (opcjonalnie).

### 2) Adresy zasobow w module
Podac dokladne adresy resource w module, np:

```hcl
import {
  to = module.aks.azurerm_kubernetes_cluster.kubernetes_cluster
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<aks_name>"
}
```

Uwagi:
- **default_node_pool** jest w resource `azurerm_kubernetes_cluster` (nie importuje sie osobno),
- dodatkowe node poole to osobne zasoby w `azurerm_kubernetes_cluster_node_pool`.

### 3) Mapowanie resource -> ID
Zamiescic tabele z przykladowymi ID:

| Resource (module address) | ID pattern |
|---|---|
| `azurerm_kubernetes_cluster.kubernetes_cluster` | `/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<aks>` |
| `azurerm_kubernetes_cluster_node_pool.kubernetes_cluster_node_pool["<pool>"]` | `/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<aks>/agentPools/<pool>` |
| `azurerm_kubernetes_cluster_extension.kubernetes_cluster_extension["<name>"]` | `/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<aks>/providers/Microsoft.KubernetesConfiguration/extensions/<name>` |
| `azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["<name>"]` | `<aks_id>|<diagnostic_setting_name>` |

### 4) Skrypty i komendy pomocnicze (Azure CLI)
Pokazac, jak pobrac ID/elementy:

- AKS ID: `az aks show -g <rg> -n <aks> --query id -o tsv`
- Node pool names: `az aks nodepool list -g <rg> --cluster-name <aks> --query "[].name" -o tsv`
- Extensions: `az k8s-extension list -g <rg> --cluster-name <aks> --cluster-type managedClusters --query "[].name" -o tsv`
- Diagnostic settings: `az monitor diagnostic-settings list --resource <aks_id> --query "[].name" -o tsv`

### 5) Przyklad kompletny (import blocks)
Wstawic pelny blok import dla klastra + kilku node pooli + diagnostics + extension.

### 6) Walidacja po imporcie
- `terraform plan` powinien zwrocic **no changes**,
- jesli sa zmiany: dopasowac inputy lub `ignore_changes` tam, gdzie potrzeba (udokumentowac ograniczenia).

---

## Kryteria akceptacji

- [ ] Dodany dokument `modules/azurerm_kubernetes_cluster/docs/IMPORT.md`.
- [ ] `modules/azurerm_kubernetes_cluster/README.md` zawiera link do dokumentu.
- [ ] W dokumencie opisano wszystkie zasoby zarzadzane przez modul (w tym for_each).
- [ ] Podane sa poprawne patterny ID i przyklady `import {}`.
- [ ] Jest sekcja walidacji po imporcie.

---

## Notatki

- Diagnostic settings sa opcjonalne i moga byc pomijane, jesli brak kategorii po filtracji; dokument powinien to wyjasniac.
- Dodatkowe node poole i extensions musza miec nazwy zgodne z istniejacymi zasobami (for_each po `name`).
