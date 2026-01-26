# Terraform Azure Monitor Data Collection Endpoint Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Monitor Data Collection Endpoints

## Usage

```hcl
module "azurerm_monitor_data_collection_endpoint" {
  source = "path/to/azurerm_monitor_data_collection_endpoint"

  # Required variables
  name                = "example-azurerm_monitor_data_collection_endpoint"
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
- [Basic](examples/basic) - This example demonstrates a basic Monitor Data Collection Endpoint configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Monitor Data Collection Endpoint with all available features and configurations.
- [Secure](examples/secure) - This example demonstrates a security-focused Data Collection Endpoint configuration with public access disabled.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
