# TASK-ADO-035: Azure DevOps Identity Module Compliance Fixes
# FileName: TASK-ADO-035_AzureDevOps_Identity_Module_Compliance_Fixes.md

**Priority:** 🔴 High  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** TASK-ADO-018, docs/MODULE_GUIDE, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md  
**Status:** 🟡 To Do

---

## Overview

Align and rename `modules/azuredevops_identity` -> `modules/azuredevops_group` to reflect the anchor resource. Enforce the “anchor resource” rule: we only manage sub-resources that hang off the module-managed group (created or imported). Independent resources are split into dedicated modules.

## Scope

- Rename module directory and metadata: `azuredevops_identity` -> `azuredevops_group` (adjust module.json, README, docs, tests, paths).
- Fix version pinning across module core, docs, examples, and fixtures.
- Keep only group-scoped resources: `azuredevops_group`, `azuredevops_group_membership`, `azuredevops_group_entitlement`.
- Move independent resources to dedicated modules:
  - `azuredevops_service_principal_entitlement` -> new module `azuredevops_service_principal_entitlement`.
  - `azuredevops_securityrole_assignment` -> new module `azuredevops_securityrole_assignment`.
  - (Optional) `azuredevops_user_entitlement` can also be split if we don’t anchor users to the group.
- Enforce group anchoring for dependent resources and document the constraint.
- Tighten validation coverage and tests (unit + Terratest) for all inputs still managed by the group module.
- Clean up examples to be deterministic (no random suffixes) and runnable with clear ADO prerequisites.
- Update workflow/module scope detection (PR validation, CI, release) for the renamed module and any newly added modules.

## Work Items

- **Rename & metadata:** Move `modules/azuredevops_identity` -> `modules/azuredevops_group`; update `module.json`, `.releaserc.js`, README links, docs, tests, examples, and references. Adjust workflows (scopes in GH Actions) to track the new name.
- **Versioning:** Pin Terraform to repo baseline (e.g., `>= 1.7.x`) and provider `azuredevops = 1.12.2` in `versions.tf`; propagate to README requirements, `docs/IMPORT.md`, examples (`examples/*/main.tf`), and test fixtures (`tests/fixtures/*/main.tf`, `tests/README.md`).
- **Module boundary:** Keep only group-scoped resources (`azuredevops_group`, `azuredevops_group_membership`, `azuredevops_group_entitlement`) in the renamed module. Remove `azuredevops_service_principal_entitlement` and `azuredevops_securityrole_assignment` (and optionally `azuredevops_user_entitlement`) into new dedicated modules with their own tests/examples/docs.
- **Anchor Rule:** Update README to state this module always creates/imports the primary `azuredevops_group`; sub-resources must target that group. No managing sub-resources when the group is absent.
- **Inputs & Validation:** Tighten enumerations (`account_license_type`, `licensing_source`, `origin`), enforce non-empty strings, and add validations ensuring group-dependent resources require the module group (no “external-only” mode). Add lifecycle/preconditions where needed for cross-field rules.
- **Examples:** Remove `random_string` usage; switch to fixed names, call out required ADO environment variables, and keep examples self-contained with deterministic outputs. Regenerate terraform-docs.
- **Tests:** Expand unit `.tftest.hcl` to cover new validation branches and group-anchoring failures; Terratest should cover the remaining in-module resources with deterministic fixtures. Add separate tests for the new modules (service principal entitlements, security role assignments). Przejrzeć i oczyścić fixtures – usunąć lub zastąpić pozostałości szablonów „network” z modułów azurerm; zostawić tylko adekwatne scenariusze ADO dla nowych modułów.
- **Docs:** Refresh `docs/IMPORT.md` for the new version requirements and group-anchor assumption; add a short note in module README about the justified deviation from “single resource” because group-scoped sub-resources are co-located. Create docs/READMEs/IMPORT for new modules.
- **Automation:** Run `make docs` to update README markers after changes; ensure workflows detect the new module scopes.

## Example (HCL, anchored to module-managed group)

```hcl
terraform {
  required_version = ">= 1.7.5"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_group" {
  source = "../../modules/azuredevops_group"

  # Primary resource (must exist or be imported)
  group_display_name = "ado-platform"
  group_description  = "Platform engineering team"

  # Group-scoped sub-resources (allowed because the group is created/imported here)
  group_memberships = [
    {
      key                = "platform-members"
      member_descriptors = ["vssgp.Uy0xLTktMTIzNDU2Nzg5MA"]
      mode               = "add"
    }
  ]

  group_entitlements = [
    {
      key                  = "platform-basic"
      display_name         = "ado-platform"
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
```

If a resource has no dependency on the module-managed group, move it to a dedicated module instead of managing it here.

## Documentation & Changelog Updates

- **Renamed module (`azuredevops_group`):** Update `README.md` (version/examples/tf-docs markers), `docs/IMPORT.md`, `docs/README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `VERSIONING.md`, `.terraform-docs.yml` output injection, `module.json`, `.releaserc.js`, `CHANGELOG.md` (via semantic-release after scope rename), `generate-docs.sh`.
- **New modules:** Add `README.md`, `docs/IMPORT.md`, `docs/README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `VERSIONING.md`, `.terraform-docs.yml`, `module.json`, `.releaserc.js`, `CHANGELOG.md` for `azuredevops_service_principal_entitlement` and `azuredevops_securityrole_assignment` (and optionally `azuredevops_user_entitlement` if split).
- **Examples/fixtures:** Update example READMEs and `.terraform-docs.yml` outputs for determinism and new version pinning; align Terratest fixture READMEs where present.
- **Repo-level references:** Adjust `docs/_TASKS/README.md` entry (if needed), workflow scope lists (PR validation, CI, release), and any root docs linking to the old module name.
