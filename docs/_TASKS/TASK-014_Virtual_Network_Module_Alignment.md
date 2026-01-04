# TASK-014: Virtual Network module alignment (docs + examples + tests)
# FileName: TASK-014_Virtual_Network_Module_Alignment.md

**Priority:** High
**Category:** Module Cleanup / Documentation / Testing
**Estimated Effort:** Medium
**Dependencies:** -
**Status:** To Do

---

## Cel

Dostosowac modul `modules/azurerm_virtual_network` do wytycznych z:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`

Zakres obejmuje tylko zasob `azurerm_virtual_network`. Sub-resources (subnets, peering,
diagnostic settings, flow logs) pozostaja poza modulem i maja byc pokazywane jako osobne
zasoby w przykladach.

---

## Kontekst / problemy do naprawy (skrot)

- Brak `docs/IMPORT.md`.
- README/SECURITY/docs/README opisuje funkcje, ktorych modul nie posiada.
- Brak testow jednostkowych `tests/unit/*.tftest.hcl`.
- Root `Makefile` nie ma targetow z guide (`validate`, `security`, `check`, `clean`, `help`).
- Przyklady maja twarde zrodla (git ref) i nazwy, ktore nie zawsze spelniaja zasady.
- Outputy nie sa owiniete `try()`.

---

## Zalecenia i decyzje

1) **Nie rozszerzamy zakresu modulu**  
   Dokumentacja i przyklady maja odzwierciedlac tylko realne API modulu.

2) **Security-first tam gdzie mozliwe**  
   Dla funkcji wymagajacych dodatkowych zasobow (np. DDoS plan) dokumentujemy ryzyko
   i pokazujemy konfiguracje w `examples/secure`.

3) **Flat variables**  
   Modul pozostaje z plaskimi zmiennymi (maly zakres). Dodajemy notke o tej decyzji w docs.

---

## Zakres i deliverables

### TASK-014-1: Dokumentacja modulu (README/SECURITY/IMPORT/docs)

**Cel:** Ujednolicic dokumentacje z realnym API modulu.

**Do zmiany:**
- `modules/azurerm_virtual_network/README.md`:
  - usunac wzmianki o peering/diagnostic/flow logs jako funkcjach modulu,
  - poprawic Usage (usunac `diagnostic_settings` z przykladu),
  - dodac sekcje **Module Documentation** z linkami do `docs/README.md` i `docs/IMPORT.md`,
  - dodac sekcje **Security Considerations** (tylko realne kontrolki),
  - zaktualizowac liste examples (basic/complete/secure + private-endpoint jako feature-specific).
- `modules/azurerm_virtual_network/docs/README.md`:
  - wpisac realne funkcje (address_space, dns_servers, flow_timeout, ddos, encryption),
  - dodac **Managed Resources** (tylko `azurerm_virtual_network`),
  - usunac opisy subnets/NSG/route tables/flow logs.
- `modules/azurerm_virtual_network/SECURITY.md`:
  - wyciac TLS/network_rules/private_endpoints/diagnostic_settings,
  - opisac rzeczywiste ustawienia (DDoS plan, encryption enforcement, DNS),
  - dodac "Out of scope" dla sub-resources.
- `modules/azurerm_virtual_network/docs/IMPORT.md` (nowy plik):
  - prerequisites, minimal module config, import blocks, weryfikacja, common errors,
  - wskazac `tag_prefix` z `module.json` (VNv).
- `modules/azurerm_virtual_network/main.tf`:
  - odswiezyc komentarz naglowka zgodnie z zakresem.

**Przyklad (IMPORT.md):**
```hcl
module "virtual_network" {
  source = "github.com/<org>/<repo>//modules/azurerm_virtual_network?ref=VNv1.1.4"

  name                = "vnet-imported"
  resource_group_name = "rg-existing"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
}

import {
  to = module.virtual_network.azurerm_virtual_network.virtual_network
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-existing"
}
```

---

### TASK-014-2: Inputs, walidacje i outputy

**Cel:** Spelnic wymagania guide (walidacje, locals, try()).

**Do zmiany:**
- `modules/azurerm_virtual_network/variables.tf`:
  - walidacja `resource_group_name` i `location` (niepuste),
  - walidacja CIDR dla `address_space`,
  - walidacja IP dla `dns_servers`,
  - walidacja `encryption.enforcement` (AllowUnencrypted/DropUnencrypted),
  - opcjonalnie: `ddos_protection_plan.enable` jako `optional(bool, true)`.
- `modules/azurerm_virtual_network/main.tf`:
  - dodac `locals` dla `ddos_protection_enabled` i `encryption_enabled`.
- `modules/azurerm_virtual_network/outputs.tf`:
  - owiniac wszystkie outputy w `try(...)`,
  - uzyc `locals` w `network_configuration`.

**Przyklad (walidacje + locals + outputy):**
```hcl
variable "address_space" {
  description = "Address space for the Virtual Network."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for cidr in var.address_space : can(cidrnetmask(cidr))])
    error_message = "address_space must contain valid CIDR blocks."
  }
}

variable "dns_servers" {
  description = "DNS servers for the Virtual Network."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for dns in var.dns_servers : can(cidrhost(format("%s/32", dns), 0))])
    error_message = "All DNS servers must be valid IPv4 addresses."
  }
}

variable "encryption" {
  description = "Encryption configuration for the Virtual Network."
  type = object({
    enforcement = string
  })
  default = null

  validation {
    condition     = var.encryption == null || contains(["AllowUnencrypted", "DropUnencrypted"], var.encryption.enforcement)
    error_message = "encryption.enforcement must be AllowUnencrypted or DropUnencrypted."
  }
}

locals {
  ddos_protection_enabled = var.ddos_protection_plan != null && var.ddos_protection_plan.enable
  encryption_enabled      = var.encryption != null
}

output "id" {
  description = "The ID of the Virtual Network."
  value       = try(azurerm_virtual_network.virtual_network.id, null)
}
```

---

### TASK-014-3: Przyklady (examples)

**Cel:** Przyklady zgodne z guide i uruchamialne lokalnie.

**Do zmiany:**
- `modules/azurerm_virtual_network/examples/*/main.tf`:
  - ustawic `source = "../.."` (zamiast git ref),
  - poprawic nazwy zasobow zgodnie z patternem,
  - dodac zmienne dla globalnie unikalnych nazw (np. storage account).
- `modules/azurerm_virtual_network/examples/secure/main.tf`:
  - naprawic nazwe Network Watcher (bez spacji z `location`).
- `modules/azurerm_virtual_network/examples/*/README.md`:
  - usunac opisy funkcji, ktorych nie tworza te przyklady,
  - wskazac, ktore zasoby sa poza modulem (peering, diagnostics, private endpoint).

**Przyklad (source + normalized location):**
```hcl
locals {
  normalized_location = replace(lower(var.location), " ", "")
}

module "virtual_network" {
  source = "../.."
  name   = "vnet-secure-example"
  # ...
}

resource "azurerm_network_watcher" "example" {
  name                = "nw-vnet-secure-example-${local.normalized_location}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

**Przyklad (globalnie unikalna nazwa):**
```hcl
variable "storage_account_name" {
  description = "Storage account name (global unique)."
  type        = string
  default     = "stvnetcompleteexample"
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

---

### TASK-014-4: Testy (unit + poprawki w testach)

**Cel:** Dodac testy jednostkowe i dopasowac docs/Makefile.

**Do zmiany:**
- Dodac `modules/azurerm_virtual_network/tests/unit/`:
  - `defaults.tftest.hcl`
  - `validation.tftest.hcl`
  - `outputs.tftest.hcl`
  - `naming.tftest.hcl`
- `modules/azurerm_virtual_network/tests/Makefile`:
  - dodac target `test-unit` (terraform test).
- `modules/azurerm_virtual_network/tests/README.md`:
  - Terraform >= 1.12.2,
  - instrukcja `terraform test -test-directory=tests/unit`,
  - poprawic liste plikow (usunac `module_test.go`).
- `modules/azurerm_virtual_network/tests/performance_test.go`:
  - usunac nieistniejace zmienne (`subnets`, `nsg_rule_count`) albo zastapic je legalnymi inputami.

**Przyklad (unit test - validation):**
```hcl
mock_provider "azurerm" {
  mock_resource "azurerm_virtual_network" {
    defaults = {
      id   = "/subscriptions/mock/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
      name = "test-vnet"
    }
  }
}

variables {
  name                = "test-vnet"
  resource_group_name = "rg-test"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
}

run "invalid_address_space" {
  command = plan

  variables {
    address_space = ["not-a-cidr"]
  }

  expect_failures = [var.address_space]
}
```

---

### TASK-014-5: Automatyzacja (Makefile)

**Cel:** Ujednolicic targety z `docs/MODULE_GUIDE/07-automation.md`.

**Do zmiany:**
- `modules/azurerm_virtual_network/Makefile`:
  - dodac `validate`, `security`, `check`, `clean`, `help`,
  - `test` powinien uruchamiac przynajmniej `tests/Makefile` (test-basic + test-unit).

**Przyklad (Makefile, szkic):**
```makefile
.PHONY: validate security check clean help

validate:
	terraform init -backend=false
	terraform validate
	terraform fmt -check -recursive

security:
	tfsec . --minimum-severity HIGH
	checkov -d . --framework terraform --quiet

check: validate security
```

---

## Definition of Done

- [ ] README/SECURITY/docs/README/IMPORT zgodne z realnym API modulu.
- [ ] Przyklady z `source = "../.."` i poprawnymi nazwami zasobow.
- [ ] Dodane `tests/unit/*.tftest.hcl` + instrukcja w `tests/README.md`.
- [ ] Outputy owiniete `try()` i walidacje uzupelnione.
- [ ] Root `Makefile` zgodny z guide.
- [ ] `docs/_TASKS/README.md` zawiera wpis TASK-014.
