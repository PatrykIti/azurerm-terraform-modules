# Fixtures i Uruchamianie Testów

Efektywne zarządzanie konfiguracjami testowymi (`fixtures`) oraz zautomatyzowane uruchamianie testów są kluczowe dla wydajnego procesu CI/CD. W tej sekcji opisujemy standardy dotyczące organizacji `fixtures` oraz wykorzystania `Makefile` i skryptów `bash` do orkiestracji testów.

## Organizacja Fixtures

Katalog `tests/fixtures` zawiera podkatalogi, z których każdy reprezentuje odrębny, izolowany scenariusz testowy w postaci kompletnej konfiguracji Terraform.

### Struktura Katalogu `fixtures`

```
tests/
└── fixtures/
    ├── simple/           # Minimalna, działająca konfiguracja modułu.
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── complete/         # Konfiguracja testująca wszystkie lub większość funkcji modułu.
    ├── security/         # Konfiguracja z maksymalnie restrykcyjnymi ustawieniami bezpieczeństwa.
    ├── network/          # Scenariusz testujący zaawansowane reguły sieciowe.
    ├── private_endpoint/ # Scenariusz z użyciem Private Endpoint.
    └── negative/         # Zbiór konfiguracji, które celowo są niepoprawne.
        ├── invalid_name_short/
        └── invalid_replication_type/
```

### Najlepsze Praktyki dla Fixtures

1.  **Lokalne źródło modułu**: Każdy `fixture` musi odwoływać się do testowanego modułu za pomocą ścieżki względnej, aby testować lokalne zmiany.
    ```hcl
    # fixtures/simple/main.tf
    module "storage_account" {
      source = "../../../" # Odwołanie do katalogu głównego modułu

      # ... zmienne
    }
    ```

2.  **Unikalne nazwy zasobów**: Używaj zmiennej `random_suffix`, przekazywanej z testu Go, do tworzenia unikalnych nazw zasobów.
    ```hcl
    # fixtures/simple/variables.tf
    variable "random_suffix" {
      type        = string
      description = "A random suffix to ensure unique resource names."
    }

    # fixtures/simple/main.tf
    resource "azurerm_resource_group" "test" {
      name     = "rg-test-${var.random_suffix}"
      location = var.location
    }
    ```

3.  **Minimalizm**: `Fixture` powinien zawierać tylko konfigurację niezbędną do przetestowania danego scenariusza. Unikaj dodawania niepowiązanych zasobów.

4.  **Wyjścia (Outputs)**: Każdy `fixture` musi definiować `outputs.tf`, które eksponują kluczowe atrybuty wdrożonych zasobów. Te wartości są następnie odczytywane i walidowane w testach Go.
    ```hcl
    # fixtures/simple/outputs.tf
    output "storage_account_id" {
      value = module.storage_account.id
    }

    output "storage_account_name" {
      value = module.storage_account.name
    }
    ```

## Uruchamianie Testów

Używamy `Makefile` jako głównego interfejsu do uruchamiania testów, co upraszcza i standaryzuje proces zarówno lokalnie, jak i w CI/CD.

### `Makefile`

Plik `Makefile` definiuje zestaw komend (targetów) do zarządzania cyklem życia testów.

**Kluczowe Targety (`modules/azurerm_storage_account/tests/Makefile`):**
```makefile
# Zmienne konfiguracyjne
TIMEOUT ?= 30m
PARALLEL ?= 8

# Sprawdzenie zmiennych środowiskowych
check-env:
	@test -n "$(AZURE_SUBSCRIPTION_ID)" || (echo "AZURE_SUBSCRIPTION_ID is not set" && exit 1)
    # ... (pozostałe zmienne)

# Instalacja zależności
deps:
	go mod download
	go mod tidy

# Uruchomienie wszystkich testów
test: check-env deps
	go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...

# Uruchomienie konkretnego testu
test-single: check-env deps
	go test -v -timeout $(TIMEOUT) -run $(TEST_NAME) ./...

# Uruchomienie testów z raportem pokrycia
test-coverage: check-env deps
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Generowanie raportu JUnit dla CI/CD
test-junit: check-env deps
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml

# Sprzątanie artefaktów
clean:
	rm -f coverage.out test-results.xml
	find . -name "*.tfstate*" -type f -delete
```

**Sposób użycia:**
```bash
# Uruchom wszystkie testy
make test

# Uruchom tylko testy podstawowe
make test-basic

# Uruchom konkretny test
make test-single TEST_NAME=TestStorageAccountSecurity

# Wygeneruj raport pokrycia kodu
make test-coverage
```

### Skrypty Uruchomieniowe (`run_tests_*.sh`)

Dla bardziej zaawansowanej orkiestracji, zwłaszcza w kontekście generowania szczegółowych raportów, używamy skryptów `bash`.

#### `run_tests_parallel.sh`

-   **Cel**: Uruchamia wszystkie zdefiniowane testy równolegle, każdy w osobnym procesie.
-   **Kluczowe cechy**:
    -   Uruchamia testy w tle (`&`).
    -   Zbiera PID-y procesów i czeka na ich zakończenie (`wait`).
    -   Dla każdego testu generuje osobny plik `.log` oraz `.json` z metadanymi (status, czas trwania, błąd).
    -   Na koniec tworzy zbiorczy plik `summary.json` z wynikami wszystkich testów.
    -   **Zawsze kończy się z kodem wyjścia 0**, aby w CI/CD można było przeanalizować pełny raport, nawet jeśli niektóre testy zawiodły.

#### `run_tests_sequential.sh`

-   **Cel**: Uruchamia testy jeden po drugim. Idealne do debugowania.
-   **Kluczowe cechy**:
    -   Uruchamia testy w pętli `for`.
    -   Wyświetla logi na żywo w konsoli (`tee`).
    -   Podobnie jak wersja równoległa, generuje indywidualne raporty JSON i zbiorcze podsumowanie.

### Konfiguracja Testów (`test_config.yaml`)

Ten plik pozwala na zdefiniowanie zestawów testów (`test suites`) i innych parametrów, które mogą być wykorzystane przez skrypty uruchomieniowe lub narzędzia CI/CD do dynamicznego budowania macierzy testów.

```yaml
# test_config.yaml
test_suites:
  - name: "Basic Tests"
    tests:
      - TestBasicStorageAccount
    parallel: true
    timeout: 15m
    
  - name: "Complete Feature Tests"
    tests:
      - TestCompleteStorageAccount
      - TestStorageAccountSecurity
    parallel: true
    timeout: 30m

coverage:
  enabled: true
  threshold: 80

reporting:
  format: junit
  output_dir: test-results/
```
Dzięki temu plikowi można łatwo zarządzać, które testy należą do jakiej kategorii (np. "szybkie", "pełne") bez modyfikowania skryptów.