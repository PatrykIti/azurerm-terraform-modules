# TASK-ADO-031: Azure DevOps Agent Pools module - MODULE_GUIDE alignment (examples + main.tf + docs)
# FileName: TASK-ADO-031_AzureDevOps_Agent_Pools_Guide_Alignment.md

**Priority:** Medium
**Category:** Azure DevOps Modules / Documentation
**Estimated Effort:** Small
**Dependencies:** TASK-ADO-015
**Status:** To Do

---

## Overview

Bring `modules/azuredevops_agent_pools` into full compliance with `docs/MODULE_GUIDE`,
covering example naming rules, main.tf patterns, and documentation consistency.

---

## Current Gaps (Summary)

- Examples use random suffixes and the `random` provider, which violates
  `docs/MODULE_GUIDE/06-examples.md` for Azure DevOps modules (fixed names only).
- Example READMEs mention random suffixes, which contradicts guide expectations.
- Example README terraform-docs output shows `../../` sources while `main.tf` uses
  `git::https` sources; docs were not regenerated after recent changes and after
  `.releaserc.js` source-pattern updates.
- `azuredevops_elastic_pool` uses `try(...)` on every attribute; `count = 0`
  already prevents evaluation when the object is null. Remove `try` and rely on
  direct access + validations, keeping `count`.
- `agent_queues_by_key` uses a multi-fallback key; this is correct but undocumented
  in module docs. Users should see how keys are derived and when to set `key`.

---

## Scope

1) **Main module (elastic pool + queue keys)**
   - Keep `count`, remove `try(...)` in `azuredevops_elastic_pool`, and use
     direct access to `var.elastic_pool.*`.
   - Update outputs to use a conditional guard instead of `try(...)`.
   - Document `agent_queues_by_key` key selection in README/variables docs:
     `key` → `name` → `agent_pool_id` (as string) → `project_id`.

**Note:** Terraform does not evaluate resource arguments when `count = 0`, so
direct access to an optional object is safe inside the resource. Outputs and
other references still need conditional guards.

2) **Examples: naming + inputs**
   - Replace random suffix logic with deterministic names in:
     - `examples/basic`
     - `examples/complete`
     - `examples/secure`
   - Remove `random` provider and `random_string` resource from all examples.
   - Use fixed defaults that follow guide patterns, e.g.
     `ado-agent-pools-basic-example`, `ado-agent-pools-complete-example`,
     `ado-agent-pools-secure-example`.
   - Keep override variables for uniqueness when required by org policy.

3) **Examples: README content**
   - Update features/notes to remove any "random suffix" wording.
   - Ensure example descriptions match the deterministic naming behavior.

4) **Docs regeneration**
   - Re-run module and example terraform-docs so tables match `main.tf`.
   - Ensure README source entries are consistent with the `git::https` pattern
     and compatible with the updated `.releaserc.js` replacements.

---

## Docs to Update

### In-module docs
- `modules/azuredevops_agent_pools/README.md` (examples list + terraform-docs refresh)
- `modules/azuredevops_agent_pools/examples/basic/README.md`
- `modules/azuredevops_agent_pools/examples/complete/README.md`
- `modules/azuredevops_agent_pools/examples/secure/README.md`
- `modules/azuredevops_agent_pools/docs/README.md` (only if naming guidance is added)

### Outside the module (if required)
- `docs/_TASKS/README.md` (update status after completion)
- `docs/_CHANGELOG/*` (only if release/changelog policy requires it)

---

## Acceptance Criteria

- All three examples use fixed, deterministic names with guide-aligned defaults.
- No `random` provider or `random_string` resource appears in examples.
- Example READMEs reflect deterministic names and contain no random-suffix language.
- terraform-docs output matches example `main.tf` sources (no stale `../../` entries).
- `azuredevops_elastic_pool` no longer uses `try(...)`; direct inputs are used
  with `count` and validations, and outputs are conditionally guarded.
- `agent_queues_by_key` key selection is documented for users.

---

## Implementation Checklist

- [ ] Update `main.tf` to keep `count`, remove `try(...)`, and access
  `var.elastic_pool.*` directly.
- [ ] Update outputs to use a conditional guard instead of `try(...)`.
- [ ] Document agent queue key selection in README or variables docs.
- [ ] Update example `main.tf` files to remove random suffixes and providers.
- [ ] Adjust example `variables.tf` defaults to fixed names per guide patterns.
- [ ] Update example `README.md` text to match deterministic naming.
- [ ] Re-run docs:
  - `./scripts/update-module-docs.sh azuredevops_agent_pools`
  - `./scripts/update-examples-list.sh azuredevops_agent_pools`
- [ ] Verify example README module sources match `git::https` and are release-safe.
