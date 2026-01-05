# Scripts

Ten katalog zawiera narzedzia do utrzymania repozytorium, generowania dokumentacji
i lokalnego testowania workflow. Polecenia uruchamiaj z katalogu repozytorium,
chyba ze opis mowi inaczej.

## Top-level scripts

### scripts/check-terraform-docs.sh
Cel: sprawdza, czy sekcja terraform-docs w README danego modulu jest aktualna.  
Uruchomienie:
```bash
./scripts/check-terraform-docs.sh modules/azurerm_storage_account
```
Wymagania: `terraform-docs` w PATH.

### scripts/create-module-json.sh
Cel: tworzy `module.json` oraz (opcjonalnie) aktualizuje `.releaserc.js` z szablonu.  
Uruchomienie:
```bash
./scripts/create-module-json.sh modules/azurerm_storage_account
./scripts/create-module-json.sh modules/azurerm_storage_account "Storage Account" storage-account SAv
```

### scripts/create-new-module.sh
Cel: generuje nowy modul z template (struktura, docs, tests, examples).  
Uruchomienie:
```bash
./scripts/create-new-module.sh azurerm_virtual_network "Virtual Network" VN virtual-network "Manages Azure Virtual Networks"
./scripts/create-new-module.sh --examples=basic,secure azurerm_subnet "Subnet" SN subnet "Manages Azure subnets"
```

### scripts/get-module-config.js
Cel: zwraca JSON z `tag_prefix` i `commit_scope` na podstawie `module.json` (lub `.releaserc.js`).  
Uruchomienie:
```bash
node scripts/get-module-config.js modules/azurerm_storage_account
```

### scripts/repo-info.js
Cel: helper do ustalenia `owner/repo` z env lub git remote (uzywany przez workflow/release).  
Uruchomienie (przyklad):
```bash
node -e "const { getRepoInfo } = require('./scripts/repo-info'); console.log(getRepoInfo());"
```

### scripts/security-scan.sh
Cel: szybki security scan (fmt/validate + checkov + tfsec + prosty grep na sekrety).  
Uruchomienie:
```bash
./scripts/security-scan.sh
```
Wymagania: `terraform`, `checkov`, `tfsec`.

### scripts/semantic-release-multi-scope-plugin.js
Cel: plugin do semantic-release filtrujacy commity po scope (multi-scope).  
Uruchomienie: nie uruchamiaj bezposrednio; jest ladowany przez `.releaserc.js`.

### scripts/update-examples-list.sh
Cel: odswieza liste Examples w README modulu.  
Uruchomienie:
```bash
./scripts/update-examples-list.sh modules/azurerm_storage_account
```

### scripts/update-module-docs.sh
Cel: bezpieczne generowanie terraform-docs dla modulu (nie rusza root README).  
Uruchomienie:
```bash
./scripts/update-module-docs.sh azurerm_storage_account
```
Wymagania: `terraform-docs` w PATH.

### scripts/update-module-releaserc.sh
Cel: aktualizuje `.releaserc.js` w modulach do nowego formatu multi-scope.  
Uruchomienie:
```bash
./scripts/update-module-releaserc.sh
./scripts/update-module-releaserc.sh azurerm_storage_account
```

### scripts/update-module-version.sh
Cel: aktualizuje wersje w sekcji `BEGIN_VERSION`/`END_VERSION` w README modulu.  
Uruchomienie:
```bash
./scripts/update-module-version.sh modules/azurerm_storage_account 1.2.0
```

### scripts/update-root-readme.sh
Cel: aktualizuje tabele i badge w root README po release (uzywane przez semantic-release).  
Uruchomienie:
```bash
./scripts/update-root-readme.sh azurerm_storage_account "Storage Account" SAv 1.2.0 owner repo
```

### scripts/validate-structure.sh
Cel: sprawdza podstawowa strukture modulow i kluczowe pliki w repo.  
Uruchomienie:
```bash
./scripts/validate-structure.sh
```

## Repository scripts

### scripts/repository/clean-terraform-artifacts.sh
Cel: usuwa cache/lock/state/plan dla Terraform ze wszystkich modulow i ich
podkatalogow (examples, fixtures, tests).  
Uruchomienie:
```bash
./scripts/repository/clean-terraform-artifacts.sh
```

## Testing workflows (lokalnie)

### scripts/testing_workflows/download-act-docker-image.sh
Cel: pobiera image do `act` (symulacja GitHub Actions).  
Uruchomienie:
```bash
./scripts/testing_workflows/download-act-docker-image.sh
```
Wymagania: Docker.

### scripts/testing_workflows/test-release-workflow.sh
Cel: testuje workflow release dla jednego modulu przez `act`.  
Uruchomienie:
```bash
./scripts/testing_workflows/test-release-workflow.sh azurerm_storage_account true
```
Wymagania: `act`, Docker.

### scripts/testing_workflows/test-full-release-workflow.sh
Cel: symuluje pelny workflow release (detect-changes + matrix + semantic-release).  
Uruchomienie:
```bash
./scripts/testing_workflows/test-full-release-workflow.sh true
./scripts/testing_workflows/test-full-release-workflow.sh true azurerm_storage_account,azurerm_subnet
```
Wymagania: `act` (opcjonalnie) i Node.js (`npx`) dla czesci semantic-release.

### scripts/testing_workflows/test-multi-module-release.sh
Cel: symulacja release wielu modulow (scope w PR title + check config).  
Uruchomienie:
```bash
./scripts/testing_workflows/test-multi-module-release.sh
./scripts/testing_workflows/test-multi-module-release.sh --run-with-act
```

### scripts/testing_workflows/test-release-docker.sh
Cel: test release w kontenerze z image runnera GitHub Actions.  
Uruchomienie:
```bash
./scripts/testing_workflows/test-release-docker.sh azurerm_storage_account
```
Wymagania: Docker.

### scripts/testing_workflows/test-semantic-release-local.sh
Cel: lokalny dry-run semantic-release bez `act`.  
Uruchomienie:
```bash
./scripts/testing_workflows/test-semantic-release-local.sh azurerm_storage_account
```
Wymagania: Node.js, npm/npx.

### scripts/testing_workflows/test-readme-update.sh
Cel: symuluje aktualizacje root README dla kilku modulow (backup i restore).  
Uruchomienie:
```bash
./scripts/testing_workflows/test-readme-update.sh
```

### scripts/testing_workflows/test-readme-direct.sh
Cel: bezposredni test update root README na kopii pliku.  
Uruchomienie:
```bash
./scripts/testing_workflows/test-readme-direct.sh
```

### scripts/testing_workflows/test-table-update.py
Cel: test logiki aktualizacji tabeli modulow (symulacja).  
Uruchomienie:
```bash
python3 scripts/testing_workflows/test-table-update.py
```

### scripts/testing_workflows/test-readme-python.py
Cel: test aktualizacji README w Pythonie (symulacja).  
Uruchomienie:
```bash
python3 scripts/testing_workflows/test-readme-python.py
```

## Templates (scripts/templates)

Pliki w `scripts/templates` sa szablonami kopiowanymi przez
`scripts/create-new-module.sh`. Nie uruchamiaj ich z tego katalogu.
Wybrane skrypty, ktore po skopiowaniu uruchamia sie z poziomu modulu:

- `generate-docs.sh` - generuje dokumentacje modulu (terraform-docs).
- `run_tests_parallel.sh` - uruchamia testy modulowe rownolegle.
- `run_tests_sequential.sh` - uruchamia testy modulowe sekwencyjnie.
- `test_env.sh` - laduje zmienne srodowiskowe dla testow.
