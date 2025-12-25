# Terraform Azure DevOps Wiki Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
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

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
