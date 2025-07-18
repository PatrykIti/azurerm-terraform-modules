# Integracja z CI/CD

Automatyzacja testów w ramach pipeline'u CI/CD jest kluczowa dla zapewnienia jakości i bezpieczeństwa modułów. Używamy GitHub Actions do orkiestracji całego procesu.

## Struktura Workflow

Główny workflow (`.github/workflows/module-ci.yml`) jest zaprojektowany tak, aby dynamicznie wykrywać zmiany w modułach i uruchamiać dla nich odpowiednie zestawy testów równolegle.

```yaml
# .github/workflows/module-ci.yml
name: Module CI

on:
  pull_request:
    paths:
      - 'modules/**'
  push:
    branches: [ main, release/** ]

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      modules: ${{ steps.filter.outputs.changes }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            storage_account: modules/azurerm_storage_account/**
            # ... inne moduły

  unit-test:
    needs: detect-changes
    if: ${{ needs.detect-changes.outputs.modules != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: ${{ fromJson(needs.detect-changes.outputs.modules) }}
    steps:
      - name: Run unit tests
        run: |
          cd modules/azurerm_${{ matrix.module }}
          terraform test -test-directory=tests/unit

  integration-test:
    needs: [detect-changes, unit-test]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: ${{ fromJson(needs.detect-changes.outputs.modules) }}
    steps:
      - name: Run integration tests
        run: |
          cd modules/azurerm_${{ matrix.module }}/tests
          make test-junit
```

### Kluczowe Elementy Workflow

1.  **`detect-changes`**: Ten job używa akcji `dorny/paths-filter`, aby zidentyfikować, które katalogi modułów zostały zmodyfikowane w danym commicie lub pull requeście. Wynik jest przekazywany do kolejnych jobów jako macierz (`matrix`).
2.  **`strategy: matrix`**: Pozwala na dynamiczne tworzenie jobów dla każdego zmienionego modułu. Jeśli zmieniono 3 moduły, GitHub Actions uruchomi 3 równoległe joby `unit-test` i 3 `integration-test`.
3.  **Równoległość**: Dzięki macierzy, testy dla różnych modułów nie blokują się nawzajem, co drastycznie skraca czas oczekiwania na wyniki.
4.  **Zależności (`needs`)**: Job `integration-test` zależy od `unit-test`, co zapewnia, że kosztowne testy integracyjne są uruchamiane tylko wtedy, gdy szybkie testy jednostkowe zakończą się sukcesem.

## Uwierzytelnianie w Azure

W CI/CD używamy **OpenID Connect (OIDC)** do bezpiecznego uwierzytelniania w Azure bez przechowywania statycznych sekretów.

```yaml
# Krok w jobie integration-test
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

# Zmienne środowiskowe przekazywane do testów Go
env:
  ARM_USE_OIDC: true
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```
-   Akcja `azure/login@v1` uzyskuje tymczasowy token dostępu.
-   Zmienna `ARM_USE_OIDC: true` informuje providera Terraform oraz nasze helpery w Go, aby używały uwierzytelniania OIDC.

## Raportowanie Wyników Testów

Aby uzyskać czytelne wyniki testów, zwłaszcza w przypadku błędów, generujemy raporty w formacie JUnit XML.

### Generowanie Raportu

W `Makefile` znajduje się target `test-junit`, który:
1.  Instaluje narzędzie `go-junit-report`.
2.  Uruchamia `go test`.
3.  Przekierowuje standardowe wyjście i błędy do `go-junit-report`, które konwertuje je na format XML.

```makefile
# Makefile
test-junit: check-env deps
	@echo "Running tests with JUnit output..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v -timeout $(TIMEOUT) ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml
```

### Publikowanie Raportu w GitHub Actions

Następnie, w workflow CI/CD, używamy akcji do publikowania tych wyników.

```yaml
# Krok w jobie integration-test
- name: Publish Test Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always() # Uruchamiaj ten krok zawsze, nawet jeśli testy zawiodły
  with:
    files: |
      **/test-results.xml
```
-   `if: always()`: Gwarantuje, że raport zostanie opublikowany, co jest kluczowe do analizy błędów.
-   Akcja automatycznie parsuje pliki XML i wyświetla podsumowanie bezpośrednio w interfejsie GitHub Actions, a także w pull requeście.