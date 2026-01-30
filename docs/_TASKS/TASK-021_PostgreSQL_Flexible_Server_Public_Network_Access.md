# TASK-021: PostgreSQL Flexible Server - public network access toggle
# FileName: TASK-021_PostgreSQL_Flexible_Server_Public_Network_Access.md

**Priority:** High  
**Category:** Module Fix / Networking  
**Estimated Effort:** Small  
**Dependencies:** TASK-016  
**Status:** Done

---

## Cel

Umozliwic w module `azurerm_postgresql_flexible_server` scenariusz:
- `public_network_access_enabled = false` bez wymuszania `delegated_subnet_id`
  i `private_dns_zone_id`
- zachowanie pelnej obslugi delegowanego subnetu (VNet integration)
- brak bundlowania private endpoint (nadal out-of-scope)

---

## Analiza stanu obecnego

1) `variables.tf` wymusza `delegated_subnet_id` i `private_dns_zone_id`, gdy
   `public_network_access_enabled = false`.
2) To blokuje scenariusz "private endpoint" zarzadzany poza modulem.
3) Dokumentacja (README + docs/README + SECURITY) opisuje delegowany subnet jako
   jedyna sciezke prywatna.

---

## Zalozenia i decyzje

1) **Public access niezalezny od delegowanego subnetu**  
   `public_network_access_enabled` mozna ustawic `true` lub `false`
   niezaleznie od ustawien delegated subnetu.

2) **Delegowany subnet = komplet**  
   `delegated_subnet_id` i `private_dns_zone_id` musza byc ustawione razem.

3) **Delegowany subnet wymaga public access = false**  
   Jesli ustawione sa `delegated_subnet_id` / `private_dns_zone_id`,
   publiczny dostep musi byc wylaczony.

4) **Private endpoint poza modulem**  
   Modul nie tworzy private endpoint ani DNS linkow; w docs jasno opisac, ze
   mozna wylaczyc public access i dostawic private endpoint poza modulem.

---

## Zakres i deliverables

### TASK-021-1: Walidacje i inputy
- [ ] Zmienic walidacje w `variables.tf`:
  - brak wymuszenia `delegated_subnet_id`/`private_dns_zone_id` przy
    `public_network_access_enabled = false`
  - wymaganie kompletu `delegated_subnet_id` + `private_dns_zone_id` gdy uzywane
  - wymaganie `public_network_access_enabled = false` dla delegated subnetu
- [ ] Zachowac ograniczenie: `firewall_rules` tylko gdy public access = true

### TASK-021-2: Dokumentacja
- [ ] Zaktualizowac opis `network` w `variables.tf` (terraform-docs -> README)
- [ ] Zaktualizowac `modules/azurerm_postgresql_flexible_server/docs/README.md`
      oraz `modules/azurerm_postgresql_flexible_server/SECURITY.md`
- [ ] Doprecyzowac scenariusz private endpoint jako out-of-scope

### TASK-021-3: Testy
- [ ] Dodac unit test dla `public_network_access_enabled = false` bez
      delegated subnetu
