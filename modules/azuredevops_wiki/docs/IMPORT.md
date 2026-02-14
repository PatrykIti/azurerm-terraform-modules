# Import existing Azure DevOps wiki and pages

This guide shows how to import an existing wiki and pages into
`modules/azuredevops_wiki` using Terraform import blocks.

## 1) Minimal module configuration

```hcl
module "azuredevops_wiki" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_wiki?ref=ADOWIv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  wiki = {
    name = "Project Wiki"
    type = "projectWiki"
  }

  wiki_pages = {
    home = {
      path    = "/Home"
      content = "Welcome"
    }
  }
}
```

## 2) Import wiki resource

```hcl
import {
  to = module.azuredevops_wiki.azuredevops_wiki.wiki
  id = "<wiki_id>"
}
```

## 3) Import wiki pages (optional)

Use stable page keys from `wiki_pages` map.

```hcl
import {
  to = module.azuredevops_wiki.azuredevops_wiki_page.wiki_page["home"]
  id = "<wiki_page_import_id>"
}
```

## 4) Run import

```bash
terraform init
terraform plan
terraform apply
```
