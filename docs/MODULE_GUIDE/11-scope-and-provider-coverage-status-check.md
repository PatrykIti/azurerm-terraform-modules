# 11. Scope and Provider Coverage Status Check

Use this check when reviewing an existing module or before finalizing a new one.
The goal is to confirm two things:

1. The module does not exceed its intended scope (atomic boundary).
2. The module exposes provider/resource capabilities intentionally and safely.

This check is designed for agents and should be run as a mandatory gate.

## Inputs

Set these values at the start of the audit:

- `MODULE_PATH=modules/<provider>_<resource>`
- `PRIMARY_RESOURCE=<provider_resource_type>` (example: `azurerm_application_insights`)
- `PROVIDER_NAME=<azurerm|azuredevops|...>`
- `PROVIDER_VERSION=<from versions.tf>`

## Scope Rule: Resource Schema vs Service Family

- Atomic module expectation applies to the **primary resource type**, not the entire cloud service family.
- Coverage target is full capability coverage of `PRIMARY_RESOURCE` arguments/blocks for the pinned provider version.
- Service-adjacent resource types are out of scope unless explicitly declared in module scope.
- Examples:
  - `azurerm_private_dns_zone` module should not be forced to manage `azurerm_private_dns_*_record` resources.
  - `azurerm_key_vault` module should not be forced to manage `azurerm_key_vault_secret`, `azurerm_key_vault_certificate`, and `azurerm_key_vault_key` unless the module scope explicitly includes them.

## Status Scale

- `GREEN`: no High findings and at most 2 Medium findings.
- `YELLOW`: no High findings, but 3+ Medium findings.
- `RED`: at least 1 High finding.

## Severity Rules

- `High`
  - Module owns resources that should be in a dedicated module.
  - Module mixes unrelated service domains (bundled cross-resource glue).
  - Security-critical provider capability is missing and not enforced by secure default.
- `Medium`
  - Supported provider capability is not exposed and not documented as intentional.
  - Missing tests/examples for major implemented features.
  - Docs/README drift from real behavior.
- `Low`
  - Naming/description inconsistencies without runtime impact.
  - Minor documentation gaps.

## A. Scope Boundary Check (Atomicity)

- [ ] Folder/module naming matches primary resource intent.
- [ ] `main.tf` primary resource matches `PRIMARY_RESOURCE`.
- [ ] Module does not manage unrelated resources (networking glue, RBAC glue, budgets, private endpoints, etc.).
- [ ] Diagnostic settings are the only accepted inline exception when needed.
- [ ] If a dedicated module exists for a sub-resource, this module does not manage that sub-resource.
- [ ] `variables.tf` contains only inputs needed for in-scope resources.
- [ ] `outputs.tf` contains only outputs for in-scope resources.
- [ ] `examples/` do not introduce out-of-scope responsibilities.
- [ ] `tests/fixtures` and Terratest scenarios do not assert out-of-scope behavior.
- [ ] `README.md`, `docs/README.md`, and `module.json` describe the same scope as the code.

## B. Provider Capability Coverage Check

Build a capability map for each managed resource:

- Use provider schema and docs for the pinned provider version.
- List all meaningful arguments/blocks.
- Mark each capability as `Implemented`, `Intentionally Omitted`, or `Not Applicable`.
- For `PRIMARY_RESOURCE`, expected target is **full schema coverage** for the pinned provider version (for example `azurerm` `4.57.0`), unless omission is explicitly justified.

Checklist:

- [ ] All required resource arguments are supported by module inputs or fixed secure defaults.
- [ ] For `PRIMARY_RESOURCE`, all supported arguments/blocks in pinned provider version are implemented or explicitly documented as intentionally omitted.
- [ ] Security-relevant capabilities are exposed or intentionally locked down with documented rationale.
- [ ] Enum/range/format inputs have validations in `variables.tf`.
- [ ] Cross-field rules are guarded with `lifecycle` preconditions or equivalent.
- [ ] Optional nested blocks are handled safely (dynamic blocks, null guards, stable keys).
- [ ] Important computed attributes are exported in `outputs.tf` (with `sensitive = true` when needed).
- [ ] `docs/IMPORT.md` covers all managed resources or clearly limits scope.
- [ ] Examples cover baseline + advanced/security variants for implemented major features.
- [ ] Unit tests cover validation and default behavior for implemented feature groups.

## H. Logic Placement and Variable Modeling Check

Design intent: keep module logic predictable, easy to consume, and easy to maintain.

Priority order for rule placement:
1. `variables.tf` validation for input-only constraints.
2. `lifecycle.precondition` for constraints that require resource semantics or apply-time context.
3. `locals` only for reused/computed transformations and readability.

Checklist:

- [ ] Input-only constraints are validated in `variables.tf` (not deferred to `precondition` by default).
- [ ] `precondition` blocks are reserved for checks that cannot be reliably enforced at variable-validation stage.
- [ ] No unnecessary one-off `locals` aliases that only rename direct variable references.
- [ ] Complex inline expressions in resource arguments are extracted to named locals (or equivalent) when they reduce cognitive load.
- [ ] Variables are grouped into logical objects where beneficial for module consumers (environment configuration ergonomics), similar to patterns used in `azurerm_postgresql_flexible_server` and `azurerm_kubernetes_cluster`.
- [ ] Grouped inputs remain explicit and testable; they do not reduce discoverability of supported provider features.
- [ ] Tests cover grouped-object validation paths and precondition paths separately.

## I. Diagnostic Settings Scope and Coverage Check

Apply this section when a module manages `azurerm_monitor_diagnostic_setting` for its primary resource.

Checklist:

- [ ] Diagnostic behavior is explicit-input driven (`diagnostic_settings`) and deterministic.
- [ ] Module does not use `azurerm_monitor_diagnostic_categories` runtime discovery.
- [ ] Allowed diagnostic categories/groups/metrics are pinned and validated in `variables.tf` for the module's provider version.
- [ ] Validation enforces at least one category/group per diagnostic setting object.
- [ ] Validation enforces destination consistency and rejects empty-string identifiers.
- [ ] `diagnostics.tf` uses simple `for_each` filtering (`length(...) > 0`) and avoids complex category-expansion `locals`.
- [ ] `lifecycle.precondition` is used for diagnostics only when a rule cannot be expressed in variable validation.
- [ ] `README.md` and `docs/README.md` explain the explicit category model and caller responsibility.
- [ ] Unit tests contain positive and negative diagnostic validation scenarios.
- [ ] Examples include at least one realistic diagnostic configuration for the resource.

Severity guidance:

- `High`: diagnostics implementation manages unrelated resources or introduces non-deterministic behavior that breaks atomic scope.
- `Medium`: supported categories exist in pinned provider but are not exposed/validated/documented.
- `Low`: wording inconsistencies in docs/examples without runtime impact.

## C. Mandatory Coverage Matrix

Agents must include this matrix in the report:

| Capability | Provider Support | Module Status | Severity if Missing | Evidence |
| --- | --- | --- | --- | --- |
| `<arg_or_block>` | `Yes/No` | `Implemented/Omitted/N-A` | `High/Medium/Low` | `<file:line>` |

Rules:

- Missing `High` capabilities block approval.
- `Omitted` is acceptable only with explicit rationale in docs.
- For `PRIMARY_RESOURCE`, undocumented omissions of supported arguments/blocks are at least `Medium` and can be `High` when they affect security/compliance.

## D. Required Agent Output (Status Report)

Every audit must end with this structure:

1. `Scope Status`: `GREEN/YELLOW/RED`
2. `Provider Coverage Status`: `GREEN/YELLOW/RED`
3. `Overall Status`: `GREEN/YELLOW/RED`
4. `Findings by Severity` with file references
5. `Coverage Matrix` (table above)
6. `Action Plan` (ordered list, each item with owner + expected impact)

Template:

```md
## Status Summary
- Scope Status: <GREEN|YELLOW|RED>
- Provider Coverage Status: <GREEN|YELLOW|RED>
- Overall Status: <GREEN|YELLOW|RED>

## Findings
- High: ...
- Medium: ...
- Low: ...

## Coverage Matrix
| Capability | Provider Support | Module Status | Severity if Missing | Evidence |
| --- | --- | --- | --- | --- |
| ... | ... | ... | ... | ... |

## Action Plan
1. <change>
2. <change>
3. <change>
```

## E. Approval Gate

- `GREEN`: can proceed.
- `YELLOW`: proceed only with explicit follow-up tasks.
- `RED`: do not proceed until High findings are resolved.

## F. Addendum: Naming/Provider-Alignment Checklist (Mandatory for Rename Work)

Use this checklist whenever there is any mismatch between module naming and provider resource naming.

### 0) Input Data (fill before start)

- [ ] `MODULE_PATH`: `modules/<provider>_<resource>`
- [ ] `PROVIDER_RESOURCE`: for example `azurerm_ai_services`
- [ ] `COMMIT_SCOPE`: for example `ai-services`
- [ ] `TAG_PREFIX`: for example `AISv`
- [ ] Work mode: `AUDIT_ONLY` or `FULL_RENAME`

### 1) Inventory and Discovery

- [ ] Confirm the real provider resource name from docs/schema (not memory).
- [ ] Find all occurrences of old naming in module files: `main.tf`, `diagnostics.tf`, `outputs.tf`, `variables.tf`, `docs/*`, `examples/*`, `tests/*`, `module.json`, `go.mod`.
- [ ] Find old naming in repository references: `README.md`, `modules/README.md`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`, workflows, and scripts.
- [ ] Classify names as public API (`inputs/outputs`) vs internal-only labels.

### 2) Internal Naming Consistency (ALWAYS)

- [ ] All resource/data source references use the new label (no `undeclared resource` failures).
- [ ] `diagnostics.tf` uses correct `resource_id` / `target_resource_id`.
- [ ] `outputs.tf` references the correct resource label.
- [ ] `docs/IMPORT.md` import addresses are correct (`module.<name>.<resource_type>.<resource_label>`).
- [ ] `README.md` resources table has correct resource/data source addresses.
- [ ] No stale naming remains in module directory (`rg` check).

### 3) `FULL_RENAME`: Module-Local Rename

- [ ] Rename module directory to canonical path (`modules/<canonical_name>`).
- [ ] Rename test files if they encode old module naming (for example `*_account_test.go` to `*_test.go`).
- [ ] Update `module.json`: `name`, `title`, `commit_scope`, `tag_prefix`, `description`.
- [ ] Update `tests/go.mod` module path.
- [ ] Update test function names and their references in test `Makefile` and scripts.
- [ ] Update fixtures/examples (`module "<name>"`, output names, variable names) only where internal.
- [ ] Do not change public module API (`inputs/outputs`) without explicit decision.

### 4) `FULL_RENAME`: Repo-Wide References

- [ ] Update root `README.md` modules table (name/path/description).
- [ ] Update `modules/README.md` modules table (name/path/tag prefix).
- [ ] Update references in `docs/_TASKS/TASK-*.md`.
- [ ] Update link targets in `docs/_CHANGELOG/README.md`.
- [ ] If task/changelog filename contains old naming, rename file and fix links.
- [ ] Update any other modules/docs referencing this module (including out-of-scope notes).

### 5) Generated Documentation

- [ ] Run `make docs` in module directory.
- [ ] Regenerate example READMEs if examples use terraform-docs.
- [ ] Verify README does not contain mixed old/new identifiers.

### 6) Technical Quality Gate

- [ ] `terraform fmt -check -recursive` passes.
- [ ] `terraform init -backend=false -input=false` passes.
- [ ] `terraform validate` passes.
- [ ] `terraform test -test-directory=tests/unit` passes.
- [ ] `go test ./... -run '^$'` in `tests/` passes (test compile gate).
- [ ] If `make test` fails due to missing credentials, confirm failures are only environmental (not naming-related).

### 7) Additional Sanity Checks

- [ ] No stale module/resource/tag-prefix naming in entire repo (`rg` check).
- [ ] No easy-to-fix deprecations remain in fixtures/examples (provider args).
- [ ] No dangling paths remain after rename (old folders/docs links).

### 8) Definition of Done

- [ ] Module has canonical naming aligned with provider resource.
- [ ] Internal resource/data source references are consistent.
- [ ] Documentation and import paths are consistent.
- [ ] Test harness (`Makefile`/scripts/test names) is consistent.
- [ ] Repo-wide links and indexes are consistent.
- [ ] Technical validation gate passes (`fmt` / `validate` / `terraform test` / `go test` compile).

### 9) Required Final Report Format

- [ ] `Module:` `<path>`
- [ ] `Mode:` `AUDIT_ONLY | FULL_RENAME`
- [ ] `Changed files:` list of paths
- [ ] `Validation results:` `fmt` / `validate` / `terraform test` / `go test`
- [ ] `Residual risks:` for example missing E2E due to credentials
- [ ] `Open decisions:` for example whether to rename public output names

## G. Addendum: Go Tests + Fixtures Checklist (Terraform Modules)

### A) `CopyTerraformFolderToTemp` (Paths)

- [ ] Check whether tests copy a wide enough root (for example `modules/`) when fixtures reference sibling modules.
- [ ] If dependencies on other modules exist:
  - [ ] Change `CopyTerraformFolderToTemp(t, "..", "tests/fixtures/...")` to `CopyTerraformFolderToTemp(t, "../..", "<module>/tests/fixtures/...")`.
  - [ ] Apply analogous change for benchmarks (`b`) and `fmt.Sprintf(...)`-based paths.
- [ ] If module has no cross-module dependencies, keep standard local copy pattern.

### B) `source` in Fixtures

- [ ] For tested module fixture (`tests/fixtures/*`), ensure `source = "../../../"`.
- [ ] For sibling modules used in fixtures:
  - [ ] Set `source` so it resolves after copying from `modules/` (for example `../../../../azurerm_eventhub_namespace`).

### C) `tests/Makefile` Pattern

- [ ] Align test `Makefile` with `modules/azurerm_postgresql_flexible_server/tests/Makefile` pattern:
  - [ ] `SHELL := /bin/bash`
  - [ ] `LOG_DIR=test_outputs`, `LOG_TIMESTAMP`
  - [ ] `run_with_log` + `tee`
  - [ ] ARM/AZURE env normalization (`ARM_*` ↔ `AZURE_*`)
  - [ ] All `make test-*` targets use `run_with_log`
- [ ] Confirm `make test` writes logs to `tests/test_outputs/all_*.log`.

### D) Integration Tests: Missing Helpers / Unused Vars

- [ ] Remove unused imports (for example `context`, `time` when unused).
- [ ] Remove/comment placeholder helpers (`New<resource>Helper`) if not implemented.
- [ ] Add `_ = var` placeholders where needed so build/test compile remains clean.

### E) Terraform String Validations

- [ ] When validating string tokens, use `strcontains`, not `contains`.

### F) Execution and Verification

- [ ] Run `cd modules/<module>/tests && make test`.
- [ ] Verify logs are generated under `tests/test_outputs/*.log`.
- [ ] If tests use fixtures with sibling modules, verify temp copy contains complete dependency set.
