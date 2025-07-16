# MODULE CREATION TASK – {{module_name}}

You are tasked with creating a new Terraform module named `{{module_name}}` according to the latest AzureRM provider version **4.36.0**. Follow strictly the internal module development standards defined in `@CLAUDE.md`. Use the helper script `@scripts/create-new-module.sh` to generate the initial structure.

## 🗂️ WORKTREE SETUP – CLAUDE MULTI-AGENT FLOW

To isolate agent work, each Claude agent should use a separate **Git worktree**, with its own branch and workspace.

### Worktree initialization:
```bash
git worktree add ../{{module_name}} feature/{{module_name}}
cd ../{{module_name}}
```

Once inside the new directory, you’ll work independently from other modules or agents.

---

## 🎯 GOAL

Create a standalone, production-ready Terraform module for `{{module_name}}`, supporting **all configuration scenarios** according to the latest AzureRM documentation. Ensure that the module is flexible, reusable, and documented.

---

## 📋 MAIN TASKS

### 1. 🧱 Use scaffolding script
```bash
bash @scripts/create-new-module.sh {{module_name}}
```
- Validate that `main.tf`, `variables.tf`, `outputs.tf`, `README.md`, and test directory were created

---

### 2. 📚 Schema exploration
- Research the full structure and capabilities of `azurerm_{{module_name}}` resource block using AzureRM provider version 4.36.0:
  - Official Terraform Registry
  - Azure provider changelog (breaking changes, deprecations, defaults)
- Document optional and required arguments

---

## 🛠️ PARALLEL AGENTS (run concurrently)

Each of the following sub-agents runs in its own Claude Code session inside its worktree:

### Agent A – `variables.tf`
- List and document all inputs with types, descriptions, and reasonable defaults
- Group by logical concerns (networking, security, flags)

### Agent B – `main.tf`
- Implement core resource block for `azurerm_{{module_name}}`
- Add conditional logic (e.g. `count`, `for_each`) as needed
- Support dynamic blocks and nested structures

### Agent C – `outputs.tf`
- Expose key attributes required by wrappers or consumers (e.g. IDs, names, computed attributes)

### Agent D – `README.md`
- Auto-generate markdown with Inputs/Outputs tables
- Add usage examples with minimal and full configuration
- Ensure consistency with internal module documentation style

### Agent E – `examples/basic/main.tf`
- Add an example for testing the module
- Showcase common real-world use (minimum config + all features)

---

## 🔁 QA & RELEASE PREP

- Validate `terraform validate` + `terraform fmt -check`
- Add meaningful CHANGELOG.md entry
- Commit using conventional format:
  ```bash
  git commit -m "feat({{module_name}}): initial release"
  ```

---

## 🚫 NOT IN SCOPE
- Do NOT implement `vnet`/`nsg`/`route` linking logic here – this will be part of the `azurerm_networking` wrapper
- Do NOT hardcode naming conventions or globals – inherit via input variables only
