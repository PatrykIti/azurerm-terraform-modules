# TASK-017: PostgreSQL Flexible Server Database module
# FileName: TASK-017_PostgreSQL_Flexible_Server_Database_Module.md

**Priority:** Medium  
**Category:** New Module / Database  
**Estimated Effort:** Medium  
**Dependencies:** TASK-016  
**Status:** Done

---

## Cel

Stworzyc nowy modul `modules/azurerm_postgresql_flexible_server_database` zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Modul ma zarzadzac pojedyncza baza danych na istniejacym PostgreSQL Flexible
Server. Serwer jest poza zakresem modulu.

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_postgresql_flexible_server_database`

**Out-of-scope:**
- `azurerm_postgresql_flexible_server` (osobny modul)
- networking, private endpoints, RBAC, Key Vault, diagnostic settings

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Jeden zasob: `azurerm_postgresql_flexible_server_database`.

2) **Brak cross-resource glue**  
   Modul nie tworzy serwera ani infrastruktury sieciowej. W examples serwer
   jest tworzony jako osobny zasob.

3) **Spojny UX**  
   Zmienne jawne (`server_id`, `name`, `charset`, `collation`). Walidacje w
   `variables.tf`, brak defaultow w `locals`.

4) **Security-first**  
   Modul nie przechowuje sekretow. Ryzyka odnosza sie do ustawien serwera
   (public access, CMK, auth) i sa opisane w `SECURITY.md`.

---

## Zakres i deliverables

### TASK-017-1: Discovery / feature inventory

**Cel:** Potwierdzic schema provider `azurerm` (4.57.0).

**Do zrobienia:**
- Sprawdzic wymagane pola i domyslne wartosci (`server_id`, `name`).
- Potwierdzic wspierane pola `charset` i `collation` (opcjonalne).
- Sprawdzic wsparcie `timeouts` dla tego resource.
- Spisac ograniczenia walidacji (dopuszczalne znaki, dlugosci).

---

### TASK-017-2: Scaffold modulu + pliki bazowe

**Cel:** Stworzyc pelna strukture modulu zgodna z guide.

**Checklist:**
- [ ] `modules/azurerm_postgresql_flexible_server_database/` utworzony przez
      `scripts/create-new-module.sh`.
- [ ] `module.json`:
  - name: `azurerm_postgresql_flexible_server_database`
  - commit_scope: `postgresql-flexible-server-database`
  - tag_prefix: `PGFSDBv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] `.releaserc.js`, `.terraform-docs.yml`, `Makefile`, `generate-docs.sh`
      zgodne z AKS.
- [ ] Pliki bazowe: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
      `VERSIONING.md`, `SECURITY.md`, `docs/IMPORT.md`.

---

### TASK-017-3: Inputs + resource `azurerm_postgresql_flexible_server_database`

**Cel:** Implementacja API zasobu + walidacje.

**Proponowany UX:**
- `server_id`: string
- `name`: string
- `charset`: optional(string)
- `collation`: optional(string)

**Walidacje (must-have):**
- `server_id` niepusty.
- `name` niepusty, zgodny z zasadami nazewnictwa (po discovery).
- `charset` i `collation` niepuste gdy ustawione (opcjonalnie: whitelist).

**Outputs:**
- `id`, `name`, `server_id`, `charset`, `collation` (z `try()`).

**Implementation notes:**
- Brak `locals` z defaultami; ewentualnie `locals` tylko dla pochodnych flag.

---

### TASK-017-4: Dokumentacja modulu

**Cel:** Kompletny zestaw docs zgodny z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` (markers + Module Documentation + Security Considerations).
- `docs/README.md`:
  - Overview
  - Managed Resources (tylko database)
  - Out-of-scope (server, networking, RBAC, diagnostics)
- `docs/IMPORT.md` (import blocks + minimal module config).
- `SECURITY.md` (ryzyka na poziomie serwera + bezpieczne usage).

---

### TASK-017-5: Examples (basic/complete/secure)

**Cel:** Przyklady zgodne z guide, uruchamialne lokalnie.

**Wymagane:**
- `examples/basic`: minimalny serwer + jedna baza.
- `examples/complete`: jawne `charset` i `collation` + dodatkowe DB (drugi
  instancjonowany modul).
- `examples/secure`: serwer z private networking (poza modulem) + baza.

**Wspolne:**
- `source = "../.."`, stale nazwy (z random suffix).
- `README.md` + `.terraform-docs.yml`.

---

### TASK-017-6: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests:**
- walidacja `database.name`
- walidacja `charset/collation`
- walidacja `server.id`

**Integration tests:**
- fixtures `basic`, `complete`, `secure`
- weryfikacja outputow + istnienia bazy

**Negative tests:**
- niepoprawny `name` lub `collation`

---

### TASK-017-7: Release i docs automation

**Cel:** Spiac release + docs jak w innych modulach.

**Do zrobienia:**
- `module.json` + `.releaserc.js` poprawne scope i tag prefix.
- `generate-docs.sh` i `.terraform-docs.yml` dla modulu i examples.
- Aktualizacja listy examples przez `./scripts/update-examples-list.sh`.
