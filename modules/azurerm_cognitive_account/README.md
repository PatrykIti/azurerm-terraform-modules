# Terraform Azure Cognitive Account Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Cognitive Services accounts for OpenAI, Language (TextAnalytics), and Speech services.

## Usage

```hcl
module "cognitive_account" {
  source = "path/to/azurerm_cognitive_account"

  name                = "example-openai"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = true
  local_auth_enabled            = true

  tags = {
    Environment = "Development"
    Service     = "OpenAI"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Additional module documentation
- [docs/IMPORT.md](docs/IMPORT.md) - Import instructions
