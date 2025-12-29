# TASK-001: AKS module – walidacje, SP/MI UX, docs i bump wersji
# FileName: TASK-001_AKS_Module_Fixes.md

**Priority:** 🔴 High  
**Category:** Terraform Module (AzureRM / AKS)  
**Estimated Effort:** Medium  
**Dependencies:** —  
**Status:** ✅ **Done** (2025-12-23)

---

## Cel

Uporządkować i utwardzić moduł `modules/azurerm_kubernetes_cluster/`:

1) poprawić UX konfiguracji `identity` vs `service_principal` (bez wymuszania `identity = null` przy SP),  
2) dodać brakujące walidacje dla node pooli (default + additional),  
3) poprawić niespójności w dokumentacji (README),  
4) zaktualizować “piny” wersji Terraforma i providera `azurerm` do aktualnych.

---

## Kontekst / stan obecny (dlaczego)

### 1) `identity` vs `service_principal` – UX i „migration scenario”

Aktualnie:
- `identity` ma domyślną wartość (nie-`null`), więc ustawienie `service_principal` wymaga jawnego `identity = null` w kodzie użytkownika.
- W `variables.tf` jest walidacja, która zabrania ustawienia obu naraz (`modules/azurerm_kubernetes_cluster/variables.tf:289`), a opis sugeruje wspieranie scenariusza migracji SP→MI.

Docelowo:
- użytkownik powinien móc podać samo `service_principal` i nie myśleć o `identity = null`,
- brak konfiguracji obu powinien dawać bezpieczny default (np. SystemAssigned), jeśli taki jest zamysł repo.

### 2) Walidacje node pooli

Aktualnie:
- `default_node_pool.node_count` jest opcjonalne, ale brak walidacji dla przypadku `auto_scaling_enabled = false` (provider zwykle wymaga `node_count` w tym trybie).
- Dla `node_pools[]` brak analogicznych walidacji `min_count`/`max_count` przy `auto_scaling_enabled = true` oraz `node_count` przy `auto_scaling_enabled = false`.

Docelowo:
- spójna walidacja dla default i additional node pooli.

### 3) DNS prefix – niespójność regex vs komunikat

Aktualnie:
- walidacja mówi „1–54”, ale regex wymaga min. 2 znaków (`modules/azurerm_kubernetes_cluster/variables.tf:48`).

Docelowo:
- albo regex dopuszcza 1 znak, albo komunikat/limit jest zgodny z regex.

### 4) README – niezgodna nazwa pola

Aktualnie:
- w README jest `enable_auto_scaling`, a moduł oczekuje `auto_scaling_enabled` (`modules/azurerm_kubernetes_cluster/README.md:127`).

Docelowo:
- README zgodny z API modułu.

---

## Wersje (aktualizacja)

Źródła (sprawdzone online):
- Terraform checkpoint API: `https://checkpoint-api.hashicorp.com/v1/check/terraform`
- Terraform Registry: `https://registry.terraform.io/v1/providers/hashicorp/azurerm/versions`

Stan na **2025-12-23**:
- Terraform: **1.14.3**
- Provider `hashicorp/azurerm`: **4.57.0**

Zakres aktualizacji wersji w repo (minimum):
- `modules/azurerm_kubernetes_cluster/versions.tf`
- `modules/azurerm_kubernetes_cluster/examples/*/main.tf`
- `modules/azurerm_kubernetes_cluster/tests/fixtures/**/main.tf` (jeśli mają `terraform { ... }`)

Opcjonalnie (dla spójności całego repo):
- `scripts/templates/versions.tf`
- `docs/MODULE_GUIDE/03-core-files.md` (template w dokumentacji)

Decyzja:
- Zostawiamy `required_version = ">= 1.12.2"` oraz aktualizujemy providera `azurerm` do `4.57.0` (w module + examples + fixtures).

---

## Proponowana implementacja (sub-taski)

### TASK-001-1: Wersje Terraforma i providera

**Deliverables:**
- Zaktualizować `azurerm` do `4.57.0` w module i przykładach/fixtures.
- (Opcjonalnie) zaktualizować `required_version`.

**Checklist:**
- [x] Update `modules/azurerm_kubernetes_cluster/versions.tf`
- [x] Update `modules/azurerm_kubernetes_cluster/examples/*/main.tf`
- [x] Update `modules/azurerm_kubernetes_cluster/tests/fixtures/**/main.tf`
- [ ] (Opcjonalnie) update `scripts/templates/versions.tf`
- [ ] (Opcjonalnie) update `docs/MODULE_GUIDE/03-core-files.md`

### TASK-001-2: `identity` / `service_principal` UX

**Propozycja (wariant preferowany):**
- `variable "identity"` domyślnie `null`
- w module (`locals`): `identity_effective = coalesce(var.identity, { type = "SystemAssigned" })`
- `main.tf` używa `identity_effective` jeśli `service_principal == null`
- walidacje tylko gdy `identity != null` (type/identity_ids), bez wymuszania „dokładnie jedno z dwóch”.

**Checklist:**
- [x] Zmiana defaulta `identity` na `null`
- [x] Dopasowanie walidacji (mutual-exclusion: `identity` vs `service_principal`)
- [x] Dodanie `locals` i użycie w `main.tf`
- [x] Aktualizacja opisów w `variables.tf` / README (jeśli trzeba)
- [x] Dodanie testów `terraform test` dla: default MI, SP-only, MI-only

### TASK-001-3: Walidacje node pooli

**Default node pool:**
- [x] Jeśli `auto_scaling_enabled = true` → wymagaj `min_count` i `max_count`
- [x] Jeśli `auto_scaling_enabled = false` → wymagaj `node_count`
- [x] `min_count <= max_count`

**Additional node pools:**
- [x] Analogiczne walidacje w `variable "node_pools"` (iteracja po liście)
- [x] `min_count <= max_count`

### TASK-001-4: DNS prefix

**Opcja A (preferowana):** poprawić regex aby dopuszczał 1 znak:
- `^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$`

**Checklist:**
- [x] Poprawić walidację `dns_config.dns_prefix`
- [x] Dodać test w `modules/azurerm_kubernetes_cluster/tests/unit/validation.tftest.hcl` dla 1-znakowego `dns_prefix`

### TASK-001-5: README – zgodność API

**Checklist:**
- [x] Zamienić `enable_auto_scaling` → `auto_scaling_enabled` w przykładzie
- [x] Przejrzeć README pod kątem innych rozjazdów nazw pól (np. w node_pools)

---

## Kryteria akceptacji

- `terraform fmt -recursive` nie pokazuje zmian dla modułu po formacie.
- `terraform test` w `modules/azurerm_kubernetes_cluster/tests` przechodzi (unit + ewentualnie inne testy zależnie od środowiska).
- Przykłady w `modules/azurerm_kubernetes_cluster/examples/*` są spójne z `variables.tf` (nazwa pól).
- Można skonfigurować:
  - brak `identity` i brak `service_principal` → działa (bezpieczny default),
  - `service_principal` bez `identity = null` → działa,
  - `identity` (SystemAssigned/UserAssigned) → działa.

---

## Notatki o kompatybilności (ważne)

- Zmiana defaulta `identity` na `null` jest zmianą zachowania wejść, ale może być „backward compatible”, jeśli efekt końcowy nadal domyślnie tworzy SystemAssigned (przez `identity_effective`).
- Podbicie `required_version` do `>= 1.14.3` może ograniczyć kompatybilność dla użytkowników na starszych wersjach; jeśli repo ma wspierać szerzej, lepiej zostawić `>= 1.12.2`.
