# Module Audit + Task Prompt (Template)

Use this prompt to have another agent audit a single module against the repo guides and produce a task plan. The agent must not implement code changes until explicitly approved.

INPUT (edit only this line):
MODULE_PATH=modules/<provider>_<resource>
MODE=AUDIT_ONLY   # AUDIT_ONLY or FULL_RENAME
PRIMARY_RESOURCE=<provider_resource_type>   # e.g. azurerm_private_dns_zone
PROVIDER_VERSION=4.57.0

Instructions:

1) Context and sources
- Read `AGENTS.md`.
- Read the guides:
  - `docs/MODULE_GUIDE/README.md`
  - `docs/MODULE_GUIDE/10-checklist.md`
  - `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md`
  - `docs/TESTING_GUIDE/README.md`
  - `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`
- Use `rg` for search.

2) Module layout audit (MODULE_PATH)
- Check the required layout (core files, docs, examples, tests, module.json, .releaserc.js, Makefile, generate-docs.sh, docs/IMPORT.md).
- Note missing files, extra artifacts (e.g., `.terraform`, `.terraform.lock.hcl` in the module), and naming issues.
- Confirm module folder naming matches `azurerm_<resource>` or `azuredevops_<resource>`.

3) Terraform code audit
- `versions.tf`: pin Terraform + provider versions to repo standards (azurerm 4.57.0 / azuredevops 1.12.2).
- `variables.tf`: every variable has description + type; prefer `object`/`list(object)` for logical grouping; add validations; enforce input-only constraints as early as possible.
- `main.tf`: use locals only when needed (reused/computed or readability), keep stable `for_each` keys (no index keys), dynamic blocks for optional features, and avoid unnecessary one-use alias locals.
- Place constraints by priority:
  - first: `variables.tf` validation for input-only rules,
  - second: `lifecycle.precondition` only when validation cannot express rule reliably (resource/apply-time semantics).
- If resource arguments contain heavy inline logic, require extraction into named locals (or equivalent) for maintainability.
- Optional object + `count`: `count = 0` prevents evaluation of resource arguments, but outputs still need guards (ternary/try).
- `outputs.tf`: include descriptions; mark sensitive outputs; guard optional outputs.
- Build a schema diff for `PRIMARY_RESOURCE` in `PROVIDER_VERSION` (provider docs/schema vs module inputs/blocks/outputs).
- Expected: full support for `PRIMARY_RESOURCE` arguments/blocks; omissions must be explicitly justified in docs.
- Do not auto-expand scope to adjacent resource types unless module scope explicitly requires it.
  - Example: `azurerm_private_dns_zone` is not automatically responsible for all `azurerm_private_dns_*_record` resources.
  - Example: `azurerm_key_vault` is not automatically responsible for secret/certificate/key resources unless explicitly in scope.

4) Documentation audit
- `README.md` has markers: `BEGIN_VERSION`, `BEGIN_EXAMPLES`, `BEGIN_TF_DOCS`.
- `docs/README.md`, `SECURITY.md`, `VERSIONING.md`, `CONTRIBUTING.md`, `docs/IMPORT.md` are present and consistent with code.
- Example READMEs match example `main.tf` and are runnable.
- Check whether terraform-docs output is stale.

5) Examples audit
- Required examples: `basic`, `complete`, `secure`.
- Azure DevOps examples must use fixed, deterministic names (no random suffixes).
- Examples should be self-contained where feasible.
- Validate naming patterns per `docs/MODULE_GUIDE/06-examples.md`.

6) Tests audit
- Validate `tests/` structure against `docs/TESTING_GUIDE`.
- Check fixtures, unit tests (`*.tftest.hcl`), Terratest files, and tooling scripts.
- Ensure env vars listed in test docs match actual usage.

7) Release config audit
- `module.json` fields: `name`, `title`, `commit_scope`, `tag_prefix`.
- `.releaserc.js` handles source replacement for `git::https` and relative paths.
- Tag prefixes must include `v` (e.g., `TAG_PREFIXvX.Y.Z`).

8) Compliance report
- List deviations by severity (High/Medium/Low) with file references.
- Run and report:
  - Scope Status (`GREEN/YELLOW/RED`)
  - Provider Coverage Status (`GREEN/YELLOW/RED`)
  - Overall Status (`GREEN/YELLOW/RED`)
- Include a capability coverage matrix per `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md`.
- Apply the addendum checklists from the same document:
  - Naming/Provider-Alignment checklist
  - Go Tests + Fixtures checklist

9) Task creation
- If deviations exist, create a new task file under `docs/_TASKS/`.
- Use the next available ID (`TASK-XXX` or `TASK-ADO-XXX`).
- Include: Overview, Current Gaps, Scope, Docs to Update (in-module + outside), Acceptance Criteria, Implementation Checklist.
- Add the task to `docs/_TASKS/README.md` (To Do) and update counts.
- Do not implement code changes.

10) Questions for me (end of response)
Ask short decision questions, e.g.:
- Should any resources move to a different module?
- Are breaking changes acceptable or do we need a migration plan?
- Any sections to skip or treat as non-essential?
- Should examples/tests be adjusted in a specific way?

Deliverables:
- Short compliance report
- Task file created (if needed)
- Clarifying questions
