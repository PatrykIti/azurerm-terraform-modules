# Terraform Azure DevOps Wiki Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps wiki module for managing project and code wikis with pages.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "path/to/azuredevops_wiki"

  project_id = "00000000-0000-0000-0000-000000000000"

  wikis = {
    project = {
      name = "Project Wiki"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Home"
      content  = "Welcome to the project wiki."
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a project wiki with a home page.
- [Complete](examples/complete) - This example demonstrates a code wiki backed by a repository with multiple pages.
- [Secure](examples/secure) - This example demonstrates a minimal wiki intended for security guidance.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps wikis into the module


<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_wiki.wiki](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/wiki) | resource |
| [azuredevops_wiki_page.wiki_page](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/wiki_page) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_wiki_pages"></a> [wiki\_pages](#input\_wiki\_pages) | List of wiki pages to manage. | <pre>list(object({<br/>    wiki_id  = optional(string)<br/>    wiki_key = optional(string)<br/>    path     = string<br/>    content  = string<br/>  }))</pre> | `[]` | no |
| <a name="input_wikis"></a> [wikis](#input\_wikis) | Map of wikis to manage. | <pre>map(object({<br/>    name          = optional(string)<br/>    type          = string<br/>    repository_id = optional(string)<br/>    version       = optional(string)<br/>    mapped_path   = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wiki_ids"></a> [wiki\_ids](#output\_wiki\_ids) | Map of wiki IDs keyed by wiki key. |
| <a name="output_wiki_page_ids"></a> [wiki\_page\_ids](#output\_wiki\_page\_ids) | Map of wiki page IDs keyed by index. |
| <a name="output_wiki_remote_urls"></a> [wiki\_remote\_urls](#output\_wiki\_remote\_urls) | Map of wiki remote URLs keyed by wiki key. |
| <a name="output_wiki_urls"></a> [wiki\_urls](#output\_wiki\_urls) | Map of wiki REST URLs keyed by wiki key. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
