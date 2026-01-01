# 10. New Module Checklist

Before submitting a pull request for a new module, please review this checklist to ensure that all repository standards and requirements have been met.

## Module Structure & Files

- [ ] Module directory is named correctly (`azurerm_<resource_type>` or `azuredevops_<resource_type>`).
- [ ] All required files and directories are present as per the [Module Structure guide](./02-module-structure.md).
- [ ] `versions.tf` is present and pins the `azurerm` provider version.
- [ ] `variables.tf` is complete with descriptions and validation for all variables.
- [ ] `main.tf` contains the core module logic.
- [ ] `outputs.tf` provides clear, described outputs for all relevant resources.
- [ ] `locals` are used for computed values or complex logic (in `main.tf` or `locals.tf`, if applicable).

## Configuration

- [ ] `module.json` is created and correctly populated (`name`, `title`, `commit_scope`, `tag_prefix`).
- [ ] `.releaserc.js` is present and copied from a reference module.
- [ ] `.terraform-docs.yml` is configured to generate the `README.md`.

## Documentation

- [ ] `README.md` is generated and includes all required sections.
- [ ] `docs/README.md` is present for complex modules and linked from the module `README.md` (optional for simple modules).
- [ ] `docs/IMPORT.md` is present and aligned with the basic example.
- [ ] `CONTRIBUTING.md` is present and tailored to the module.
- [ ] `SECURITY.md` is present and details the module's security features.
- [ ] `VERSIONING.md` is present and explains the versioning strategy.
- [ ] All `examples` have their own `README.md`.

## Examples

- [ ] `basic` example exists and is linked in the main `README.md`.
- [ ] `complete` example exists, demonstrating advanced features.
- [ ] `secure` example exists, demonstrating a security-hardened configuration.
- [ ] All examples are self-contained and runnable.
- [ ] Each example includes its own `.terraform-docs.yml` (AKS pattern).

## Testing

- [ ] Unit tests (`.tftest.hcl`) are implemented in `tests/unit/` for variables and logic.
- [ ] Integration tests (Terratest) are implemented in `tests/` for all major scenarios (basic, complete, secure).
- [ ] Test fixtures are organized correctly in `tests/fixtures/`.
- [ ] `tests/Makefile` is present to orchestrate test execution.
- [ ] All tests pass locally (`make test`).

## Automation

- [ ] A root `Makefile` is present in the module directory.
- [ ] `make docs` successfully generates the `README.md`.
- [ ] `make validate` passes without errors.
- [ ] `make security` passes without any high or critical severity findings.
- [ ] `make check` (or `make all`) completes successfully.

## Code Quality & Commits

- [ ] Code is formatted with `terraform fmt`.
- [ ] No hardcoded secrets or sensitive data are present.
- [ ] Variables and resources use clear, consistent naming.
- [ ] Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) standard with the correct scope (e.g., `feat(scope): ...`).

## CI/CD Integration

- [ ] `module.json` and `.releaserc.js` are configured for release automation.
- [ ] `commit_scope` is added to `scopes` in `.github/workflows/pr-validation.yml` when using scoped PR titles.
- [ ] `commit_scope` is added to `scopes` in `.github/workflows/pr-validation.yml`.
