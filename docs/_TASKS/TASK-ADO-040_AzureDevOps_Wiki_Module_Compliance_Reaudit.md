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

## Planning Assumption

- No active production consumers yet (owner confirmation, 2026-02-13).
- Breaking changes are explicitly allowed for atomic-boundary alignment.
- Backward-compatibility shims are optional; prioritize clean target architecture.

## Mandatory Rule (Atomic Boundary)

- Primary resource in a module must be single and non-iterated (`no for_each`, `no count` on primary block).
- Additional resources may remain only when they are strict children of that primary resource.
- Strict child means direct dependency on module-managed primary resource and no external-ID fallback.
- If a resource can operate without module primary resource (for example via external `*_id` input), it must be moved to a separate atomic module.
- Multiplicity belongs in consumer configuration via module-level `for_each`.

## Current Gaps

- Primary wiki resource is iterated inside the module (`for_each = var.wikis`) instead of module-level `for_each` in consumer config (`modules/azuredevops_wiki/main.tf:7`).
- Wiki page addressing uses index-based keys (`wiki_pages = { for idx, page in var.wiki_pages : idx => page }`), which is unstable on reorder (`modules/azuredevops_wiki/main.tf:3`).
- `wiki_pages` can target external `wiki_id`, so page management is not strict-child-only.
- Output naming/docs expose index-based model (`Map of wiki page IDs keyed by index`) rather than stable semantic keys (`modules/azuredevops_wiki/outputs.tf:17`).
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
- **Strict-child cleanup:** if pages remain in this module, remove external `wiki_id` fallback and anchor pages to module-managed wiki only; otherwise split pages to dedicated module.
- **Stable keys for pages:** replace index-based page keys with explicit `key` or deterministic path-based keying and enforce uniqueness validation.
- **Outputs:** expose stable map outputs keyed by semantic keys (not list index).
- **Examples/tests:** update `basic|complete|secure` + fixtures to the new single-instance model and add/adjust unit tests for stable-key behavior.
- **Release/docs sync:** align example refs with actual published tags via `TASK-ADO-039` flow.

## Acceptance Criteria

- Main wiki resource is single-instance inside module (no internal `for_each` for primary resource).
- Any retained page resource is strict-child-only or moved to dedicated module.
- Wiki pages are keyed deterministically and remain stable across list reorder.
- Outputs are keyed by stable semantic keys, not by index.
- Examples and tests reflect module-level iteration pattern for multiple wikis.
- Scope/coverage status report is attached with `Scope Status`, `Provider Coverage Status`, and `Overall Status`.

## Implementation Checklist

- [ ] Refactor `variables.tf` and `main.tf` to single-wiki model.
- [ ] Remove non-child fallback behavior for pages or split pages scope.
- [ ] Introduce stable keying strategy for `wiki_pages` + uniqueness validations.
- [ ] Update `outputs.tf` to stable-key outputs.
- [ ] Update examples/fixtures/unit tests for new API shape.
- [ ] Regenerate docs and update import guidance.
- [ ] Link release/tag normalization dependency to `TASK-ADO-039`.
