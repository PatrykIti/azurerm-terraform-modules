# TASK-018: Diagnostic settings alignment (AKS + Storage)
# FileName: TASK-018_Diagnostic_Settings_Alignment.md

**Priority:** Medium  
**Category:** Module Alignment / Observability  
**Estimated Effort:** Medium  
**Dependencies:** TASK-004, TASK-008, TASK-016  
**Status:** To Do

---

## Cel

Ujednolicic `diagnostic settings` w:
- `modules/azurerm_kubernetes_cluster`
- `modules/azurerm_storage_account`

Wzor: `modules/azurerm_postgresql_flexible_server`.
Cel to spojnosc UX, identyczne walidacje i identyczna logika `for_each`
oraz brak mapowania/automatyzacji kategorii przez data sources.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_monitor_diagnostic_setting`

**Out-of-scope:**
- `azurerm_monitor_diagnostic_categories` (usunac uzycie)
- automatyczne mapowanie `areas` -> categories (usunac)

---

## Zalozenia i decyzje

1) **Jedna struktura inputu (list(object))**  
   Dla AKS ten sam ksztalt obiektu jak w `azurerm_postgresql_flexible_server`.
   Uzytkownik podaje jawne `log_categories` i/lub `metric_categories`.

2) **Storage account - scope po stronie modulu**  
   Dla storage account scope musi byc wyliczany w module.  
   Uzytkownik podaje dane per-scope (storage/blob/queue/file/table/dfs),
   a modul mapuje je na `target_resource_id`.
   Brakujace scope traktujemy jako puste listy.

3) **Nazwa zmiennej**  
   Docelowo `monitoring` (jak w PGFS).  
   Zmiana jest breaking change - w docs i w tasku trzeba to jasno opisac.
   Dla storage account pozostaje per-scope struktura wejscia (deviation).

4) **`for_each` po `name`**  
   Kluczem ma byc `name`; wymagamy globalnej unikalnosci (przekroj wszystkich
   scope w storage). Wpisy bez kategorii sa pomijane i raportowane w output.

5) **Limit liczby settings**  
   Zachowac limit 5 wpisow na target resource (Azure limit).
   Dla storage account limit per `scope`.

---

## Zakres i deliverables

### TASK-018-1: Discovery / constraints

**Cel:** Potwierdzic limity i dozwolone wartosci dla diagnostics w azurerm 4.57.0.

**Do zrobienia:**
- Potwierdzic limit 5 settings per resource (AKS i storage scopes).
- Potwierdzic dozwolone wartosci `log_analytics_destination_type`.
- Spisac wymagania dla `eventhub_name` i destination IDs.

---

### TASK-018-2: AKS - schema + diagnostics.tf

**Cel:** Ujednolicic AKS z PGFS.

**Do zrobienia:**
- Zamienic `variable "diagnostic_settings"` na `variable "monitoring"` z tym samym
  schema jak w PGFS.
- Usunac `areas` i data sources `azurerm_monitor_diagnostic_categories`.
- Walidacje identyczne jak w PGFS (unique name, destinations, eventhub name).
- `diagnostics.tf`: `for_each` po `name`, filter gdy brak kategorii.
- Output `diagnostic_settings_skipped` jak w PGFS.

**Schema (AKS):**
```hcl
variable "monitoring" {
  type = list(object({
    name                           = string
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

---

### TASK-018-3: Storage Account - schema + diagnostics.tf

**Cel:** Ujednolicic storage account z PGFS, ale z obsluga scope po stronie modulu.

**Do zrobienia:**
- Zamienic `variable "diagnostic_settings"` na `variable "monitoring"`.
- Input per-scope (storage_account/blob/queue/file/table/dfs) zamiast
  jawnego `scope` w kazdym wpisie.
- Usunac `areas` i data sources `azurerm_monitor_diagnostic_categories`.
- Walidacje identyczne jak w PGFS + limit 5 per scope.
- Nazwy `name` musza byc unikalne globalnie (przekroj wszystkich scope).
- Brakujace scope maja byc traktowane jako puste listy (bez tworzenia zasobow).
- `diagnostics.tf`: mapowanie scope -> `target_resource_id`, `for_each` po `name`.
- Output `diagnostic_settings_skipped` analogiczny do PGFS (z `scope`).

**Schema (Storage):**
```hcl
variable "monitoring" {
  type = object({
    storage_account = optional(list(object({
      name                           = string
      log_categories                 = optional(list(string))
      metric_categories              = optional(list(string))
      log_analytics_workspace_id     = optional(string)
      log_analytics_destination_type = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
    })), [])
    blob = optional(list(object({
      name                           = string
      log_categories                 = optional(list(string))
      metric_categories              = optional(list(string))
      log_analytics_workspace_id     = optional(string)
      log_analytics_destination_type = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
    })), [])
    queue = optional(list(object({
      name                           = string
      log_categories                 = optional(list(string))
      metric_categories              = optional(list(string))
      log_analytics_workspace_id     = optional(string)
      log_analytics_destination_type = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
    })), [])
    file = optional(list(object({
      name                           = string
      log_categories                 = optional(list(string))
      metric_categories              = optional(list(string))
      log_analytics_workspace_id     = optional(string)
      log_analytics_destination_type = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
    })), [])
    table = optional(list(object({
      name                           = string
      log_categories                 = optional(list(string))
      metric_categories              = optional(list(string))
      log_analytics_workspace_id     = optional(string)
      log_analytics_destination_type = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
    })), [])
    dfs = optional(list(object({
      name                           = string
      log_categories                 = optional(list(string))
      metric_categories              = optional(list(string))
      log_analytics_workspace_id     = optional(string)
      log_analytics_destination_type = optional(string)
      storage_account_id             = optional(string)
      eventhub_authorization_rule_id = optional(string)
      eventhub_name                  = optional(string)
    })), [])
  })
  default = {}
}
```

---

### TASK-018-4: Examples + fixtures + tests

**Cel:** Zgodnosc examples i testow z nowym UX.

**Do zrobienia:**
- AKS: zaktualizowac `examples/diagnostic-settings` i wszystkie fixtures/testy,
  ktore uzywaly `diagnostic_settings` lub `areas`.
- Storage: zaktualizowac examples uzywajace diagnostic settings (scope + categories).
- Unit tests: zaktualizowac walidacje i testy `diagnostic_settings_skipped`.

---

### TASK-018-5: Dokumentacja i automation

**Cel:** Aktualne docs zgodne z nowym UX (jak w TASK-017).

**Do zrobienia:**
- `modules/azurerm_kubernetes_cluster/README.md` (terraform-docs).
- `modules/azurerm_kubernetes_cluster/examples/*/README.md` (tam gdzie diagnostics).
- `modules/azurerm_storage_account/README.md` (terraform-docs).
- `modules/azurerm_storage_account/docs/README.md`.
- `modules/azurerm_storage_account/examples/README.md` + per-example READMEs.
- Usunac/naprawic referencje do `diagnostic_settings` i `areas`.
- Regeneracja docs: `generate-docs.sh` + `scripts/update-examples-list.sh`.

---

### TASK-018-6: Release i versioning

**Cel:** Spiac zmiane jako breaking change.

**Do zrobienia:**
- Zaktualizowac wersje modulow przez `./scripts/update-module-version.sh`
  (zgodnie z SemVer).
- Upewnic sie, ze `CHANGELOG.md` i `VERSIONING.md` opisuje breaking change
  (rename inputu i usuniecie `areas`).
