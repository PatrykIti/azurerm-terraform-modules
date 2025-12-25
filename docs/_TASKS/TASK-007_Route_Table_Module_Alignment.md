# TASK-007: Route Table module alignment (docs + examples + tests)
# FileName: TASK-007_Route_Table_Module_Alignment.md

**Priority:** 🔴 High  
**Category:** Module Cleanup / Documentation  
**Estimated Effort:** Medium  
**Dependencies:** —  
**Status:** ✅ **Done** (2025-12-25)

---

## Cel

Dostosowac modul `modules/azurerm_route_table` do wytycznych w:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`

Bez dodawania funkcji, ktorych modul nie wspiera (np. diagnostic settings). Asocjacje subnetow maja pozostac poza modulem (poziom konfiguracji/wrapper).

---

## Zalecenia i decyzje

1) **Brak diagnostic settings**  
   Route Table nie wspiera diagnostic settings w Azure, wiec dokumentacja i przyklady nie moga tego sugerowac.

2) **Asocjacje subnetow poza modulem**  
   Route Table ma byc elastyczny; asocjacje (np. `azurerm_subnet_route_table_association`) robimy w konfiguracji lub wrapperze.

3) **BGP propagation**  
   Dopuszczalne jest dodanie `disable_bgp_route_propagation` (alias) jesli tego brakuje, bo to funkcjonalnosc `azurerm_route_table`.

---

## Zakres i deliverables

### TASK-007-1: Dokumentacja modulu (README/SECURITY/IMPORT)

**Cel:** Usunac nieprawdziwe sekcje i ujednolicic dokumentacje z faktycznym stanem modulu.

**Do zmiany:**
- `modules/azurerm_route_table/README.md`:
  - usunac duplikaty "Examples" i przyklady, ktore nie istnieja (hub-spoke/firewall),
  - usunac wzmianki o dynamicznych asocjacjach w module,
  - poprawic usage (zgodne z realnymi inputami),
  - dopisac sekcje **Security Considerations** (wymagane w guide).
- `modules/azurerm_route_table/main.tf` (header):
  - zaktualizowac opis i features, aby odzwierciedlaly realne funkcje,
  - usunac `disable_bgp_route_propagation` i `subnet_ids_to_associate` z komentarza, jesli nieobslugiwane.
- `modules/azurerm_route_table/SECURITY.md`:
  - usunac TLS, private endpoints, network rules, diagnostic settings,
  - opisac tylko realne aspekty: kontrola tras, least privilege, forced tunneling, deny/blackhole.
- `modules/azurerm_route_table/docs/IMPORT.md`:
  - dodac zgodnie z guide (module-only config, import blocks, weryfikacja, common errors).
- `modules/azurerm_route_table/.terraform-docs.yml`:
  - ujednolicic liste examples z faktycznie istniejacymi katalogami.

---

### TASK-007-2: API modulu (BGP propagation)

**Cel:** Wsparcie dla `disable_bgp_route_propagation` jesli brakuje.

**Wymagania:**
- Dodac `disable_bgp_route_propagation` jako alias (np. `bool`, default `null`).
- Zdefiniowac jasna preferencje:
  - gdy `disable_bgp_route_propagation` != null, wylicz `bgp_route_propagation_enabled = !disable_bgp_route_propagation`,
  - zachowac kompatybilnosc z `bgp_route_propagation_enabled`.
- Zaktualizowac `variables.tf`, `main.tf`, `README.md` i outputy (jesli potrzebne).

---

### TASK-007-3: Przyklady

**Cel:** Przyklady zgodne z guide i gotowe do lokalnego uruchomienia.

**Checklist:**
- [ ] Usunac hardcoded `subscription_id` z providerow w examples.
- [ ] Ustawic `source = "../.."` we wszystkich examples (release workflow i tak podmienia).
- [ ] Upewnic sie, ze nazwy zasobow sa stale i zgodne z AKS pattern (bez losowych suffixow).
- [ ] Wszystkie examples maja: `README.md`, `.terraform-docs.yml`, `main.tf`, `variables.tf`, `outputs.tf`.
- [ ] Zostawic `network-wrapper` / `network-wrapper-advanced` jako feature-specific (opisane w README).

---

### TASK-007-4: Testy i docs testowe

**Cel:** Zgodnosc z `docs/TESTING_GUIDE/`.

**Checklist:**
- [ ] `modules/azurerm_route_table/tests/README.md`:
  - Terraform `>= 1.12.2`,
  - ENV vars zgodne z guide (`ARM_*` + mapowanie z `AZURE_*`),
  - komendy zgodne z `tests/Makefile` (`make test`, `make test-basic`, itd.),
  - usunac nieistniejace targety (`test-all`, `test-short`).
- [ ] Sprawdzic fixture layout vs guide (basic/complete/secure/network/negative).
- [ ] Sprawdzic, czy docs nie sugeruja nieistniejacych feature’ow.

---

## Definition of Done

- [ ] README/main.tf/SECURITY/IMPORT zgodne z realna funkcjonalnoscia modulu.
- [ ] Brak wzmianki o diagnostic settings i innych nieistniejacych funkcjach.
- [ ] Przyklady bez hardcoded `subscription_id` i z `source = "../.."`.
- [ ] Lista examples spójna w README i `.terraform-docs.yml`.
- [ ] `tests/README.md` zgodne z `docs/TESTING_GUIDE/`.
