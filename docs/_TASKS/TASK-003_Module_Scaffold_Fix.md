# TASK-003: Fix generator scaffolding vs AKS baseline
# FileName: TASK-003_Module_Scaffold_Fix.md

**Priority:** 🔴 High  
**Category:** Tooling / Scaffolding  
**Estimated Effort:** Medium  
**Dependencies:** —  
**Status:** ✅ **Done** (2025-12-23)

---

## Cel

Naprawic generator (`scripts/create-new-module.sh` + `scripts/templates/`), tak aby nowy modul byl jak najblizej wzorca `modules/azurerm_kubernetes_cluster/` i pozwalal szybko zaczac prace bez recznych poprawek krytycznych plikow.

---

## Zapis obserwacji (po analizie)

1) **Krytyczny blad heredoca**  
   `scripts/create-new-module.sh` wrzuca blok tworzenia `module.json` do `examples/private-endpoint/outputs.tf` (heredoc nie jest zamkniety w miejscu).  
   Efekt: brak `module.json` + uszkodzony `outputs.tf`.

2) **Nieistniejacy template**  
   `scripts/create-module-json.sh` kopiuje `scripts/templates/.releaserc.auto.js`, ktory nie istnieje.

3) **Niespojne fixtures vs testy**  
   Template testow uzywa `fixtures/simple`, `fixtures/security`, `fixtures/private_endpoint` i negatywnych subfolderow, a generator tworzy `fixtures/basic`, `fixtures/complete`, `fixtures/secure`, `fixtures/network`, `fixtures/negative`.

4) **Niepoprawne identyfikatory w testach/Makefile**  
   W testach i Makefile uzywany jest `MODULE_DISPLAY_NAME_PLACEHOLDER`, co po zamianie (np. "Virtual Network") daje spacje i psuje identyfikatory Go i targety Makefile.

5) **Braki w test scaffolding**  
   W szablonach nie ma plikow obecnych w AKS i innych modulach:
   `tests/run_tests_parallel.sh`, `tests/run_tests_sequential.sh`, `tests/test_env.sh`, `tests/go.sum`, `tests/unit/*.tftest.hcl`.

6) **`.github/module-config.yml`**  
   Generator tworzy `.github/module-config.yml`, ale obecnie zaden modul w repo tego nie ma. Dokumentacja jest niespojna (WORKFLOWS vs MODULE_GUIDE).

7) **Outdated instrukcje**  
   Skrypt sugeruje reczne zmiany w workflow, a `docs/MODULE_GUIDE/09-cicd-integration.md` mowi o automatycznej detekcji.

8) **Bezpieczenstwo nadpisania**  
   Generator powinien fail-fast, jesli katalog modulu juz istnieje (bez nadpisywania plikow Terraforma).

---

## Weryfikacja ponowna (po spisaniu)

Potwierdzone po ponownym sprawdzeniu:
- `modules/azurerm_kubernetes_cluster/tests/` zawiera `run_tests_parallel.sh`, `run_tests_sequential.sh`, `test_env.sh`, `go.sum`, `unit/*.tftest.hcl`.  
- `scripts/templates/` nie zawiera odpowiednikow tych plikow.  
- `modules/azurerm_kubernetes_cluster/` nie ma `.github/` ani `module-config.yml`.  
- `scripts/templates/MODULE_TYPE_test.go` odwoluje sie do `fixtures/simple` i uzywa `MODULE_DISPLAY_NAME_PLACEHOLDER` w nazwach testow.

---

## Zakres i decyzje (ustalone)

1) **Zrodlo prawdy dla struktury**  
   - Testy/fixtures/skrypty wzorowac na AKS, a `docs/` zostawic (standard w innych modulach).  
   - `private-endpoint` **nie jest domyslny** (nie kazdy resource wspiera PE). Dodac flagi, by mozna go dolaczyc, gdy ma sens.

2) **Pliki metadanych**  
   - `.github/module-config.yml` to zaszlosc. `module.json` jest jedynym zrodlem metadata i powinien byc jedynym elementem generatora.

3) **Flagi CLI do przykladow**  
   - Brak profili (nie utrzymujemy listy profili).  
   - Domyslnie generujemy `basic`, `complete`, `secure`.  
   - `private-endpoint` tylko przez flage (resource musi to obslugiwac).

---

## Specyfikacja CLI (flagi i skladnia)

**Nowe usage:**

```
./scripts/create-new-module.sh [options] <module_name> <display_name> <prefix> <scope> <description>
```

**Flagi:**

1) `--examples=<csv>`
   - **Opis:** lista przykladow do wygenerowania (tylko katalog `examples/` + odpowiadajace fixtures).
   - **Dozwolone wartosci:** `basic`, `complete`, `secure`, `private-endpoint`
   - **Domyslnie:** `basic,complete,secure`
   - **Wymagane minimum:** `basic`, `complete`, `secure` (bez nich generator ma zwrocic blad albo je automatycznie dopisac z ostrzezeniem; decyzja implementacyjna)
   - **Walidacja:** blad gdy pojawi sie nieznana wartosc lub pusty element listy.
   - **Zachowanie:** generator tworzy tylko wskazane foldery `examples/*` oraz kopiuje je do `tests/fixtures/*`.

2) `--with-private-endpoint`
   - **Opis:** shortcut do dolaczenia `private-endpoint` do listy `--examples`.
   - **Precedencja:**  
     - jesli `--examples` nie podano -> efektywnie `basic,complete,secure,private-endpoint`  
     - jesli `--examples` podano -> dopisuje `private-endpoint` (o ile nie bylo)

3) `-h` / `--help`
   - **Opis:** pokazuje usage i przyklad wywolania z flagami.

**Przyklady:**

```
# Domyslnie: basic + complete + secure
./scripts/create-new-module.sh azurerm_virtual_network "Virtual Network" VN virtual-network "Manages VNets"

# Dodanie private-endpoint
./scripts/create-new-module.sh --with-private-endpoint azurerm_storage_account "Storage Account" SA storage-account "..."

# Jawna lista
./scripts/create-new-module.sh --examples=basic,secure azurerm_subnet "Subnet" SN subnet "..."
```

**Uwagi implementacyjne:**
- Flagi powinny byc parsowane przed walidacja liczby argumentow pozycyjnych.
- Skrypt odrzuca `--examples` z nieznanymi wartosciami (fail-fast).
- `tests/fixtures/network` i `tests/fixtures/negative` tworzone zawsze (baseline AKS).

### Edge cases i walidacja

- `--examples=` (pusta wartosc) => blad i help.
- `--examples=,basic` / trailing comma => blad i help.
- Duplikaty w CSV => dozwolone, ale deduplikujemy (zachowac pierwsze wystapienie).
- Wielkosc liter: tylko lowercase (np. `Basic` -> blad).
- `--examples` bez `basic`/`complete`/`secure` => blad albo auto-dopisanie z warning (do ustalenia; preferowane auto-dopisanie, zeby testy nie wybuchly).
- `--with-private-endpoint` + `--examples` bez `private-endpoint` => dopisz.
- `--with-private-endpoint` + `--examples=...private-endpoint...` => brak zmian.
- Brak `--examples` i brak `--with-private-endpoint` => domyslne `basic,complete,secure`.
- Modul docelowy juz istnieje (`modules/<module_name>`) => blad i exit (bez zmian na dysku).

---

## Proponowana implementacja (sub-taski)

### TASK-003-1: Naprawa krytycznych bledow generatora

**Deliverables:**
- Blok `create-module-json.sh` przeniesiony poza heredoc `outputs.tf`.
- `module.json` tworzony zawsze i poprawnie.
- Dodanie nowego placeholdera dla bezpiecznych identyfikatorow (np. `MODULE_PASCAL_PLACEHOLDER`).

**Checklist:**
- [ ] Zamknac heredoc przed wywolaniem `create-module-json.sh`
- [ ] Dodac obliczanie `MODULE_PASCAL` (Camel/Pascal z `MODULE_TYPE`)
- [ ] Zaktualizowac `replace_placeholders` o nowy placeholder
- [ ] Dodac walidacje brakujacych template files (fail-fast)

---

### TASK-003-2: Ujednolicenie testow i fixtures (AKS baseline)

**Deliverables:**
- Testy i fixtures w szablonach zgodne z AKS: `basic`, `complete`, `secure`, `network`, `negative`.
- `private-endpoint` jako **opcjonalny** przyklad/fixture, wlaczany flaga (bez domyslnej generacji).

**Checklist:**
- [ ] Zmienic `scripts/templates/MODULE_TYPE_test.go` na fixtures: `basic/complete/secure/network/negative`
- [ ] Usunac odniesienia do `simple`/`security`/`private_endpoint` z testow
- [ ] Dodac flage do generatora (np. `--with-private-endpoint` lub `--examples=...`)
- [ ] Upewnic sie, ze generator tworzy foldery zgodne z wybranymi flagami

---

### TASK-003-3: Dodanie brakujacych plikow testowych

**Deliverables:**
- Szablony dla: `run_tests_parallel.sh`, `run_tests_sequential.sh`, `test_env.sh`, `unit/*.tftest.hcl`.
- `go.sum` generowany lub dodany do scaffoldu.

**Checklist:**
- [ ] Skopiowac wzorce z `modules/azurerm_kubernetes_cluster/tests` (lub innego wzorca) do `scripts/templates/`
- [ ] Zaktualizowac `create-new-module.sh`, aby kopiowal te pliki
- [ ] Ustalic, czy `go.sum` powstaje automatycznie (np. `go mod tidy`) czy jest template

---

### TASK-003-4: Przebudowa template test names i Makefile

**Deliverables:**
- W testach/Makefile uzywany bezpieczny identyfikator (PascalCase), bez spacji.
- Makefile dopasowany do aktualnych env var (ARM_*/AZURE_* jak w AKS).

**Checklist:**
- [ ] Zamienic `MODULE_DISPLAY_NAME_PLACEHOLDER` na `MODULE_PASCAL_PLACEHOLDER` w testach i Makefile
- [ ] Zweryfikowac, ze nazwy testow odpowiadaja faktycznym funkcjom Go
- [ ] Zaktualizowac `Makefile.tests` pod wzorzec AKS

---

### TASK-003-5: Pliki metadata i dokumentacja

**Deliverables:**
- `create-module-json.sh` nie odwoluje sie do nieistniejacego `.releaserc.auto.js`
- `.github/module-config.yml` usuniety z generatora i szablonow
- Dokumentacja zaktualizowana do faktycznego procesu (module.json jako jedyne zrodlo)

**Checklist:**
- [ ] Naprawic `scripts/create-module-json.sh` (usunac `.releaserc.auto.js` lub dodac template)
- [ ] Usunac `.github/module-config.yml` z generatora i `scripts/templates/`
- [ ] Zaktualizowac `docs/WORKFLOWS.md` (usunac `.github/module-config.yml`, poprawic opis detekcji)
- [ ] Zaktualizowac `docs/MODULE_GUIDE/02-module-structure.md` (private-endpoint jako opcjonalny)
- [ ] Zaktualizowac `docs/MODULE_GUIDE/09-cicd-integration.md` (potwierdzic `module.json` jako jedyne zrodlo)
- [ ] Zaktualizowac `docs/PROMPT_FOR_MODULE_CREATION.md` (opis nowych flag)
- [ ] Dodac wzmianke o flagach w `scripts/create-new-module.sh` usage

---

### TASK-003-6: Walidacja i kontrola jakosci

**Deliverables:**
- Skrypt/komenda weryfikujaca scaffold vs baseline (AKS).
- Lista akceptowanych roznic (allowlist).

**Checklist:**
- [ ] Dodac check: `find` + diff listy plikow (ignoruj `.terraform`, `.tmp`, `go.sum` itd.)
- [ ] Uruchomic generator w testowym katalogu i porownac z AKS
- [ ] Zaktualizowac README generatora (jesli istnieje) o kroki weryfikacji
- [ ] Zaktualizowac `scripts/validate-structure.sh` (basic/complete zamiast simple, private-endpoint jako opcjonalny)
- [ ] Dodac test manualny: uruchomienie generatora na istniejacym module ma zwrocic blad i nie zmienic plikow

---

## Kryteria akceptacji

- Generator tworzy `module.json` i nie wstrzykuje kodu shell do plikow `.tf`.
- Testy kompiluja sie (brak bledow Go z powodu spacji w nazwach).
- Lista plikow w nowym module jest zgodna z AKS (poza uzgodnionymi wyjatkami).
- Skrypt nie komunikuje przestarzalych instrukcji o workflow.
- `scripts/validate-structure.sh` przechodzi dla nowo wygenerowanego modulu.
- Uruchomienie generatora na istniejacym module nie nadpisuje plikow i zwraca blad.

---

## Notatki / out of scope

- Implementacja logiki zasobu (main/variables/outputs) pozostaje poza zakresem naprawy scaffoldu.
- Przebudowa istniejacych modulow nie jest wymagana (chyba ze uzgodnione w oddzielnym tasku).
