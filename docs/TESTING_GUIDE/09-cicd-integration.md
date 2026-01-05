# CI/CD Integration

Automated tests run in GitHub Actions via two workflows:

1) **PR Validation** (`.github/workflows/pr-validation.yml`)  
   Fast checks for affected modules:
   - `terraform fmt -check -recursive`
   - `terraform init -backend=false` + `terraform validate`
   - `terraform test -test-directory=tests/unit`

2) **Module CI** (`.github/workflows/module-ci.yml`)  
   Full module validation, integration tests, and security scanning:
   - `validate` action (fmt, validate, tflint, example validation)
   - `test` action (Go-based Terratest via `go test`)
   - `security` action (tfsec + checkov in Docker, SARIF upload)

---

## Module Detection

Both workflows detect modules dynamically:

- **PR title scope**: uses `commit_scope` from `module.json` to map scopes to modules.
- **Path changes**: uses generated filters from `modules/*` to select changed modules.

If your PR title uses a new `commit_scope`, add it to the allowlist in
`.github/workflows/pr-validation.yml` to satisfy title validation.

---

## Module CI Execution Details

Module CI uses the composite action `./.github/actions/module-runner`:

- **validate**: `terraform fmt`, `terraform init`, `terraform validate`, `tflint`,
  and example validation.
- **test**: runs `go test -v -timeout 30m` in the module `tests/` directory if Go tests exist.
- **security**: runs `tfsec` and `checkov` via Docker and uploads SARIF.

`workflow_dispatch` supports inputs (`test_type`, `module`), but the current
module-runner always runs full `go test` when invoked.

---

## Authentication

### AzureRM modules

`module-ci.yml` uses `azure/login@v2` with OIDC and passes Azure credentials
to tests via environment variables:

- `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_CLIENT_SECRET`
- `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_SECRET`
- `ARM_USE_OIDC` (true when no client secret is supplied)

### Azure DevOps modules

Azure DevOps tests rely on:

- `AZDO_ORG_SERVICE_URL`
- `AZDO_PERSONAL_ACCESS_TOKEN`
- `AZDO_PROJECT_ID`

These are provided via GitHub secrets in `module-ci.yml` and consumed by test helpers.

---

## Reporting

Module CI does not generate JUnit reports by default. Test results are visible in
job logs. If you need JUnit output, use your module `tests/Makefile` locally.
