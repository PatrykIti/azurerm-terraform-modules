# TASK-012: Module Guide Alignment (AKS + Azure DevOps Repository)
# FileName: TASK-012_Module_Guide_Alignment.md

**Priority:** 🟡 Medium
**Category:** Documentation / Standards
**Estimated Effort:** Medium
**Dependencies:** —
**Status:** ✅ **Done** (2026-01-01)

---

## Overview

Align `docs/MODULE_GUIDE/*` with the actual patterns used in
`modules/azurerm_kubernetes_cluster` and `modules/azuredevops_repository`,
with emphasis on locals usage, block optionality, for_each/count selection,
docs structure, and CI expectations.

---

## Scope

1) **Module Structure**
   - Mark `docs/README.md` as optional (AKS does not include it).
   - Keep `docs/IMPORT.md` required and aligned to module keying rules.
   - Note optional test fixture subfolders (`network`, `negative`, feature-specific).

2) **Core Files Guidance**
   - Add explicit guidance for provider-required blocks (always send block + defaults).
   - Clarify when to use `count` vs `for_each` (0/1 vs list).
   - Emphasize `nullable = false` with `default = {}` to avoid `try/coalesce`.
   - Document flattening nested list patterns + uniqueness validation for list policy names.

3) **Configuration Files**
   - Update `.terraform-docs.yml` template to match the AKS/ADO minimal style.
   - Move Usage/Examples/Notes outside TF_DOCS markers.

4) **Documentation Rules**
   - README markers: `BEGIN_VERSION`, `BEGIN_EXAMPLES`, `BEGIN_TF_DOCS`.
   - `docs/README.md` section layout aligned to Azure DevOps module pattern.
   - `docs/IMPORT.md` must include CLI commands to fetch import IDs.

5) **Examples Guidance**
   - AzureRM examples: self-contained with RG and fixed naming.
   - Azure DevOps examples: fixed names, may require existing project ID.

6) **CI/CD + Checklist**
   - Clarify the PR title scope allowlist requirement in `pr-validation.yml`.
   - Clarify `locals` can live in `main.tf` (no required `locals.tf`).

---

## Acceptance Criteria

- `docs/MODULE_GUIDE/*` reflects AKS + ADO repository patterns for locals, optional blocks,
  and collection handling.
- `.terraform-docs.yml` guidance matches module configs in repo.
- README/doc section requirements align to actual modules (optional `docs/README.md`).
- Checklist and CI docs clarify when `pr-validation.yml` scope updates are required.

---

## Implementation Checklist

- [x] Update `docs/MODULE_GUIDE/02-module-structure.md`.
- [x] Update `docs/MODULE_GUIDE/03-core-files.md`.
- [x] Update `docs/MODULE_GUIDE/04-configuration-files.md`.
- [x] Update `docs/MODULE_GUIDE/05-documentation.md`.
- [x] Update `docs/MODULE_GUIDE/06-examples.md`.
- [x] Update `docs/MODULE_GUIDE/09-cicd-integration.md`.
- [x] Update `docs/MODULE_GUIDE/10-checklist.md`.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (add task row, update counters)
- `docs/_CHANGELOG/README.md` (add new entry)
- `docs/_CHANGELOG/053-2026-01-01-module-guide-alignment.md` (new changelog item)
