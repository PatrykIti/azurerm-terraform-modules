# TASK-030: Private DNS Zone + VNet Link modules
# FileName: TASK-030_Private_DNS_Zone_Modules.md

**Priority:** High  
**Category:** New Modules / Networking  
**Estimated Effort:** Medium  
**Dependencies:** -  
**Status:** To Do

---

## Cel

Stworzyc nowe moduly zgodne z repo standardami:
- `modules/azurerm_private_dns_zone`
- `modules/azurerm_private_dns_zone_virtual_network_link`

Moduly musza byc zgodne z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Private DNS Zone i VNet Link sa krytyczne dla scenariuszy z Private Endpoint,
ale zgodnie z "atomic modules" pozostaja osobnymi modulami, bez bundlowania w PE.

---

## Zakres (Provider Resources)

**Private DNS Zone module (primary):**
- `azurerm_private_dns_zone`

**Private DNS Zone VNet Link module (primary):**
- `azurerm_private_dns_zone_virtual_network_link`

**Out-of-scope (oba moduly):**
- Private DNS record sets (A/AAAA/CNAME/SRV/TXT/PTR/MX) jako osobne moduly
- RBAC/role assignments, policy, budzety
- VNet/Subnet creation (pokazujemy w examples jako zasoby pomocnicze)

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Jeden primary resource na modul. DNS Zone i VNet Link sa osobnymi modulami.

2) **Brak cross-resource glue**  
   Moduly nie tworza zasobow zewnetrznych poza swoim primary resource.
   Powiazania realizowane tylko przez ID inputy.

3) **Security-first**  
   Domyslnie brak publicznego exposure. Ryzyka i rekomendacje w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`,
   zaleznosci cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

**Private DNS Zone:**
- name + RG + tags
- `soa_record` (jesli wspierane)
- timeouts

**Private DNS Zone VNet Link:**
- name + RG + zone name + vnet id
- `registration_enabled`
- tags + timeouts

---

## Zakres i deliverables

### TASK-027-1: Discovery / feature inventory

**Cel:** Potwierdzic schema provider `azurerm` 4.57.0 dla DNS Zone i VNet Link.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`) dla:
  - `azurerm_private_dns_zone`
  - `azurerm_private_dns_zone_virtual_network_link`
- Potwierdzic:
  - wsparcie i pola `soa_record` (jesli wystepuje).
  - dozwolone wartosci i limity (nazwa strefy, `registration_enabled`).
  - wsparcie `timeouts`.
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).

---

### TASK-027-2: Scaffold modulu Private DNS Zone

**Cel:** Stworzyc pelna strukture `modules/azurerm_private_dns_zone`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_private_dns_zone`
  - commit_scope: `private-dns-zone`
  - tag_prefix: `PDNSZv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` i doprowadzic do pelnej zgodnosci.

---

### TASK-027-3: Implementacja Private DNS Zone (variables + main + outputs)

**Cel:** Wsparcie pelnego API `azurerm_private_dns_zone`.

**Do zrobienia:**
- Inputs: `name`, `resource_group_name`, `tags`, `soa_record` (jesli wspierane), `timeouts`.
- Walidacje: nazwa strefy (format FQDN, length), pola `soa_record`.
- Outputs: `id`, `name`, `number_of_record_sets`, `soa_record` (wg schema).

---

### TASK-027-4: Scaffold modulu Private DNS Zone VNet Link

**Cel:** Stworzyc pelna strukture `modules/azurerm_private_dns_zone_virtual_network_link`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_private_dns_zone_virtual_network_link`
  - commit_scope: `private-dns-zone-vnet-link`
  - tag_prefix: `PDNSZLNKv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` i doprowadzic do pelnej zgodnosci.

---

### TASK-027-5: Implementacja Private DNS Zone VNet Link

**Cel:** Wsparcie pelnego API `azurerm_private_dns_zone_virtual_network_link`.

**Do zrobienia:**
- Inputs: `name`, `resource_group_name`, `private_dns_zone_name`,
  `virtual_network_id`, `registration_enabled`, `tags`, `timeouts`.
- Walidacje: nazwa linku, format `private_dns_zone_name`, `virtual_network_id`.
- Outputs: `id`, `name`, `virtual_network_id`, `registration_enabled`.

---

### TASK-027-6: Dokumentacja modulow

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia (dla kazdego modulu):**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (record sets, RBAC, itp.).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (DNS, registration, isolation)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-027-7: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady uruchamialne lokalnie, zgodne z guide.

**Private DNS Zone examples:**
- `basic`: minimalna strefa DNS.
- `complete`: strefa z `soa_record` (jesli wspierane) + tags.
- `secure`: strefa + ograniczony usage (opis w README).

**VNet Link examples:**
- `basic`: strefa + vnet link.
- `complete`: vnet link z `registration_enabled`.
- `secure`: link do VNetu uzywanego przez Private Endpoint (PE jako osobny modul).

**Feature-specific (propozycje):**
- `examples/soa-record`
- `examples/registration-enabled`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, dns zone) tworzone lokalnie w example.

---

### TASK-027-8: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw (DNS zone, link).
- walidacje `registration_enabled`.
- outputs z `try()`.

**Integration / Terratest:**
- Fixtures:
  - DNS: `basic`, `complete`
  - VNet link: `basic`, `complete`, `secure`
- Weryfikacja:
  - DNS zone properties
  - VNet link i rejestracja (jesli enabled)

**Negatywne:**
- niepoprawny format `private_dns_zone_name`
- brak `virtual_network_id`

---

### TASK-027-9: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpisy w `docs/_CHANGELOG/` dla nowych modulow.

---

## Acceptance Criteria

- Moduly `azurerm_private_dns_zone` i `azurerm_private_dns_zone_virtual_network_link`
  spelniaja layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-private-dns-zone.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-private-dns-zone-vnet-link.md`
- `modules/README.md` (nowe moduly w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
