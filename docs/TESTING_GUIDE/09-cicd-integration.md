# CI/CD Integration

Automating tests within a CI/CD pipeline is crucial for ensuring the quality and security of modules. We use GitHub Actions to orchestrate the entire process.

## Workflow Structure

The main workflow (`.github/workflows/module-ci.yml`) is designed to dynamically detect changes in modules and run the appropriate test suites for them in parallel.

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
            # ... other modules

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

### Key Workflow Elements

1.  **`detect-changes`**: This job uses the `dorny/paths-filter` action to identify which module directories have been modified in a given commit or pull request. The result is passed to subsequent jobs as a matrix.
2.  **`strategy: matrix`**: Allows for the dynamic creation of jobs for each changed module. If 3 modules are changed, GitHub Actions will run 3 parallel `unit-test` jobs and 3 `integration-test` jobs.
3.  **Parallelism**: Thanks to the matrix, tests for different modules do not block each other, which drastically reduces the waiting time for results.
4.  **Dependencies (`needs`)**: The `integration-test` job depends on `unit-test`, ensuring that expensive integration tests are only run if the fast unit tests succeed.

## Authentication in Azure

In CI/CD, we use **OpenID Connect (OIDC)** for secure authentication in Azure without storing static secrets.

```yaml
# Step in the integration-test job
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

# Environment variables passed to Go tests
env:
  ARM_USE_OIDC: true
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```
-   The `azure/login@v1` action obtains a temporary access token.
-   The `ARM_USE_OIDC: true` variable informs the Terraform provider and our Go helpers to use OIDC authentication.

## Reporting Test Results

To get clear test results, especially in case of failures, we generate reports in JUnit XML format.

### Generating the Report

The `Makefile` contains a `test-junit` target that:
1.  Installs the `go-junit-report` tool.
2.  Runs `go test`.
3.  Redirects standard output and errors to `go-junit-report`, which converts them to XML format.

```makefile
# Makefile
test-junit: check-env deps
	@echo "Running tests with JUnit output..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v -timeout $(TIMEOUT) ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml
```

### Publishing the Report in GitHub Actions

Then, in the CI/CD workflow, we use an action to publish these results.

```yaml
# Step in the integration-test job
- name: Publish Test Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always() # Always run this step, even if tests failed
  with:
    files: |
      **/test-results.xml
```
-   `if: always()`: Guarantees that the report will be published, which is crucial for analyzing failures.
-   The action automatically parses the XML files and displays a summary directly in the GitHub Actions interface, as well as in the pull request.
