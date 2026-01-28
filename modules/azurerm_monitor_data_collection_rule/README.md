# Terraform Azure Monitor Data Collection Rule Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Monitor Data Collection Rules

## Usage

```hcl
module "azurerm_monitor_data_collection_rule" {
  source = "path/to/azurerm_monitor_data_collection_rule"

  # Required variables
  name                = "example-azurerm_monitor_data_collection_rule"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Optional configuration
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Monitor Data Collection Rule configuration using secure defaults and minimal setup.
- [AKS Basic](examples/aks-basic) - This example demonstrates an AKS Container Insights DCR configuration using the basic stream profile.
- [AKS Advanced](examples/aks-advanced) - This example demonstrates an AKS Container Insights DCR configuration using the advanced stream profile.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Monitor Data Collection Rule with all available features and configurations.
- [Secure](examples/secure) - This example demonstrates a DCR configured to use a dedicated Data Collection Endpoint with public access disabled on the endpoint.
- [Syslog](examples/syslog) - This example demonstrates a Data Collection Rule configured for Linux syslog data.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
