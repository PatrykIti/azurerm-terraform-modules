# TASK-ADO-040: Azure DevOps Wiki Module Compliance Re-audit
# FileName: TASK-ADO-040_AzureDevOps_Wiki_Module_Compliance_Reaudit.md

**Priority:** 🔴 High  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** docs/MODULE_GUIDE/10-checklist.md, docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md, TASK-ADO-039  
**Status:** 🟡 To Do

---

## Overview

Re-audit and refactor `modules/azuredevops_wiki` to match current repository standards for atomic scope, stable resource addressing, and module-level iteration patterns.

## Current Gaps

- Primary wiki resource is iterated inside the module (`for_each = var.wikis`) instead of module-level `for_each` in consumer config (`modules/azuredevops_wiki/main.tf:7`).
- Wiki page addressing uses index-based keys (`wiki_pages = { for idx, page in var.wiki_pages : idx => page }`), which is unstable on reorder (`modules/azuredevops_wiki/main.tf:3`).
- Output naming/docs expose index-based model (`Map of wiki page IDs keyed by index`) rather than stable semantic keys (`modules/azuredevops_wiki/outputs.tf:17`).
- Current module scope (`wikis` + `pages`) needs explicit decision and documentation against atomic-module rule in AGENTS/MODULE_GUIDE.
- Example source refs point to `ADOWIv1.0.0`, but this tag is not present in git history; examples are not runnable against published tag set (covered by `TASK-ADO-039`).

## Scope

- Module: `modules/azuredevops_wiki/`
- Examples: `modules/azuredevops_wiki/examples/*`
- Tests: `modules/azuredevops_wiki/tests/*`
- Docs: module `README.md`, `docs/README.md`, `docs/IMPORT.md`

## Docs to Update

### In-Module
- `modules/azuredevops_wiki/README.md`
- `modules/azuredevops_wiki/docs/README.md`
- `modules/azuredevops_wiki/docs/IMPORT.md`
- `modules/azuredevops_wiki/examples/*/README.md`

### Repo-Level
- `docs/_TASKS/README.md`
- `README.md` (version links handled jointly with `TASK-ADO-039`)

## Work Items

- **Primary resource model:** change module to a single wiki per module instance (non-iterated main resource); move multi-wiki usage to module-level `for_each` in consumers/examples.
- **Stable keys for pages:** replace index-based page keys with explicit `key` or deterministic path-based keying and enforce uniqueness validation.
- **Validation hardening:** ensure `wiki_id` vs `wiki_key` selector constraints are preserved after refactor and add explicit uniqueness checks for page keys.
- **Outputs:** expose stable map outputs keyed by semantic keys (not list index).
- **Examples/tests:** update `basic|complete|secure` + fixtures to the new single-instance model and add/adjust unit tests for stable-key behavior.
- **Release/docs sync:** align example refs with actual published tags via `TASK-ADO-039` flow.

## Acceptance Criteria

- Main wiki resource is single-instance inside module (no internal `for_each` for primary resource).
- Wiki pages are keyed deterministically and remain stable across list reorder.
- Outputs are keyed by stable semantic keys, not by index.
- Examples and tests reflect module-level iteration pattern for multiple wikis.
- Scope/coverage status report is attached with `Scope Status`, `Provider Coverage Status`, and `Overall Status`.

## Implementation Checklist

- [ ] Refactor `variables.tf` and `main.tf` to single-wiki model.
- [ ] Introduce stable keying strategy for `wiki_pages` + uniqueness validations.
- [ ] Update `outputs.tf` to stable-key outputs.
- [ ] Update examples/fixtures/unit tests for new API shape.
- [ ] Regenerate docs and update import guidance.
- [ ] Link release/tag normalization dependency to `TASK-ADO-039`.
