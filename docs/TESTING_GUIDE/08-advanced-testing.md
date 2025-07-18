# Zaawansowane Scenariusze Testowe

Poza podstawowymi testami integracyjnymi, kluczowe jest pokrycie bardziej zaawansowanych scenariuszy, takich jak testy wydajności, bezpieczeństwa i zgodności z politykami.

## Testowanie Wydajności

Plik `performance_test.go` jest dedykowany do mierzenia i walidacji wydajności modułu.

### Benchmarki Czasu Tworzenia

Używamy wbudowanego w Go mechanizmu benchmarków do mierzenia czasu operacji `terraform apply`.

```go
// performance_test.go
func BenchmarkStorageAccountCreationSimple(b *testing.B) {
	b.ReportAllocs() // Raportuje alokacje pamięci

	for i := 0; i < b.N; i++ {
		b.StopTimer() // Zatrzymujemy timer na czas przygotowań
		// ... przygotowanie (kopiowanie fixture, ustawienie opcji)
		b.StartTimer() // Wznawiamy timer tuż przed operacją

		start := time.Now()
		terraform.InitAndApply(b, terraformOptions)
		creationTime := time.Since(start)

		b.StopTimer() // Zatrzymujemy ponownie na czas sprzątania
		terraform.Destroy(b, terraformOptions)
		b.StartTimer()

		// Raportujemy metrykę, która pojawi się w wynikach benchmarku
		b.ReportMetric(float64(creationTime.Milliseconds()), "creation_ms")
	}
}
```
-   **`b.N`**: Go automatycznie dostosowuje liczbę iteracji, aby uzyskać miarodajny wynik.
-   **`b.StopTimer()` / `b.StartTimer()`**: Kluczowe dla mierzenia tylko interesującego nas fragmentu kodu.
-   **`b.ReportMetric`**: Pozwala na dodanie niestandardowych metryk do wyników benchmarku.

### Testy Czasu Wdrożenia

Oprócz benchmarków, warto mieć standardowy test, który sprawdza, czy czas wdrożenia nie przekracza ustalonego progu (SLA).

```go
// performance_test.go
func TestStorageAccountCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	// ... przygotowanie
	
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Definiujemy maksymalny akceptowalny czas
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Storage account creation took %v, expected less than %v", duration, maxDuration)
}
```

## Testowanie Bezpieczeństwa i Zgodności

Te testy weryfikują, czy wdrożone zasoby spełniają standardy bezpieczeństwa i polityki firmowe.

### Statyczna Analiza Bezpieczeństwa (CI/CD)

Narzędzia takie jak `tfsec` i `checkov` są uruchamiane w pipeline CI/CD i stanowią pierwszą linię obrony.

### Testy Zgodności w Terratest

W `integration_test.go` możemy stworzyć test, który weryfikuje kluczowe aspekty bezpieczeństwa na wdrożonym zasobie.

```go
// integration_test.go
func TestStorageAccountCompliance(t *testing.T) {
	t.Parallel()
	// ... wdrożenie zasobu z fixture/security

	helper := NewStorageAccountHelper(t)
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// Definiujemy listę sprawdzeń zgodności
	complianceChecks := []struct {
		name      string
		check     func() bool
		message   string
	}{
		{
			name:    "HTTPS Only",
			check:   func() bool { return *account.Properties.EnableHTTPSTrafficOnly },
			message: "HTTPS-only traffic must be enforced",
		},
		{
			name:    "TLS Version",
			check:   func() bool { return *account.Properties.MinimumTLSVersion == armstorage.MinimumTLSVersionTLS12 },
			message: "Minimum TLS version must be 1.2",
		},
		// ... inne sprawdzenia
	}
	
	for _, cc := range complianceChecks {
		t.Run(cc.name, func(t *testing.T) {
			assert.True(t, cc.check(), cc.message)
		})
	}
}
```
Ten wzorzec pozwala na łatwe dodawanie nowych reguł zgodności w postaci małych, czytelnych funkcji.

## Testowanie Cyklu Życia (Lifecycle)

Testy cyklu życia weryfikują, jak zasób zachowuje się podczas aktualizacji i czy operacje są idempotentne.

```go
// integration_test.go
func TestStorageAccountLifecycle(t *testing.T) {
	// ...
	
	// 1. Początkowe wdrożenie
	terraform.InitAndApply(t, terraformOptions)
	
	// 2. Weryfikacja stanu początkowego
	accountBeforeUpdate := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.False(t, *accountBeforeUpdate.Properties.IsVersioningEnabled) // Zakładając, że domyślnie jest wyłączone

	// 3. Aktualizacja konfiguracji w zmiennych Terraform
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)

	// 4. Weryfikacja, czy zmiana została zastosowana
	accountAfterUpdate := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.True(t, *accountAfterUpdate.Properties.IsVersioningEnabled)

	// 5. Test na idempotentność
	// Uruchomienie apply ponownie z tymi samymi zmiennymi nie powinno nic zmienić
	exitCode := terraform.Apply(t, terraformOptions)
	assert.Equal(t, 0, exitCode, "Second apply should show no changes")
}
```

## Testy End-to-End (E2E)

Testy E2E weryfikują integrację kilku modułów. Chociaż nie ma dedykowanego pliku, można je umieścić w `integration_test.go` lub w osobnym katalogu na poziomie repozytorium.

**Przykład scenariusza E2E:**
1.  Wdróż moduł `azurerm_virtual_network`.
2.  Wdróż moduł `azurerm_storage_account` z `private_endpoint` w podsieci z kroku 1.
3.  Wdróż moduł `azurerm_virtual_machine` w innej podsieci.
4.  Użyj `terratest/modules/ssh` do połączenia się z VM.
5.  Z wewnątrz VM spróbuj połączyć się z prywatnym adresem IP konta magazynu, aby zweryfikować łączność.

Oprócz benchmarków, warto mieć standardowy test, który sprawdza, czy czas wdrożenia nie przekracza ustalonego progu (SLA).

```go
// performance_test.go
func TestStorageAccountCreationTime(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}
	t.Parallel()

	// ... przygotowanie
	
	start := time.Now()
	terraform.InitAndApply(t, terraformOptions)
	duration := time.Since(start)

	// Definiujemy maksymalny akceptowalny czas
	maxDuration := 5 * time.Minute
	require.LessOrEqual(t, duration, maxDuration,
		"Storage account creation took %v, expected less than %v", duration, maxDuration)
}
```

## Testowanie Bezpieczeństwa i Zgodności

Te testy weryfikują, czy wdrożone zasoby spełniają standardy bezpieczeństwa i polityki firmowe.

### Statyczna Analiza Bezpieczeństwa (CI/CD)

Narzędzia takie jak `tfsec` i `checkov` są uruchamiane w pipeline CI/CD i stanowią pierwszą linię obrony.

### Testy Zgodności w Terratest

W `integration_test.go` możemy stworzyć test, który weryfikuje kluczowe aspekty bezpieczeństwa na wdrożonym zasobie.

```go
// integration_test.go
func TestStorageAccountCompliance(t *testing.T) {
	t.Parallel()
	// ... wdrożenie zasobu z fixture/security

	helper := NewStorageAccountHelper(t)
	account := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	
	// Definiujemy listę sprawdzeń zgodności
	complianceChecks := []struct {
		name      string
		check     func() bool
		message   string
	}{
		{
			name:    "HTTPS Only",
			check:   func() bool { return *account.Properties.EnableHTTPSTrafficOnly },
			message: "HTTPS-only traffic must be enforced",
		},
		{
			name:    "TLS Version",
			check:   func() bool { return *account.Properties.MinimumTLSVersion == armstorage.MinimumTLSVersionTLS12 },
			message: "Minimum TLS version must be 1.2",
		},
		// ... inne sprawdzenia
	}
	
	for _, cc := range complianceChecks {
		t.Run(cc.name, func(t *testing.T) {
			assert.True(t, cc.check(), cc.message)
		})
	}
}
```
Ten wzorzec pozwala na łatwe dodawanie nowych reguł zgodności w postaci małych, czytelnych funkcji.

## Testowanie Cyklu Życia (Lifecycle)

Testy cyklu życia weryfikują, jak zasób zachowuje się podczas aktualizacji i czy operacje są idempotentne.

```go
// integration_test.go
func TestStorageAccountLifecycle(t *testing.T) {
	// ...
	
	// 1. Początkowe wdrożenie
	terraform.InitAndApply(t, terraformOptions)
	
	// 2. Weryfikacja stanu początkowego
	accountBeforeUpdate := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.False(t, *accountBeforeUpdate.Properties.IsVersioningEnabled) // Zakładając, że domyślnie jest wyłączone

	// 3. Aktualizacja konfiguracji w zmiennych Terraform
	terraformOptions.Vars["enable_blob_versioning"] = true
	terraform.Apply(t, terraformOptions)

	// 4. Weryfikacja, czy zmiana została zastosowana
	accountAfterUpdate := helper.GetStorageAccountProperties(t, storageAccountName, resourceGroupName)
	assert.True(t, *accountAfterUpdate.Properties.IsVersioningEnabled)

	// 5. Test na idempotentność
	// Uruchomienie apply ponownie z tymi samymi zmiennymi nie powinno nic zmienić
	exitCode := terraform.Apply(t, terraformOptions)
	assert.Equal(t, 0, exitCode, "Second apply should show no changes")
}
```

## Testy End-to-End (E2E)

Testy E2E weryfikują integrację kilku modułów. Chociaż nie ma dedykowanego pliku, można je umieścić w `integration_test.go` lub w osobnym katalogu na poziomie repozytorium.

**Przykład scenariusza E2E:**
1.  Wdróż moduł `azurerm_virtual_network`.
2.  Wdróż moduł `azurerm_storage_account` z `private_endpoint` w podsieci z kroku 1.
3.  Wdróż moduł `azurerm_virtual_machine` w innej podsieci.
4.  Użyj `terratest/modules/ssh` do połączenia się z VM.
5.  Z wewnątrz VM spróbuj połączyć się z prywatnym adresem IP konta magazynu, aby zweryfikować łączność.