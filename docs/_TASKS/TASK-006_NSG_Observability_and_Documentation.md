# TASK-006: NSG observability + docs alignment
# FileName: TASK-006_NSG_Observability_and_Documentation.md

**Priority:** 🔴 High  
**Category:** Module Enhancement / Documentation  
**Estimated Effort:** Large  
**Dependencies:** —  
**Status:** ✅ **Done** (2025-12-24)

**Update (2025-12-25):** Azure retired NSG flow logs (no new creation after 2025-07-30). Flow log support was removed from the module, examples, tests, and docs. Observability now focuses on diagnostic settings only.

---

## Cel

Rozszerzyc modul `azurerm_network_security_group` o observability (diagnostic settings) oraz ujednolicic dokumentacje tak, aby jasno wskazywala, ze AKS jest wzorcem, ale inne resource'y moga sie znacznie roznic.

---

## Zalecenia i decyzje

1) **AKS jako wzorzec, nie dogmat**  
   Dokumentacja ma jasno mowic, ze AKS jest baseline, ale inne resource'y moga wymuszac odstepstwa. Takie odstepstwa musza byc opisane w module.

2) **NSG ma wspierac observability**  
   Observability opiera sie na diagnostic settings. Flow logs zostaly wycofane przez Azure i nie sa wspierane w module.

3) **Przyklady maja byc bogate**  
   Przynajmniej `basic`, `complete`, `secure` oraz dodatkowe przyklady feature-specific, tak aby uzytkownicy mieli gotowe wzorce podobnie jak w AKS.

---

## Zakres i deliverables

### TASK-006-1: Aktualizacja dokumentacji repo (AKS jako wzorzec, ale nie jedyne rozwiazanie)

**Cel:** Wprost wskazac, ze AKS jest guide/baseline, lecz nie wszystkie moduły beda identyczne.

**Do zmiany:**
- `docs/MODULE_GUIDE/01-introduction.md`
- `docs/MODULE_GUIDE/05-documentation.md`
- `docs/MODULE_GUIDE/06-examples.md`
- `docs/TESTING_GUIDE/README.md`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

**Checklist:**
- [ ] Dodac zdanie o tym, ze AKS jest wzorcem, ale odstepstwa sa dozwolone i musza byc opisane.
- [ ] Upewnic sie, ze docsy nie implikuja, ze wszystkie moduły MUSZA miec identyczne feature sety.

---

### TASK-006-2: Diagnostic settings dla NSG

**Cel:** Dodac `azurerm_monitor_diagnostic_setting` dla NSG z pelnym wsparciem destynacji.

**Wymagania:**
- Wsparcie dla wszystkich 3 destynacji: Log Analytics, Storage, Event Hub.
- Lista obiektow (np. `diagnostic_settings`) z `for_each` po `name`.
- `default = []` -> brak zasobow.
- Walidacje: unikalne `name`, przynajmniej jedna destynacja, brak konfliktow.
- Opcjonalne filtrowanie kategorii (np. przez `data.azurerm_monitor_diagnostic_categories`) i skip pustych wynikow.

**Deliverables:**
- `variables.tf`: nowa zmienna typu `list(object(...))`.
- `main.tf`: resource `azurerm_monitor_diagnostic_setting`.
- `outputs.tf`: output zdefiniowanych diagnostic settings (IDs + map).
- `README.md` + `SECURITY.md`: sekcje i przyklady zgodne z funkcjonalnoscia.

---

### TASK-006-3: Przyklady (jak najwiecej, zgodnie z AKS)

**Cel:** Pokazac realne uzycia modulu z observability.

**Wymagania minimalne:**
- `examples/basic` (minimal).
- `examples/complete` (pelny set: rules + diag).
- `examples/secure` (zero-trust + observability).
- Feature-specific: np. `examples/diagnostic-settings` lub `examples/observability`.

**Checklist:**
- [ ] Kazdy przyklad ma `README.md`, `.terraform-docs.yml`, `main.tf`, `variables.tf`, `outputs.tf`.
- [ ] Nazewnictwo zgodne z AKS (fixed names, bez losowych suffixow).
- [ ] Lista przykladow w `README.md` zaktualizowana skryptem.

---

### TASK-006-5: Testy (unit + integration)

**Cel:** Pokryc nowa funkcjonalnosc testami i dopasowac do guide.

**Checklist:**
- [ ] `tests/unit/diagnostic_settings.tftest.hcl` + negatywne przypadki.
- [ ] Testy walidacji konfliktow (single vs plural, destination vs destinations).
- [ ] Fixture dla `diagnostic-settings` / `observability`.
- [ ] Go tests sprawdzajace, ze zasoby observability powstaly.
- [ ] Update `tests/test_config.yaml` z poprawnymi nazwami testow.
- [ ] Update `tests/README.md` (zgodne fixture names i komendy).

---

### TASK-006-6: Dokumentacja modulu

**Cel:** Usunac nieprawdziwe sekcje i dodac rzeczywiste.

**Checklist:**
- [ ] `README.md`: sekcje Monitoring/Compliance zgodne z implementacja.
- [ ] `SECURITY.md`: tylko funkcje faktycznie wspierane przez NSG (usunac TLS, private endpoints itd. jesli nie istnieja).
- [ ] Dodac `docs/IMPORT.md` (import NSG + rules, zgodne z guide).

---

## Definition of Done

- [ ] W module NSG sa zrobione diagnostic settings.
- [ ] Dokumentacja repo jasno mowi o AKS jako wzorcu, ale dopuszcza roznice.
- [ ] Przyklady zawieraja pelne scenariusze, plus feature-specific.
- [ ] Testy obejmuja nowa funkcjonalnosc i przechodza.
- [ ] README i SECURITY sa zgodne z rzeczywistoscia, bez deklaracji "z powietrza".
