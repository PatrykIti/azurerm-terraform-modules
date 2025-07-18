# Struktura Plików Terratest

Utrzymanie spójnej i logicznej struktury plików w katalogu `tests` jest kluczowe dla czytelności, skalowalności i łatwości utrzymania testów integracyjnych. Poniższy wzorzec, oparty na implementacji w module `azurerm_storage_account`, jest standardem dla wszystkich modułów w tym repozytorium.

## Wzorcowa Struktura Katalogu `tests`

```
tests/
├── fixtures/                    # Konfiguracje Terraform dla różnych scenariuszy testowych
│   ├── simple/                  # Minimalna, podstawowa konfiguracja
│   ├── complete/                # Konfiguracja ze wszystkimi funkcjami
│   ├── security/                # Konfiguracja z naciskiem na bezpieczeństwo
│   ├── network/                 # Scenariusze sieciowe
│   ├── private_endpoint/        # Testy z użyciem Private Endpoint
│   └── negative/                # Scenariusze, które mają zakończyć się błędem
├── unit/                        # Testy jednostkowe (Native Terraform Tests)
├── go.mod                       # Definicja modułu Go i zależności
├── go.sum                       # Sumy kontrolne zależności
├── Makefile                     # Skrypty pomocnicze do uruchamiania testów
├── storage_account_test.go      # Główne testy dla podstawowych scenariuszy
├── integration_test.go          # Bardziej złożone testy integracyjne i cyklu życia
├── performance_test.go          # Testy wydajnościowe i benchmarki
├── test_helpers.go              # Funkcje pomocnicze, walidacyjne i klienty Azure SDK
├── test_config.yaml             # Konfiguracja zestawów testów dla CI/CD
├── test_env.sh                  # Skrypt do ustawiania zmiennych środowiskowych
├── run_tests_parallel.sh        # Skrypt do równoległego uruchamiania testów
├── run_tests_sequential.sh      # Skrypt do sekwencyjnego uruchamiania testów
└── test_outputs/                # Katalog na wyniki testów (ignorowany przez Git)
    └── .gitkeep
```

## Szczegółowy Opis Plików Go

### 1. `{module_name}_test.go` (np. `storage_account_test.go`)

-   **Cel**: Główny plik testowy dla modułu. Zawiera testy dla podstawowych i najważniejszych scenariuszy.
-   **Zawartość**:
    -   Funkcje testowe (`Test...`) dla każdego głównego `fixture`, np. `TestBasicStorageAccount`, `TestCompleteStorageAccount`, `TestStorageAccountSecurity`.
    -   Każda funkcja testowa powinna być niezależna i używać `t.Parallel()`.
    -   Orkiestracja cyklu życia testu: `Setup` -> `Deploy` -> `Validate` -> `Cleanup` przy użyciu `test_structure`.
    -   Podstawowe asercje na wartościach wyjściowych (`outputs`) z Terraform.
    -   Wywołania bardziej szczegółowych funkcji walidacyjnych z `test_helpers.go`.

**Przykład (`storage_account_test.go`):**
```go
func TestBasicStorageAccount(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "azurerm_storage_account/tests/fixtures/simple")
	
	defer test_structure.RunTestStage(t, "cleanup", func() {
		terraform.Destroy(t, getTerraformOptions(t, testFolder))
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := getTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
		// ... dalsza walidacja
	})
}
```

### 2. `integration_test.go`

-   **Cel**: Zawiera bardziej zaawansowane testy, które sprawdzają integrację różnych funkcji, cykl życia zasobu lub specyficzne scenariusze.
-   **Zawartość**:
    -   Testy `lifecycle`: Sprawdzanie, czy `terraform apply` na tej samej konfiguracji nie powoduje zmian (idempotentność) oraz czy aktualizacje zasobu działają poprawnie.
    -   Testy scenariuszy `Disaster Recovery`, np. weryfikacja `RA-GRS`.
    -   Testy zgodności (`compliance`), które weryfikują zestaw reguł bezpieczeństwa.
    -   Testy, które mogą wymagać dłuższego czasu wykonania i są oznaczane do pominięcia w trybie `short` (`if testing.Short() { t.Skip(...) }`).

**Przykład (`integration_test.go`):**
```go
func TestStorageAccountLifecycle(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}
	t.Parallel()

	// ...
	// 1. Początkowe wdrożenie
	terraform.InitAndApply(t, terraformOptions)
	
	// 2. Aktualizacja konfiguracji
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)

	// 3. Weryfikacja aktualizacji
	helper.ValidateBlobServiceProperties(t, storageAccountName, resourceGroupName)
}
```

### 3. `performance_test.go`

-   **Cel**: Zawiera testy wydajnościowe i benchmarki.
-   **Zawartość**:
    -   Benchmarki Go (`Benchmark...`) do mierzenia czasu tworzenia zasobów w różnych konfiguracjach.
    -   Testy walidujące, czy czas tworzenia zasobu mieści się w akceptowalnych granicach (np. poniżej 5 minut).
    -   Testy skalowalności, np. tworzenie wielu zasobów równolegle.
    -   Wszystkie testy w tym pliku powinny być pomijane w trybie `short`.

**Przykład (`performance_test.go`):**
```go
func BenchmarkStorageAccountCreationSimple(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer()
		// ... przygotowanie
		b.StartTimer()

		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		creationTime := time.Since(start)

		b.StopTimer()
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()

		b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
	}
}
```

### 4. `test_helpers.go`

-   **Cel**: Centralne miejsce na współdzielone funkcje pomocnicze, aby unikać duplikacji kodu (`DRY`).
-   **Zawartość**:
    -   **Klasa pomocnicza (Helper Class)**: Wzorzec, w którym tworzymy strukturę (np. `StorageAccountHelper`) przechowującą klienty Azure SDK i logikę specyficzną dla danego zasobu.
    -   **Funkcje inicjalizujące**: `NewStorageAccountHelper` do tworzenia instancji helpera i inicjalizacji klientów SDK.
    -   **Funkcje walidacyjne**: `ValidateStorageAccountEncryption`, `ValidateNetworkRules` - funkcje, które przyjmują obiekt zasobu z SDK i dokonują na nim asercji.
    -   **Funkcje oczekujące (Waiters)**: `WaitForStorageAccountReady`, `WaitForGRSSecondaryEndpoints` - funkcje, które używają pętli `retry` do oczekiwania na osiągnięcie przez zasób pożądanego stanu.
    -   **Funkcje pomocnicze Terratest**: `getTerraformOptions` - funkcja fabryczna do tworzenia spójnej konfiguracji `terraform.Options` dla wszystkich testów.

Ten plik jest sercem testów integracyjnych i jego dobra organizacja jest kluczowa. Zostanie on szczegółowo omówiony w kolejnej sekcji.

