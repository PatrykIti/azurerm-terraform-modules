# TASK-015: AKS secrets - remove Key Vault data sources from module
# FileName: TASK-015_AKS_Secrets_Remove_Module_Data_Sources.md

**Priority:** High  
**Category:** Terraform Module (AKS / Secrets)  
**Estimated Effort:** Medium  
**Dependencies:** TASK-002 (AKS secrets module baseline)  
**Status:** ✅ **Done** (2026-01-14)

---

## Cel

Uproscic modul `modules/azurerm_kubernetes_secrets` tak, aby strategia `manual`
nie wykonywala odczytow z Key Vault (brak data sources w module). Odczyt lub
generowanie sekretow powinno byc w warstwie konsumpcji, a modul ma jedynie
tworzyc zasoby w Kubernetes.

---

## Kontekst / problem

- Warstwa konsumpcji (np. aks-secrets) posiada juz logike wyboru KV,
  generowania i kontroli sekretow (prefer KV, optional checks, dynamic sets).
- Data source w module wymusza zaleznosc od `azurerm` i dostep do KV w module,
  co ogranicza elastycznosc oraz utrudnia sterowanie fallbackami.
- Manual strategy staje sie zbyt "opiniowana" - powinna przyjmowac juz
  przygotowane wartosci (z KV, random, vaulty innych providerow itp.).

---

## Zakres i deliverables

### TASK-015-1: Zmiana API manual strategy (breaking change)

**Cel:** Usuniecie KV data sources z modulu i przeniesienie pobierania wartosci
do konsumenta.

**Do zmiany:**
- `modules/azurerm_kubernetes_secrets/main.tf`:
  - usunac `data.azurerm_key_vault_secret.manual`,
  - zasilac `kubernetes_secret_v1.manual` danymi z wejscia (np. `string_data`).
- `modules/azurerm_kubernetes_secrets/variables.tf`:
  - zmienic `manual` tak, aby przyjmowal **wartosci** sekretow, a nie nazwy KV,
  - usunac `key_vault_id`, `key_vault_secret_name`, `key_vault_secret_version`,
  - dodac walidacje: wymagane `value`, unikalnosc kluczy, brak pustych.
- `modules/azurerm_kubernetes_secrets/versions.tf`:
  - usunac `azurerm` z `required_providers` (brak uzycia w module).

**Propozycja nowego ksztaltu manual:**
```hcl
manual = {
  kubernetes_secret_type = "Opaque"
  secrets = [
    {
      name                  = "db-password"
      kubernetes_secret_key = "DB_PASSWORD"
      value                 = var.db_password
    }
  ]
}
```

---

### TASK-015-2: Aktualizacje dokumentacji (obowiazkowe)

**Cel:** Zaktualizowac docs tak, aby odzwierciedlaly nowy kontrakt.

**Do zmiany:**
- `modules/azurerm_kubernetes_secrets/README.md`:
  - opisac manual jako "caller-provided values",
  - usunac wzmianki o KV data sources w module,
  - zaktualizowac Usage i Inputs,
  - dodac krotki **Migration** (stare vs nowe pola).
- `modules/azurerm_kubernetes_secrets/SECURITY.md`:
  - zaktualizowac "Manual" (brak KV odczytow w module, ale sekrety nadal w state).
- `modules/azurerm_kubernetes_secrets/docs/README.md`:
  - dopisac ze KV read jest poza modulem (caller responsibility).
- `modules/azurerm_kubernetes_secrets/examples/*/README.md`:
  - dostosowac opisy manual/inputs do nowych pol.

Po zmianach uruchomic generowanie docs (terraform-docs / generate-docs).

---

### TASK-015-3: Przyklady i testy

**Cel:** Utrzymac spojnosc fixtures i testow po zmianie API.

**Do zmiany:**
- `modules/azurerm_kubernetes_secrets/examples/basic/main.tf`:
  - przekazywac `manual.secrets[*].value` z warstwy wyzej (np. data source KV
    w przykladzie lub wartosc z `var`).
- `modules/azurerm_kubernetes_secrets/tests/unit/*.tftest.hcl`:
  - usunac mock `azurerm` i dostosowac dane wejsciowe.
- `modules/azurerm_kubernetes_secrets/tests/fixtures/basic/*`:
  - przekazywac wartosci do manual zamiast KV nazw.
- `modules/azurerm_kubernetes_secrets/tests/fixtures/*`:
  - upewnic sie, ze pozostalym strategiom (csi/eso) nie szkodzi zmiana.

---

## Notatki do release

- Zmiana jest **breaking** dla `strategy = "manual"` -> release `AKSSv2.0.0`.
- Dodac ostrzezenie o migracji w README i w komunikacie release.
