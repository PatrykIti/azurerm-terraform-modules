# TASK-004: AKS diagnostic settings (multi-stream, area-based)
# FileName: TASK-004_AKS_Diagnostic_Settings.md

**Priority:** 🔴 High  
**Category:** AKS / Observability  
**Estimated Effort:** Medium  
**Dependencies:** —  
**Status:** ✅ **Done** (2025-12-23)

---

## Cel

Dodac obsluge **Azure Monitor Diagnostic Settings** dla `azurerm_kubernetes_cluster` w module AKS:
- **multi-stream** (wiele ustawien diagnostycznych dla tego samego AKS),
- **jedna zmienna + jeden resource** w HCL,
- **for_each po name**,
- **wszystkie obszary** (kategorie logow/metryk pobierane dynamicznie).

---

## Kontekst

Diagnostic Settings w AKS dotycza **control plane / API plane** i kategorii zwracanych przez `azurerm_monitor_diagnostic_categories`.  
To **nie** jest to samo co OMS / Container Insights (logi z podow i node'ow).

AKS **nie ma** sub-resource ID dla diagnostyki (w przeciwienstwie do Storage Account).  
Wszystkie ustawienia trafiaja do **tego samego** `target_resource_id`:
`azurerm_kubernetes_cluster.kubernetes_cluster.id`.

---

## Zakres

1) Dodanie jednej zmiennej `diagnostic_settings` (list(object), default `[]`).  
2) Jeden resource `azurerm_monitor_diagnostic_setting` z `for_each` po `name`.  
3) Dynamiczne logi/metryki na podstawie:
   - `areas` (obszary) **lub**
   - jawnie przekazanych `log_categories` / `metric_categories`.  
4) Wsparcie wszystkich 3 destynacji:
   - Log Analytics
   - Storage Account
   - Event Hub
5) Dokumentacja i przyklad uzycia w module.

---

## Specyfikacja zmiennej

### Zmienna wejsciowa

```hcl
variable "diagnostic_settings" {
  type = list(object({
    name                           = string
    areas                          = optional(list(string))
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))
  default = []
}
```

### Zasady i walidacje

- **default = []** -> nie tworzy zadnych diagnostic settings.  
- **for_each po `name`** -> nazwa musi byc unikalna.  
- **Wymagane minimum**: co najmniej jedna destynacja:
  `log_analytics_workspace_id` albo `storage_account_id` albo `eventhub_authorization_rule_id`.  
- **EventHub**: jesli ustawione `eventhub_authorization_rule_id`, to wymagane jest `eventhub_name`.  
- **Areas vs categories**:
  - jesli `log_categories` / `metric_categories` sa podane -> **maja priorytet**,
  - jesli nie -> oblicz na podstawie `areas`,
  - jesli brak `areas` -> domyslnie `areas = ["all"]`.
- **Brak kategorii po filtracji**:
  - ustawienie jest **pomijane** (resource nie powstaje),
  - zapisujemy informacje o pominietych wpisach (np. `local.diagnostic_settings_skipped`),
  - jesli mozliwe, dodac `output diagnostic_settings_skipped` z lista pominietych konfiguracji.
- **Limit Azure**: max 5 diagnostic settings na resource (walidacja `length(var.diagnostic_settings) <= 5`).

---

## Obszary (areas) i mapowanie kategorii

### Zrodlo prawdy

```
data "azurerm_monitor_diagnostic_categories" "aks" {
  resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
}
```

### Dostepne obszary (do wyboru w `areas`)

- `all` -> wszystkie logi + metryki
- `api_plane` -> `kube-apiserver`
- `audit` -> `kube-audit`, `kube-audit-admin`
- `controller_manager` -> `kube-controller-manager`
- `scheduler` -> `kube-scheduler`
- `autoscaler` -> `cluster-autoscaler`
- `guard` -> `guard`
- `cloud_controller` -> `cloud-controller-manager` (jesli dostepne)
- `csi` -> wszystkie kategorie z prefixem `csi-`
- `metrics` -> `AllMetrics` (jesli dostepne)

### Mapping (przykladowy, filtrowany do realnie dostepnych kategorii)

```hcl
locals {
  # Wszystkie dostepne kategorie logow i metryk z Azure (dynamiczne per region/wersja)
  aks_diag_log_categories    = data.azurerm_monitor_diagnostic_categories.aks.log_category_types
  aks_diag_metric_categories = data.azurerm_monitor_diagnostic_categories.aks.metrics

  # Bazowe mapowanie obszar -> kategorie (podstawa do filtrowania)
  aks_area_log_map_raw = {
    api_plane          = ["kube-apiserver"]
    audit              = ["kube-audit", "kube-audit-admin"]
    controller_manager = ["kube-controller-manager"]
    scheduler          = ["kube-scheduler"]
    autoscaler         = ["cluster-autoscaler"]
    guard              = ["guard"]
    cloud_controller   = ["cloud-controller-manager"]
  }

  # Mapowanie obszar -> kategorie logow, przefiltrowane tylko do faktycznie dostepnych
  aks_area_log_map = merge(
    { all = local.aks_diag_log_categories },
    { csi = [for c in local.aks_diag_log_categories : c if startswith(c, "csi-")] },
    { for k, v in local.aks_area_log_map_raw : k => [for c in v : c if contains(local.aks_diag_log_categories, c)] }
  )

  # Mapowanie obszar -> kategorie metryk (wszystkie metryki to zwykle AllMetrics)
  aks_area_metric_map = {
    all     = local.aks_diag_metric_categories
    metrics = local.aks_diag_metric_categories
  }
}
```

**Wazne:** lista kategorii moze sie roznic per region/wersja, dlatego **zawsze filtrujemy** po `data.azurerm_monitor_diagnostic_categories`.

---

## Resource (jedna definicja)

```hcl
locals {
  # Wejscie po rozwinieciu areas -> log/metric categories (bez filtrowania pustych)
  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = coalesce(ds.areas, ["all"])
      log_categories = ds.log_categories != null
        ? ds.log_categories
        : distinct(flatten([for area in coalesce(ds.areas, ["all"]) : lookup(local.aks_area_log_map, area, [])]))
      metric_categories = ds.metric_categories != null
        ? ds.metric_categories
        : distinct(flatten([for area in coalesce(ds.areas, ["all"]) : lookup(local.aks_area_metric_map, area, [])]))
    })
  ]

  # Tylko konfiguracje, ktore po filtracji maja cokolwiek do wyslania
  diagnostic_settings_effective = [
    for ds in local.diagnostic_settings_resolved : ds
    if length(ds.log_categories) + length(ds.metric_categories) > 0
  ]

  # Konfiguracje pominiete (zero kategorii po filtracji)
  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name              = ds.name
      areas             = ds.areas
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each           = { for ds in local.diagnostic_settings_effective : ds.name => ds }
  name               = each.value.name
  target_resource_id = azurerm_kubernetes_cluster.kubernetes_cluster.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}
```

**Uwagi:**
- Resource name: **`monitor_diagnostic_settings`** (bez prefiksu azurerm).
- Jezeli po filtracji kategorie sa puste (log + metric) -> **pominiecie** + lista w `local.diagnostic_settings_skipped`.
- Jesli mozliwe, dodac output informacyjny (np. `diagnostic_settings_skipped`).

### Output (informacyjny)

```hcl
output "diagnostic_settings_skipped" {
  description = "Konfiguracje diagnostic settings pominiete z powodu braku kategorii po filtracji."
  value       = local.diagnostic_settings_skipped
}
```

---

## Dokumentacja

Do zaktualizowania:
- `modules/azurerm_kubernetes_cluster/README.md`  
  - opis nowej zmiennej `diagnostic_settings`  
  - lista obszarow (`areas`) i zasady wyboru kategorii  
  - ostrzezenie o limicie 5 diagnostic settings na resource  
  - przyklad multi-stream (np. LA + EventHub)

Opcjonalnie:
- `docs/MODULE_GUIDE/05-documentation.md` lub `docs/WORKFLOWS.md` (jesli chcemy ogolny wzorzec dla innych modulow).

---

## Kroki implementacyjne (checklista)

1) **variables.tf**
   - Dodac `variable "diagnostic_settings"` z walidacjami:
     - `length(var.diagnostic_settings) <= 5`
     - wymagana destynacja (LA/Storage/EventHub)
     - `eventhub_authorization_rule_id` -> wymaga `eventhub_name`
     - walidacja `areas` (tylko dozwolone wartosci)

2) **locals.tf (lub nowy diagnostics.tf)**
   - `data.azurerm_monitor_diagnostic_categories.aks`
   - `local.aks_area_log_map` + `local.aks_area_metric_map`
   - `local.diagnostic_settings_effective`

3) **main.tf / diagnostics.tf**
   - `azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings` z `for_each`
   - dynamiczne bloki `enabled_log` i `metric`

4) **README / Docs**
   - Dodac opis zmiennej i przyklady konfiguracji
   - Uwzglednic “areas” i limit 5

5) **Testy**
   - Ustawic fixture / unit test (np. `tests/unit/diagnostic_settings.tftest.hcl`)
   - Scenariusz: `diagnostic_settings=[]` -> brak resource
   - Scenariusz: 1 ustawienie z `areas=["all"]` i LA -> resource istnieje
   - Scenariusz: obszar nieobslugiwany (brak kategorii) -> brak resource + wpis w `diagnostic_settings_skipped`

---

## Kryteria akceptacji

- `diagnostic_settings=[]` -> brak zasobow diagnostic settings.  
- `diagnostic_settings` z 1+ wpisami -> powstaje odpowiadajaca liczba resources.  
- `areas=["all"]` obejmuje wszystkie dostepne kategorie logow i metryk.  
- Walidacje blokujace bledne konfiguracje (brak destynacji, brak eventhub_name).  
- Ustawienia bez zadnych kategorii po filtracji sa pominiete i raportowane.  
- README jasno opisuje sposob uzycia + ograniczenia.

---

## Notatki i ryzyka

- Azure limit: **max 5 diagnostic settings** na jeden AKS resource.  
- Kategorie diagnostyczne sa dynamiczne (region/wersja) -> filtracja jest obowiazkowa.  
- “Pods” / workload logs to osobny strumien (Container Insights / AMA), poza zakresem tego taska.
