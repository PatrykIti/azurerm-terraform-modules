# Wzorzec Helpera i Funkcje Walidacyjne

Plik `test_helpers.go` jest fundamentem reużywalności i czytelności w naszych testach integracyjnych. Zamiast umieszczać logikę interakcji z Azure SDK i powtarzalne fragmenty kodu bezpośrednio w plikach testowych, centralizujemy je w helperach. Poniżej opisano standardowy wzorzec i najlepsze praktyki.

## Wzorzec Klasy Pomocniczej (Helper Pattern)

Dla każdego testowanego modułu tworzymy dedykowaną strukturę (klasę) pomocniczą, która enkapsuluje logikę specyficzną dla danego zasobu.

### Definicja Struktury

Struktura przechowuje uwierzytelnione klienty Azure SDK oraz inne niezbędne informacje, takie jak ID subskrypcji.

**Przykład (`test_helpers.go` dla `azurerm_storage_account`):**
```go
// StorageAccountHelper provides helper methods for storage account testing
type StorageAccountHelper struct {
	subscriptionID string
	credential     azcore.TokenCredential
	client         *armstorage.AccountsClient
	blobClient     *armstorage.BlobServicesClient
}
```
-   `subscriptionID`: Przechowuje ID subskrypcji, aby uniknąć wielokrotnego odczytywania go ze zmiennych środowiskowych.
-   `credential`: Przechowuje obiekt `TokenCredential` z Azure SDK, używany do uwierzytelniania wszystkich klientów.
-   `client`, `blobClient`: Przechowują instancje klientów SDK specyficznych dla zasobu (w tym przypadku `AccountsClient` i `BlobServicesClient`).

### Inicjalizacja Helpera

Funkcja fabryczna `New...Helper` jest odpowiedzialna za:
1.  Odczytanie niezbędnych zmiennych środowiskowych.
2.  Utworzenie obiektu `credential` (obsługując różne metody uwierzytelniania).
3.  Inicjalizację wszystkich potrzebnych klientów SDK.
4.  Zwrócenie w pełni skonfigurowanej instancji helpera.

```go
// NewStorageAccountHelper creates a new helper instance
func NewStorageAccountHelper(t *testing.T) *StorageAccountHelper {
	subscriptionID := getRequiredEnvVar(t, "AZURE_SUBSCRIPTION_ID")
	
	// Logika uwierzytelniania (Service Principal, Azure CLI, Default)
	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create credential")

	// Inicjalizacja klientów
	client, err := armstorage.NewAccountsClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create storage accounts client")
	
	blobClient, err := armstorage.NewBlobServicesClient(subscriptionID, credential, nil)
	require.NoError(t, err, "Failed to create blob services client")

	return &StorageAccountHelper{
		subscriptionID: subscriptionID,
		credential:     credential,
		client:         client,
		blobClient:     blobClient,
	}
}
```

## Funkcje Walidacyjne

Metody walidacyjne są kluczową częścią helpera. Ich zadaniem jest weryfikacja, czy wdrożony zasób ma oczekiwaną konfigurację.

### Najlepsze Praktyki
-   **Jedna odpowiedzialność**: Każda funkcja powinna walidować jeden logiczny aspekt zasobu (np. szyfrowanie, reguły sieciowe).
-   **Przyjmowanie obiektu zasobu**: Funkcje powinny przyjmować jako argument obiekt zasobu pobrany z Azure SDK (np. `armstorage.Account`), a nie tylko jego nazwę. To zmniejsza liczbę wywołań API.
-   **Użycie `require` i `assert`**: Używaj `require` dla krytycznych asercji, które muszą być spełnione, aby kontynuować test (np. `require.NotNil`). Używaj `assert` dla pozostałych sprawdzeń.
-   **Czytelne komunikaty o błędach**: Każda asercja powinna mieć jasny komunikat, co poszło nie tak.

### Przykłady Funkcji Walidacyjnych

#### Walidacja Szyfrowania
```go
// ValidateStorageAccountEncryption validates encryption settings
func (h *StorageAccountHelper) ValidateStorageAccountEncryption(t *testing.T, account armstorage.Account) {
	require.NotNil(t, account.Properties.Encryption, "Encryption should be configured")
	require.Equal(t, armstorage.KeySourceMicrosoftStorage, *account.Properties.Encryption.KeySource, "Should use Microsoft managed keys")
	
	// Validate blob encryption
	require.NotNil(t, account.Properties.Encryption.Services.Blob, "Blob encryption should be configured")
	assert.True(t, *account.Properties.Encryption.Services.Blob.Enabled, "Blob encryption should be enabled")
}
```

#### Walidacja Reguł Sieciowych
```go
// ValidateNetworkRules validates network access rules
func (h *StorageAccountHelper) ValidateNetworkRules(t *testing.T, account armstorage.Account, expectedIPRules []string) {
	require.NotNil(t, account.Properties.NetworkRuleSet, "Network rules should be configured")
	assert.Equal(t, armstorage.DefaultActionDeny, *account.Properties.NetworkRuleSet.DefaultAction)
	
	// Validate IP rules
	require.Equal(t, len(expectedIPRules), len(account.Properties.NetworkRuleSet.IPRules), "IP rules count mismatch")
	
	actualIPRules := make([]string, 0)
	for _, rule := range account.Properties.NetworkRuleSet.IPRules {
		actualIPRules = append(actualIPRules, *rule.IPAddressOrRange)
	}
	
	for _, expectedIP := range expectedIPRules {
		require.Contains(t, actualIPRules, expectedIP, "Expected IP rule not found")
	}
}
```

## Funkcje Oczekujące (Waiters)

Niektóre operacje w Azure są asynchroniczne. Funkcje oczekujące używają mechanizmu `retry` z Terratest, aby cyklicznie sprawdzać stan zasobu, aż osiągnie on pożądany stan lub upłynie limit czasu.

```go
// WaitForGRSSecondaryEndpoints waits for GRS secondary endpoints to be available
func (h *StorageAccountHelper) WaitForGRSSecondaryEndpoints(t *testing.T, accountName, resourceGroupName string) {
	description := fmt.Sprintf("Waiting for GRS secondary endpoints for storage account %s", accountName)
	
	retry.DoWithRetry(t, description, 60, 10*time.Second, func() (string, error) {
		account := h.GetStorageAccountProperties(t, accountName, resourceGroupName)
		
		if account.Properties.SecondaryEndpoints != nil && account.Properties.SecondaryEndpoints.Blob != nil && *account.Properties.SecondaryEndpoints.Blob != "" {
			return "GRS secondary endpoints are available", nil
		}
		
		return "", fmt.Errorf("GRS secondary endpoints are not yet available")
	})
}
```
-   `retry.DoWithRetry`: Funkcja z Terratest.
-   `description`: Czytelny komunikat logowany podczas każdej próby.
-   `60`: Maksymalna liczba prób.
-   `10*time.Second`: Czas oczekiwania między próbami.
-   Funkcja anonimowa zawiera logikę sprawdzającą. Zwraca `nil` jako błąd, jeśli warunek jest spełniony, co kończy pętlę.

## Ogólne Funkcje Pomocnicze

Oprócz metod w helperze, plik `test_helpers.go` zawiera również globalne funkcje pomocnicze.

### Fabryka `terraform.Options`

Funkcja `getTerraformOptions` centralizuje tworzenie konfiguracji dla Terratest, zapewniając spójność.

```go
// getTerraformOptions helper function to get terraform options
func getTerraformOptions(t testing.TB, terraformDir string) *terraform.Options {
	randomSuffix := strings.ToLower(random.UniqueId())
	
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"random_suffix": randomSuffix,
			"location":      "northeurope",
		},
		NoColor: true,
		// Konfiguracja ponowień dla błędów przejściowych
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                    "Timeout error - retrying",
			".*ResourceGroupNotFound.*":      "Resource group not found - retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}
}
```
-   **Unikalne nazwy**: Automatycznie generuje `random_suffix` i przekazuje go do zmiennych Terraform.
-   **Konfiguracja ponowień**: Definiuje, które błędy Terraform powinny być ponawiane (np. problemy z siecią, błędy `Eventually Consistent`).

### Odczyt Zmiennych Środowiskowych

```go
// getRequiredEnvVar gets a required environment variable or fails the test
func getRequiredEnvVar(t *testing.T, envVarName string) string {
	value := os.Getenv(envVarName)
	require.NotEmpty(t, value, fmt.Sprintf("Required environment variable %s is not set", envVarName))
	return value
}
```
Ta prosta funkcja zapewnia, że test zakończy się niepowodzeniem, jeśli brakuje kluczowej zmiennej środowiskowej, zamiast kontynuować z nieprzewidywalnymi błędami.