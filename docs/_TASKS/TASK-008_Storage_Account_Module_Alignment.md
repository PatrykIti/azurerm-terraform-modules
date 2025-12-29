# TASK-008: Storage Account module alignment (docs + examples + tests)
# FileName: TASK-008_Storage_Account_Module_Alignment.md

**Priority:** 🔴 High  
**Category:** Module Cleanup / Documentation  
**Estimated Effort:** Large  
**Dependencies:** —  
**Status:** ✅ **Done** (2025-12-25)

---

## Cel

Dostosowac modul `modules/azurerm_storage_account` do wytycznych:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

AKS jest wzorcem, ale storage account ma inne ograniczenia (np. nazewnictwo, osobne resource dla diagnostic settings, prywatne endpointy per service). Dokumentacja musi to jasno opisac.

---

## Kontekst i problemy do naprawy (skrocony opis)

- Brak wymaganego `docs/IMPORT.md`.
- `SECURITY.md` zawiera bledne nazwy zmiennych i funkcje, ktorych modul realnie nie ma.
- `README.md` nie zawiera sekcji **Security Considerations**.
- `docs/README.md` i `examples/README.md` wskazuja nieistniejace przyklady (`simple`) i maja nieaktualne wersje/komendy.
- Czesci przykladow brakuje `variables.tf`.
- `generate-docs.sh` generuje dodatkowe `.terraform-docs.yml` w examples i nie jest zgodny z guide.
- `tests/README.md` nie zgadza sie z `tests/Makefile` i guide (targety, wersje TF).
- Brak `tests/.gitignore`.
- Brak wsparcia `diagnostic settings` w module (ma byc wbudowane, z obsluga scope per service).

---

## Zakres i deliverables

### TASK-008-1: Dokumentacja modulu (README/SECURITY/IMPORT/docs)

**Cel:** Ujednolicic dokumentacje z guide i realnym stanem modulu.

**Do zrobienia:**
- `modules/azurerm_storage_account/docs/IMPORT.md`:
  - dodac wg wzorca z AKS (Prerequisites, minimal module-only config, import blocks, verification, common errors).
- `modules/azurerm_storage_account/README.md`:
  - dodac sekcje **Security Considerations** (wymagane przez guide),
  - opisac security defaults i wskazac, ktore elementy sa poza modulem (np. diagnostic settings tworzone osobnymi resource).
- `modules/azurerm_storage_account/SECURITY.md`:
  - poprawic nazwy zmiennych (np. `https_traffic_only_enabled`, `shared_access_key_enabled`),
  - usunac/naprostowac opisy diagnostyki jesli modul jej nie tworzy,
  - opisac tylko realne kontrolki i ograniczenia.
- `modules/azurerm_storage_account/docs/README.md`:
  - zaktualizowac liste dokumentow i examples (basic/complete/secure),
  - usunac referencje do `examples/simple`.
- `modules/azurerm_storage_account/examples/README.md`:
  - lista istniejacych przykladow,
  - poprawny opis zrodel (lokalny `../..` w repo),
  - wersje Terraform/AzureRM zgodne z `versions.tf`.

---

### TASK-008-2: Przyklady (examples)

**Cel:** Przyklady zgodne z guide, kompletne i uruchamialne lokalnie.

**Checklist:**
- [ ] Wszystkie przyklady maja: `README.md`, `.terraform-docs.yml`, `main.tf`, `variables.tf`, `outputs.tf`.
- [ ] Dodac brakujace `variables.tf` w:
  - `examples/secure`
  - `examples/data-lake-gen2`
  - `examples/identity-access`
- [ ] Ustawic `source = "../.."` we wszystkich examples.
- [ ] Upewnic sie, ze nazwy zasobow sa stale i zgodne z patternami (z uwzglednieniem ograniczen storage account).

---

### TASK-008-3: Automatyzacja (Makefile + generate-docs.sh)

**Cel:** Zgodnosc z `docs/MODULE_GUIDE/07-automation.md`.

**Do zrobienia:**
- `modules/azurerm_storage_account/generate-docs.sh`:
  - uproscic do wzorca AKS (bez tworzenia/niszczenia `.terraform-docs.yml` w examples),
  - opcjonalnie uzyc `scripts/generate-terraform-docs-config.sh` z repo.
- `modules/azurerm_storage_account/Makefile`:
  - dodac targety `docs`, `validate`, `security`, `check`, `clean`, `help`,
  - zachowac `test`/`test-short` itd. (spojne z `tests/Makefile`).

---

### TASK-008-4: Testy (fixtures + README + .gitignore)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE/`.

**Checklist:**
- [ ] `modules/azurerm_storage_account/tests/README.md`:
  - komendy zgodne z `tests/Makefile` (bez `test-all/test-short` jesli nie istnieja),
  - poprawne wersje Terraform/Go (TF >= 1.12.2),
  - opis katalogow fixtures zgodny z rzeczywistoscia.
- [ ] Dodac `modules/azurerm_storage_account/tests/.gitignore` (jak w AKS).
- [ ] Rozstrzygnac nazwy fixtures:
  - albo rename `simple` -> `basic` i `security` -> `secure`,
  - albo opisac jako legacy w README (zgodnie z guide).
- [ ] Ujednolicic `required_version` w fixtures z `versions.tf`.

---

### TASK-008-5: CONTRIBUTING i zgodnosc z module.json

**Cel:** Zgodnosc z aktualnym stanem repo.

**Do zrobienia:**
- `modules/azurerm_storage_account/CONTRIBUTING.md`:
  - usunac wzmianke o `.github/module-config.yml` (uzywany jest `module.json`),
  - poprawic liste examples (basic/complete/secure + feature-specific),
  - poprawic format tagu na `SAv{major}.{minor}.{patch}` zgodny z `module.json`,
  - poprawic nazwy zmiennych w sekcjach security.

---

### TASK-008-6: Diagnostic settings (storage account + services)

**Cel:** Dodac w module wsparcie `azurerm_monitor_diagnostic_setting` analogicznie do AKS, ale z mozliwoscia wyboru scope (storage account + poszczegolne serwisy).

**Zakres (wzorowany na AKS):**
- Dodac zmienna `diagnostic_settings` (lista obiektow) z parametrem `scope`, ktory okresla target resource ID.
- Obslugiwane scope (min): `storage_account`, `blob`, `queue`, `file`.  
  Opcjonalnie: `table`, `dfs` (jesli provider wspiera).
- Implementacja ma tworzyc *jeden* blok `azurerm_monitor_diagnostic_setting` per wpis (for_each po `name`).
- Dla kazdego scope wyliczyc `target_resource_id`:
  - storage account: `azurerm_storage_account.storage_account.id`
  - blob service: `join("/", [azurerm_storage_account.storage_account.id, "blobServices", "default"])`
  - queue service: `join("/", [azurerm_storage_account.storage_account.id, "queueServices", "default"])`
  - file service: `join("/", [azurerm_storage_account.storage_account.id, "fileServices", "default"])`
  - table service: `join("/", [azurerm_storage_account.storage_account.id, "tableServices", "default"])` (jesli uzywane)
  - dfs service: `join("/", [azurerm_storage_account.storage_account.id, "dfsServices", "default"])` (jesli uzywane)
- Pobierac dostepne kategorie per scope z data source `azurerm_monitor_diagnostic_categories`,
  a nastepnie filtrowac wymagane kategorie do tych, ktore sa realnie dostepne w regionie.
- Jeśli po filtracji brak kategorii (log/metric) => wpis pomijany + raport w `diagnostic_settings_skipped` (jak w AKS).

**Proponowana struktura inputu:**
```hcl
variable "diagnostic_settings" {
  description = "Diagnostic settings for storage account and services. Empty list disables diagnostics."
  type = list(object({
    name                           = string
    scope                          = optional(string, "storage_account") # storage_account | blob | queue | file | table | dfs
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

**Przyklad (storage account + blob + file):**
```hcl
diagnostic_settings = [
  {
    name                       = "diag-storage"
    scope                      = "storage_account"
    areas                      = ["transaction", "capacity"]
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  },
  {
    name                       = "diag-blob"
    scope                      = "blob"
    areas                      = ["read", "write", "delete", "transaction", "capacity"]
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  },
  {
    name                       = "diag-file"
    scope                      = "file"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    log_categories             = ["StorageRead"]
    metric_categories          = ["Transaction"]
  }
]
```

**Implementacja (szkic, analogiczny do AKS):**
```hcl
locals {
  diagnostic_scope_ids = {
    storage_account = azurerm_storage_account.storage_account.id
    blob            = join("/", [azurerm_storage_account.storage_account.id, "blobServices", "default"])
    queue           = join("/", [azurerm_storage_account.storage_account.id, "queueServices", "default"])
    file            = join("/", [azurerm_storage_account.storage_account.id, "fileServices", "default"])
    table           = join("/", [azurerm_storage_account.storage_account.id, "tableServices", "default"])
    dfs             = join("/", [azurerm_storage_account.storage_account.id, "dfsServices", "default"])
  }

  diagnostic_scopes = distinct([for ds in var.diagnostic_settings : ds.scope])
}

data "azurerm_monitor_diagnostic_categories" "storage" {
  for_each   = { for scope in local.diagnostic_scopes : scope => local.diagnostic_scope_ids[scope] }
  resource_id = each.value
}

locals {
  diagnostics_enabled = length(var.diagnostic_settings) > 0

  diag_log_categories_by_scope = {
    for scope, ds in data.azurerm_monitor_diagnostic_categories.storage : scope => ds.log_category_types
  }

  diag_metric_categories_by_scope = {
    for scope, ds in data.azurerm_monitor_diagnostic_categories.storage : scope => ds.metrics
  }

  # Area map (minimalny, filtrowany do dostepnych kategorii)
  diag_area_log_map = {
    for scope, categories in local.diag_log_categories_by_scope : scope => merge(
      { all   = categories },
      { read  = [for c in ["StorageRead"] : c if contains(categories, c)] },
      { write = [for c in ["StorageWrite"] : c if contains(categories, c)] },
      { delete = [for c in ["StorageDelete"] : c if contains(categories, c)] }
    )
  }

  diag_area_metric_map = {
    for scope, categories in local.diag_metric_categories_by_scope : scope => merge(
      { all         = categories },
      { transaction = [for c in ["Transaction"] : c if contains(categories, c)] },
      { capacity    = [for c in ["Capacity"] : c if contains(categories, c)] }
    )
  }

  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      scope            = ds.scope != null ? ds.scope : "storage_account"
      areas            = ds.areas != null ? ds.areas : ["all"]
      log_categories   = ds.log_categories != null ? ds.log_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) :
        lookup(local.diag_area_log_map[ds.scope], area, [])
      ]))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) :
        lookup(local.diag_area_metric_map[ds.scope], area, [])
      ]))
    })
  ]

  diagnostic_settings_resolved_by_name = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
  }

  diagnostic_settings_for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if !(
      ds.log_categories != null && length(ds.log_categories) == 0 &&
      ds.metric_categories != null && length(ds.metric_categories) == 0
    )
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name              = ds.name
      scope             = ds.scope
      areas             = ds.areas
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = local.diagnostic_scope_ids[local.diagnostic_settings_resolved_by_name[each.key].scope]

  log_analytics_workspace_id     = try(local.diagnostic_settings_resolved_by_name[each.key].log_analytics_workspace_id, null)
  storage_account_id             = try(local.diagnostic_settings_resolved_by_name[each.key].storage_account_id, null)
  eventhub_authorization_rule_id = try(local.diagnostic_settings_resolved_by_name[each.key].eventhub_authorization_rule_id, null)
  eventhub_name                  = try(local.diagnostic_settings_resolved_by_name[each.key].eventhub_name, null)

  dynamic "enabled_log" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}
```

**Output (jak w AKS):**
```hcl
output "diagnostic_settings_skipped" {
  description = "Entries skipped because no categories were available after filtering."
  value       = local.diagnostic_settings_skipped
}
```

**Dokumentacja i przyklady:**
- Dodac sekcje diagnostic settings w `README.md` oraz `SECURITY.md`.
- Dodac przyklad w `examples/complete` i/lub nowy `examples/diagnostic-settings`.
- Zaktualizowac `tests/unit` o walidacje scope i destinations (przynajmniej 1 dest ustawiony).

---

## Definition of Done

- [ ] `docs/IMPORT.md` istnieje i jest zgodny z guide.
- [ ] `README.md` zawiera **Security Considerations**.
- [ ] `SECURITY.md` nie opisuje nieistniejacych inputow/feature'ow.
- [ ] Wszystkie examples sa kompletne i zgodne z guide.
- [ ] `generate-docs.sh` i `Makefile` zgodne z guide.
- [ ] `tests/README.md` i fixtures zgodne z `docs/TESTING_GUIDE/`.
- [ ] `CONTRIBUTING.md` zgodny z `module.json` i aktualnym stanem repo.
- [ ] Diagnostic settings wspieraja scope dla storage account i serwisow (blob/queue/file, opcjonalnie table/dfs).
