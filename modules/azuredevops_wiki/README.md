# Terraform Azure DevOps Wiki Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps wiki module for managing a single wiki and strict-child pages.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "path/to/azuredevops_wiki"

  project_id = "00000000-0000-0000-0000-000000000000"

  wiki = {
    name = "Project Wiki"
    type = "projectWiki"
  }

  wiki_pages = {
    home = {
      path    = "/Home"
      content = "Welcome to the project wiki."
    }
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a project wiki with a home page.
- [Complete](examples/complete) - This example demonstrates a code wiki backed by a repository with multiple pages.
- [Secure](examples/secure) - This example demonstrates a wiki intended for security guidance.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps wiki resources into the module

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
| <a name="input_wiki"></a> [wiki](#input\_wiki) | Wiki configuration managed by this module instance. | <pre>object({<br/>    name          = string<br/>    type          = string<br/>    repository_id = optional(string)<br/>    version       = optional(string)<br/>    mapped_path   = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_wiki_pages"></a> [wiki\_pages](#input\_wiki\_pages) | Map of wiki pages keyed by a stable semantic key. | <pre>map(object({<br/>    path    = string<br/>    content = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wiki_id"></a> [wiki\_id](#output\_wiki\_id) | ID of the wiki created by this module. |
| <a name="output_wiki_ids"></a> [wiki\_ids](#output\_wiki\_ids) | Map containing the wiki ID under the stable key `wiki`. |
| <a name="output_wiki_name"></a> [wiki\_name](#output\_wiki\_name) | Name of the wiki created by this module. |
| <a name="output_wiki_page_ids"></a> [wiki\_page\_ids](#output\_wiki\_page\_ids) | Map of wiki page IDs keyed by stable page key. |
| <a name="output_wiki_remote_url"></a> [wiki\_remote\_url](#output\_wiki\_remote\_url) | Remote URL of the wiki created by this module. |
| <a name="output_wiki_remote_urls"></a> [wiki\_remote\_urls](#output\_wiki\_remote\_urls) | Map containing the wiki remote URL under the stable key `wiki`. |
| <a name="output_wiki_url"></a> [wiki\_url](#output\_wiki\_url) | REST API URL of the wiki created by this module. |
| <a name="output_wiki_urls"></a> [wiki\_urls](#output\_wiki\_urls) | Map containing the wiki REST URL under the stable key `wiki`. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
