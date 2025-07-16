# MODULE CREATION TASK – {{ module name}}

You are tasked with creating a new Terraform module named `{{ module name}}` according to the latest AzureRM provider version **4.36.0**. Follow strictly the internal module development standards defined in `@CLAUDE.md`. Use the helper script `@scripts/create-new-module.sh` to generate the initial structure.
First you need to check script and what will be created as a module template.

## 🗂️ WORKTREE SETUP – CLAUDE MULTI-AGENT FLOW

To isolate agent work, each Claude agent should use a separate **Git worktree**, with its own branch and workspace

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

---

## 📋 MAIN TASKS

Before start, plan everything and set up proper task in taskmaster (@CLAUDE has proper guidance for this) and create proper subtasks with full description what needs to be done.
Taskmaster is initialized already and do not do this again!!!

---

## 📋 MAIN TASKS

### 1. 🧱 Use scaffolding script
```bash
bash @scripts/create-new-module.sh {{ module name}} (each module folder has name like main terraform resource block for ex. azurerm_storage_account, {{ module name}}, azurerm_app_service_plan etc.)
```
- Validate that `main.tf`, `variables.tf`, `outputs.tf`, `README.md`, and test directory were created

Most of the files for module documentation have place holders which should be replaced with proper name of module but most of them are for review and standard correction where the script is not correcting them.

---

### 2. 📚 Schema exploration
- Research the full structure and capabilities of `azurerm_{{ module name}}` resource block using AzureRM provider version 4.36.0:
  - Official Terraform Registry
  - Azure provider changelog (breaking changes, deprecations, defaults)
- Document optional and required arguments
- Use gemini zen when possible - for almost all tasks which needs a documentation review

---

## 🛠️ PARALLEL AGENTS (run concurrently)

Each of the following sub-agents runs in its own Claude Code session inside its worktree:

### Agent A – main files for module:
- See guidelines in @CLAUDE.md - MANDATORY!!
- `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` 

### Agent B - tests
- See guidelines in @CLAUDE.md - MANDATORY!!
- Start creation / correction for tests files ui / integration etc.

### Agent C – examples
- See guidelines in @CLAUDE.md - MANDATORY!!
- Start creation / correction for examples files

### Agent D – .... if needed

Check the existing module directory structure and divide the work for the agents in logic, proper way that they will not collide with each other.

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
- Do NOT hardcode naming conventions or globals – inherit via input variables only
- Everything for terraform module creation is described in the @CLAUDE.md and referenced files
