# Integracja z Terratest (Testy Integracyjne)

Testy integracyjne stanowią trzeci poziom piramidy testów i są kluczowe dla weryfikacji, czy moduły Terraform poprawnie tworzą i konfigurują rzeczywistą infrastrukturę w Azure. W tym celu wykorzystujemy framework **Terratest** napisany w języku Go.

## Kiedy używać Terratest?

Terratest jest idealnym narzędziem do scenariuszy, których nie da się sprawdzić za pomocą statycznej analizy lub testów jednostkowych. Główne zastosowania to:

- ✅ **Weryfikacja poprawności wdrożenia**: Sprawdzanie, czy zasoby zostały utworzone z prawidłowymi właściwościami (SKU, lokalizacja, nazwa).
- ✅ **Testowanie reguł sieciowych**: Weryfikacja, czy reguły NSG, firewalla, czy private endpoints działają zgodnie z oczekiwaniami.
- ✅ **Walidacja uprawnień IAM**: Sprawdzanie, czy przypisane role i uprawnienia (RBAC) pozwalają na zamierzone akcje.
- ✅ **Testowanie interakcji między zasobami**: Weryfikacja, czy np. maszyna wirtualna może połączyć się z bazą danych przez prywatny link.
- ✅ **Sprawdzanie zgodności z Azure Policy**: Weryfikacja, czy wdrożona infrastruktura jest zgodna z przypisanymi politykami.

## Wymagane narzędzia i zależności

Aby uruchomić testy integracyjne, środowisko deweloperskie musi być wyposażone w:

1.  **Go**: Wersja 1.21 lub nowsza.
2.  **Terraform**: Wersja 1.5.0 lub nowsza.
3.  **Azure CLI**: Do uwierzytelniania i interakcji z Azure.
4.  **Kluczowe pakiety Go**: Zależności są zarządzane przez `go.mod`.

### Główne zależności w `go.mod`

Plik `go.mod` w katalogu `tests` definiuje kluczowe biblioteki. Najważniejsze z nich to:

```go
module github.com/example/azurerm-storage-account/tests

go 1.21

require (
	github.com/Azure/azure-sdk-for-go/sdk/azcore v1.9.0
	github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.4.0
	github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/storage/armstorage v1.5.0
	github.com/gruntwork-io/terratest v0.46.7
	github.com/stretchr/testify v1.8.4
)
```

-   **`github.com/gruntwork-io/terratest`**: Główny framework do testowania infrastruktury. Dostarcza funkcje do uruchamiania poleceń Terraform (`terraform init`, `apply`, `destroy`) i walidacji wyników.
-   **`github.com/stretchr/testify`**: Popularny pakiet do asercji w Go. Używamy go do sprawdzania warunków (np. `assert.Equal`, `require.NoError`).
-   **`github.com/Azure/azure-sdk-for-go/sdk/*`**: Nowy Azure SDK dla Go. Używamy go do bezpośredniej interakcji z API Azure w celu weryfikacji stanu zasobów po ich utworzeniu przez Terraform.

## Uwierzytelnianie

Testy Terratest wymagają uwierzytelnienia w Azure. Nasze skrypty i helpery wspierają kilka metod, z których korzystają w następującej kolejności:

1.  **Service Principal (Zmienne środowiskowe)**: Preferowana metoda w CI/CD.
    - `AZURE_CLIENT_ID`
    - `AZURE_CLIENT_SECRET`
    - `AZURE_TENANT_ID`
    - `AZURE_SUBSCRIPTION_ID`
2.  **Azure CLI**: Domyślna metoda dla lokalnego developmentu, jeśli powyższe zmienne nie są ustawione. Wystarczy być zalogowanym przez `az login`.
3.  **Default Azure Credential**: Ostateczna metoda, która próbuje różnych mechanizmów (Managed Identity, itp.).

Plik `test_env.sh` służy do lokalnego ustawiania tych zmiennych. **Nigdy nie należy umieszczać w nim prawdziwych danych uwierzytelniających w systemie kontroli wersji.**

```bash
# modules/azurerm_storage_account/tests/test_env.sh
#!/bin/bash
# Azure credentials for testing
export AZURE_CLIENT_ID="YOUR_AZURE_CLIENT_ID_HERE"
export AZURE_CLIENT_SECRET="YOUR_AZURE_CLIENT_SECRET_HERE"
export AZURE_SUBSCRIPTION_ID="YOUR_AZURE_SUBSCRIPTION_ID_HERE"
export AZURE_TENANT_ID="YOUR_AZURE_TENANT_ID_HERE"

# ARM_ prefixed variables for Terraform provider
export ARM_CLIENT_ID="${AZURE_CLIENT_ID}"
export ARM_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_TENANT_ID}"
```

## Podstawowy cykl życia testu

Każdy test integracyjny z Terratestem przebiega według następującego schematu:

1.  **Setup (Przygotowanie)**:
    - Test kopiuje odpowiednią konfigurację Terraform (tzw. `fixture`) do tymczasowego katalogu.
    - Generowane są unikalne nazwy dla zasobów, aby uniknąć konfliktów podczas równoległego uruchamiania testów.
2.  **Deploy (Wdrożenie)**:
    - Uruchamiane są komendy `terraform init` i `terraform apply` w celu wdrożenia infrastruktury.
3.  **Validate (Walidacja)**:
    - Odczytywane są wartości wyjściowe (`outputs`) z wdrożonej konfiguracji.
    - Za pomocą Azure SDK i asercji sprawdzany jest stan i konfiguracja wdrożonych zasobów.
4.  **Cleanup (Sprzątanie)**:
    - Uruchamiana jest komenda `terraform destroy`, aby usunąć wszystkie zasoby utworzone podczas testu. Ten krok jest wykonywany zawsze, nawet jeśli test się nie powiedzie, dzięki użyciu `defer`.

Ten cykl zapewnia, że testy są **izolowane**, **powtarzalne** i **nie pozostawiają po sobie zbędnych zasobów**, co jest kluczowe dla kontroli kosztów.