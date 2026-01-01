# Import existing Azure DevOps Pipelines into the module

This guide explains how to import existing Azure DevOps build definitions and
folders into `modules/azuredevops_pipelines` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
pipeline settings.

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_pipelines" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_pipelines?ref=ADOPIv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  name = "existing-build-definition-name"

  repository = {
    repo_type = "TfsGit"
    repo_id   = "00000000-0000-0000-0000-000000000000"
    yml_path  = "azure-pipelines.yml"
  }

  build_folders = [
    {
      key  = "pipelines"
      path = "\\Pipelines"
    }
  ]
}
```

---

## 2) Import build definitions

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_pipelines.azuredevops_build_definition.build_definition
  id = "<build_definition_id>"
}
```

Use the build definition ID from Azure DevOps (UI or REST API). Refer to the
Azure DevOps provider documentation for the exact import ID format.

---

## 3) Import build folders (optional)

If you manage build folders, ensure each folder has a stable `key` and add an
import block:

```hcl
import {
  to = module.azuredevops_pipelines.azuredevops_build_folder.build_folder["pipelines"]
  id = "<build_folder_import_id>"
}
```

The import ID format varies by resource; follow the Azure DevOps provider
documentation for `azuredevops_build_folder`.

---

## 4) Permissions and authorizations (optional)

If you manage `build_definition_permissions`, `build_folder_permissions`,
`pipeline_authorizations`, or legacy `resource_authorizations` (mapped to
`azuredevops_pipeline_authorization`), set a stable `key` for each item so the
import address remains consistent (default keys are derived from principal or
`type:resource_id` pairs):

```hcl
import {
  to = module.azuredevops_pipelines.azuredevops_pipeline_authorization.pipeline_authorization["app-endpoint"]
  id = "<pipeline_authorization_import_id>"
}
```

Import support and ID formats vary across provider resources. Check the Azure
DevOps provider documentation to confirm support for each resource.

---

## 5) Run the import

```bash
terraform init
terraform plan
terraform apply
```

When the plan is clean, remove `import.tf`.
