# TASK-026: Private Endpoint module
# FileName: TASK-026_Private_Endpoint_Module.md

**Priority:** High  
**Category:** New Modules / Networking  
**Estimated Effort:** Large  
**Dependencies:** TASK-030 (Private DNS modules)  
**Status:** To Do

---

## Cel

Stworzyc nowy modul zgodny z repo standardami:
- `modules/azurerm_private_endpoint`

Modul musi byc zgodny z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- `docs/SECURITY.md`

Private Endpoint jest wymaganym elementem scenariuszy z izolacja sieciowa,
ale zgodnie z "atomic modules" nie moze byc bundlowany w innych modulach.
Private DNS Zone i VNet Link sa osobnymi zasobami i sa poza zakresem tego taska
(`TASK-030`).

---

## Zakres (Provider Resources)

**Primary:**
- `azurerm_private_endpoint`

**Powiazane zasoby (w module, jesli wspierane w 4.57.0):**
- `azurerm_private_dns_zone_group` (powiazanie PE -> DNS Zone)
- `azurerm_monitor_diagnostic_setting` (tylko jesli resource wspiera)

**Out-of-scope:**
- `azurerm_private_dns_zone` i `azurerm_private_dns_zone_virtual_network_link`
  (osobny task `TASK-030`)
- Private DNS record sets (A/AAAA/CNAME/SRV/TXT/PTR/MX) jako osobne moduly
- RBAC/role assignments, policy, budzety
- Private Link Service (osobny modul)
- VNet/Subnet creation (pokazujemy w examples jako zasoby pomocnicze)

---

## Zalozenia i decyzje

1) **Atomic scope**  
   Jeden primary resource na modul. Private Endpoint jest osobnym modulem.

2) **Brak cross-resource glue**  
   Private Endpoint nie jest bundlowany w innych modulach. Powiazania miedzy
   modulami realizowane tylko przez ID inputy. DNS Zone i VNet Link tworzone
   osobno (TASK-030). PE moze opcjonalnie zarzadzac `private_dns_zone_group`.

3) **Security-first**  
   Secure defaults gdzie to mozliwe. Brak publicznych zaleznosci. Ryzyka i
   rekomendacje w `SECURITY.md`.

4) **Spojny styl**  
   Listy obiektow + `for_each` po `name`, walidacje w `variables.tf`,
   zaleznosci cross-field jako `lifecycle` preconditions w `main.tf`.

---

## Feature matrix (musi byc pokryty)

- name + RG + location + tags
- `subnet_id`, `custom_network_interface_name`
- `private_service_connection` (resource id lub alias, subresource names)
- `is_manual_connection` + `request_message`
- `ip_configuration` (statyczne IP)
- `private_dns_zone_group` (powiazanie z DNS Zone)
- timeouts

---

## Zakres i deliverables

### TASK-026-1: Discovery / feature inventory

**Cel:** Potwierdzic schema provider `azurerm` 4.57.0 dla PE.

**Do zrobienia:**
- Sprawdzic schema provider `azurerm` (doc lub `terraform providers schema -json`) dla:
  - `azurerm_private_endpoint`
  - `azurerm_private_dns_zone_group`
- Potwierdzic:
  - czy `private_dns_zone_group` jest osobnym resource (i czy PE ma jeszcze nested block).
  - liczbe wspieranych `private_service_connection` oraz `ip_configuration`.
  - pola wymagane przy `is_manual_connection`.
  - czy `private_connection_resource_id` i `private_connection_resource_alias`
    sa rozlaczne oraz kiedy wymagane.
  - zakres/format `subresource_names` i `member_name`.
  - wsparcie `diagnostic_settings` dla PE (jesli brak, jawnie out-of-scope).
- Spisac finalny zestaw pol i ograniczen (allowed values, required combos).

---

### TASK-026-2: Scaffold modulu Private Endpoint

**Cel:** Stworzyc pelna strukture `modules/azurerm_private_endpoint`.

**Checklist:**
- [ ] `scripts/create-new-module.sh` (obowiazkowo)
- [ ] `module.json`:
  - name: `azurerm_private_endpoint`
  - commit_scope: `private-endpoint`
  - tag_prefix: `PEv`
- [ ] `versions.tf` z `azurerm` 4.57.0 + TF >= 1.12.2.
- [ ] Pliki bazowe + docs (`README.md`, `SECURITY.md`, `docs/IMPORT.md`, itd.)
- [ ] Porownac pliki testowe i tooling z
      `modules/azurerm_postgresql_flexible_server` i doprowadzic do pelnej zgodnosci.

---

### TASK-026-3: Core resource `azurerm_private_endpoint`

**Cel:** Implementacja pelnego API PE w `main.tf` + walidacje w `variables.tf`.

**Zakres (przykladowy podzial inputow):**
- **core**: `name`, `resource_group_name`, `location`, `subnet_id`, `tags`
- **network_interface**: `custom_network_interface_name`
- **service_connection(s)**: list(object({ name, private_connection_resource_id?,
  private_connection_resource_alias?, subresource_names?, is_manual_connection,
  request_message? }))
- **ip_configuration**: list(object({ name, private_ip_address, subresource_name?, member_name? }))
- **timeouts** (optional)

**Walidacje i preconditions (must-have):**
- Nazwa PE zgodna z rules Azure (length + regex).
- `subnet_id` musi byc ustawione.
- `private_connection_resource_id` XOR `private_connection_resource_alias`.
- `is_manual_connection = true` -> wymagany `request_message`.
- `subresource_names` wymagane, gdy resource tego wymaga (wg discovery).
- Unikalnosc nazw `private_service_connection` i `ip_configuration`.

---

### TASK-026-4: Sub-resources (private DNS zone group + optional diagnostics)

**Cel:** Pelne wsparcie `azurerm_private_dns_zone_group` dla PE.

**Inputs (propozycje):**
- `private_dns_zone_groups`: list(object({
    name,
    private_dns_zone_ids = list(string)
  }))

**Wymagania:**
- `for_each` po `name` + walidacja unikalnosci.
- Walidacja formatu Azure resource ID dla DNS zones.
- Zaleznosc na PE.

**Opcjonalnie (jesli wspierane):**
- `diagnostic_settings` input (AKS pattern).
- `data.azurerm_monitor_diagnostic_categories` + filtracja kategorii.
- `diagnostic_settings_skipped` output jak w AKS.

---

### TASK-026-5: Dokumentacja modulu

**Cel:** Kompletne docs zgodne z MODULE_GUIDE.

**Do zrobienia:**
- `README.md` z wymaganymi markerami i sekcjami (Module Documentation, Security Considerations).
- `docs/README.md`:
  - Overview, Managed Resources, Usage Notes
  - Out-of-scope zasoby (Private DNS Zone, RBAC, Private Link Service, itp.).
- `docs/IMPORT.md` wg AKS (import blocks + ID collection).
- `SECURITY.md`:
  - posture (network isolation, DNS, manual connection)
  - secure example
  - checklist i typowe bledy
- `CONTRIBUTING.md` i `VERSIONING.md` zgodne z `module.json`.

---

### TASK-026-6: Examples (basic/complete/secure + feature-specific)

**Cel:** Przyklady uruchamialne lokalnie, zgodne z guide.

**Private Endpoint examples:**
- `basic`: PE do Storage Account (subresource: `blob`).
- `complete`: PE + custom NIC + `ip_configuration` + `private_dns_zone_group`.
- `secure`: PE + Private DNS Zone + VNet Link + target resource z wylaczonym
  public access (DNS Zone + VNet Link jako osobne moduly).

**Feature-specific (propozycje):**
- `examples/manual-connection`
- `examples/alias-connection`
- `examples/ip-configuration`
- `examples/private-dns-zone-group`

**Wymagania wspolne:**
- `source = "../.."`, stale nazwy, `README.md` + `.terraform-docs.yml`.
- Zasoby pomocnicze (VNet, subnet, storage account, dns zone) tworzone lokalnie w example.
- Subnet musi miec wylaczone private endpoint network policies (zgodnie z Azure).

---

### TASK-026-7: Testy (unit + integration + negative)

**Cel:** Zgodnosc z `docs/TESTING_GUIDE`.

**Unit tests (tftest.hcl):**
- walidacje nazw PE.
- `private_connection_resource_id` XOR alias.
- `is_manual_connection` -> `request_message`.
- unikalnosc nazw `private_service_connection`, `ip_configuration`, `private_dns_zone_group`.
- outputs z `try()`.

**Integration / Terratest:**
- Fixtures: `basic`, `complete`, `secure`, `private-dns-zone-group`, `ip-configuration`.
- Weryfikacja:
  - PE -> NIC + private IP + service connection
  - DNS zone group attaches do PE

**Negatywne:**
- brak `subnet_id`
- `is_manual_connection = true` bez `request_message`
- brak `private_connection_resource_id` i aliasu
- niepoprawny format zone ID w `private_dns_zone_group`

---

### TASK-026-8: Automatyzacja i release

**Cel:** Spojna automatyzacja i dokumentacja.

**Do zrobienia:**
- `tests/Makefile`, `test_env.sh`, `run_tests_*` jak w AKS.
- `generate-docs.sh` zgodny z guide.
- Aktualizacja `docs/_TASKS/README.md` po wdrozeniu.
- Wpisy w `docs/_CHANGELOG/` dla nowego modulu.

---

## Acceptance Criteria

- Modul `azurerm_private_endpoint` spelnia layout z MODULE_GUIDE.
- Pokrycie wszystkich funkcji z feature matrix + potwierdzonych w provider schema.
- README/SECURITY/IMPORT/CONTRIBUTING/VERSIONING kompletne i spojne.
- Examples basic/complete/secure + feature-specific gotowe i uruchamialne.
- Testy unit + integration + negative przechodza lokalnie.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status + statystyki)
- `docs/_CHANGELOG/README.md`
- `docs/_CHANGELOG/NNN-YYYY-MM-DD-private-endpoint.md`
- `modules/README.md` (nowy modul w tabeli AzureRM)
- `README.md` (badges + tabela "Available Modules")
