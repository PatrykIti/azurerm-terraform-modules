# 4. Configuration Files

Configuration files are the backbone of the automation and standardization within the repository. They control everything from release automation to documentation generation.

## `module.json`

This file provides essential metadata about the module. It is used by various automation scripts, including the `semantic-release` configuration, to dynamically get information about the module.

**Fields:**
- `name`: The technical name of the module (e.g., `azurerm_kubernetes_cluster` or `azuredevops_project`). MUST match the directory name.
- `title`: A human-friendly name for the module (e.g., `Kubernetes Cluster`).
- `commit_scope`: The scope used in conventional commits (e.g., `kubernetes-cluster`).
- `tag_prefix`: The prefix for git tags for this module (e.g., `AKSv`).
- `description`: A brief description of the module's purpose.

**Template (`module.json`):**
```json
{
  "name": "azurerm_kubernetes_cluster",
  "title": "Kubernetes Cluster",
  "commit_scope": "kubernetes-cluster",
  "tag_prefix": "AKSv",
  "description": "Azure Kubernetes Terraform module with enterprise-grade security features"
}
```

---

## `.releaserc.js`

This file configures the `semantic-release` process for the module. The template provided is designed to be dynamic, loading its configuration from `module.json`. This means you rarely need to change this file.

**Key Features of the Template:**
- **Dynamic Scope**: Filters commits based on the `commit_scope` from `module.json`.
- **Custom Tagging**: Uses the `tag_prefix` from `module.json`.
- **Automated Updates**: Runs scripts to update the module version, examples, and `README.md` files upon release.
- **Conventional Commits**: Enforces conventional commit standards for automated changelog generation and version bumping.
- **Shell Compatibility**: `@semantic-release/exec` runs under `/bin/sh`, so `prepareCmd` must use POSIX syntax (`[ ... ]`).

**Template (`.releaserc.js`):**
```javascript
/**
 * Semantic Release Configuration with Auto-loaded Module Config
 * This configuration automatically loads module settings from module.json
 */

const path = require('path');
const fs = require('fs');

// Auto-detect module directory
const moduleDir = __dirname;
const moduleName = path.basename(moduleDir);

// Load module configuration
const configPath = path.join(moduleDir, 'module.json');
if (!fs.existsSync(configPath)) {
  throw new Error(`Module configuration not found at ${configPath}. Please create module.json with required fields.`);
}

const moduleConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));

// Validate required fields
const requiredFields = ['name', 'title', 'commit_scope', 'tag_prefix'];
for (const field of requiredFields) {
  if (!moduleConfig[field]) {
    throw new Error(`Missing required field '${field}' in module.json`);
  }
}

// Extract configuration
const { name, title, commit_scope, tag_prefix } = moduleConfig;

// ... (The rest of the standard .releaserc.js file)
// This part is generic and should be copied from a reference module like azurerm_kubernetes_cluster.
// It includes plugins for commit analysis, release notes, changelog, git, and github.
```

---

## `.terraform-docs.yml`

This file controls the generation of the module's `README.md` file using `terraform-docs`. It defines which sections to show, hide, and what custom content to inject.

**Best Practices:**
- **Header**: Use `header-from: main.tf` to pull the module's main description from the top of the `main.tf` file.
- **Minimal content**: Keep terraform-docs content focused on requirements/providers/resources/inputs/outputs. Put `Usage`, `Examples`, and `Notes` outside `<!-- BEGIN_TF_DOCS -->` markers in `README.md`.
- **Markers**: Use the standard `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` markers to define where the generated content should be injected.

**Template (`.terraform-docs.yml`, AKS-aligned):**
```yaml
formatter: "markdown table"

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules

sections:
  hide: []
  show: []

content: |-
  {{ .Header }}

  {{ .Requirements }}

  {{ .Providers }}

  {{ .Modules }}

  {{ .Resources }}

  {{ .Inputs }}

  {{ .Outputs }}

output:
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

# ... (other settings like sort, settings)
```
