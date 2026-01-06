# MODULE CREATION TASK – {{ module name}}

You are tasked with creating a new Terraform module named `{{ module name}}` according to the latest AzureRM provider version **4.57.0**. Follow strictly the internal module development standards defined in `@AGENTS.md` and the `docs/MODULE_GUIDE/` series. Use the helper script `@scripts/create-new-module.sh` to generate the initial structure.

## 🗂️ WORKTREE SETUP – PARALLEL WORK (OPTIONAL)

If multiple agents or contributors work in parallel, use separate Git worktrees with distinct branches and workspaces.

Worktree: git worktree add ../azurerm-terraform-modules-<shortcut_for_created_module> feature/<module_name_without_azurerm_prefix>_module

Ex. Worktree: git worktree add ../azurerm-terraform-modules-aks feature/aks-module

### Worktree initialization:
```bash
git git worktree add ../azurerm-terraform-modules-aks feature/aks-module
cd ../azurerm-terraform-modules-aks
```

Once inside the new directory, you’ll work independently from other modules or agents.

---

## 🎯 GOAL

Create a standalone, production-ready Terraform module for `{{ module name}}`, supporting **all configuration scenarios** according to the latest AzureRM documentation. Ensure that the module is flexible, reusable, and documented.

Use `modules/azurerm_kubernetes_cluster` as the gold standard for structure, testing, and documentation. When a resource requires different patterns, document the reason for the deviation.

---

## 📋 MAIN TASKS

### 1. 🧱 Use scaffolding script
```bash
bash @scripts/create-new-module.sh {{ module name}} (each module folder has name like main terraform resource block for ex. azurerm_storage_account, {{ module name}}, azurerm_app_service_plan etc.)
```
- Validate that `main.tf`, `variables.tf`, `outputs.tf`, `README.md`, and test directory were created

Optional flags:
```bash
# customize examples list (must include basic, complete, secure)
bash @scripts/create-new-module.sh --examples=basic,complete,secure {{ module name}} "Display Name" XX scope "Description"
```
Add any feature-specific examples (e.g., `diagnostic-settings`, `multi-node-pool`, `workload-identity`) manually after scaffolding.

Most of the files for module documentation have place holders which should be replaced with proper name of module but most of them are for review and standard correction where the script is not correcting them.

---

### 2. 📚 Schema exploration
- Research the full structure and capabilities of `azurerm_{{ module name}}` resource block using AzureRM provider version 4.57.0:
  - Official Terraform Registry
  - Azure provider changelog (breaking changes, deprecations, defaults)
- Document optional and required arguments

---

## 🛠️ PARALLEL CONTRIBUTORS (OPTIONAL)

If work is split across multiple contributors, divide responsibilities by area:

- **Core module files**: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- **Tests**: `tests/unit/*.tftest.hcl`, `tests/fixtures/*`, Go tests, `tests/Makefile`
- **Examples**: `examples/basic`, `examples/complete`, `examples/secure`, plus optional feature examples

Ensure all contributors follow `@AGENTS.md` and `docs/MODULE_GUIDE/`.

---

## 🔁 QA & RELEASE PREP

- Validate `terraform validate` + `terraform fmt -check`
- Run unit tests and check if everything is ok
- Run 'Go' tests which will be triggered by workflow
- Commit using conventional format:
  ```bash
  git commit -m "feat({{ module name}}): initial release"
  ```

---

## 🚫 NOT IN SCOPE
- Do NOT implement `vnet`/`nsg`/`route` linking logic here – this will be part of the `azurerm_networking` wrapper
- Do NOT bundle private endpoints, role assignments/RBAC, or budgets here – these live in dedicated modules or higher-level environment configs
- Do NOT create nested/submodules or “solution modules” – each module must stay atomic around a single primary resource
- Diagnostic settings belong inline in the module (duplication is fine); do not factor them into shared submodules
- Do NOT hardcode naming conventions or globals – inherit via input variables only
- Everything for terraform module creation is described in the @AGENTS.md and referenced files
