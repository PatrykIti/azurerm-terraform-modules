# Terraform Azure Virtual Network Module

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-blue.svg)](https://www.terraform.io/)
[![AzureRM](https://img.shields.io/badge/AzureRM-4.35.0-blue.svg)](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0)

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This Terraform module creates and manages Azure Virtual Networks with comprehensive configuration options including:

- **Core Virtual Network**: Address spaces, DNS servers, flow timeout configuration
- **Security Features**: DDoS protection, encryption enforcement, network flow logs
- **Network Peering**: Virtual network peering with customizable settings
- **DNS Integration**: Private DNS zone virtual network links
- **Monitoring**: Diagnostic settings with Log Analytics and Storage Account integration
- **BGP Support**: BGP community configuration for ExpressRoute scenarios

## Features

- ✅ **Comprehensive Configuration**: Support for all Virtual Network features
- ✅ **Security-First**: DDoS protection, encryption, and comprehensive logging
- ✅ **Network Peering**: Automated peering setup with validation
- ✅ **DNS Integration**: Private DNS zone linking with registration control
- ✅ **Monitoring**: Built-in diagnostic settings and flow logs
- ✅ **Validation**: Input validation for all critical parameters
- ✅ **Lifecycle Management**: Prevent destroy protection for production environments

## Usage

### Basic Virtual Network

```hcl
module "virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_virtual_network?ref=VNvX.X.X"

  name                = "vnet-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### Secure Virtual Network with DDoS Protection

```hcl
module "secure_virtual_network" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_virtual_network?ref=VNvX.X.X"

  name                = "vnet-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  # Security Configuration
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  encryption = {
    enforcement = "DropUnencrypted"
  }

  # Monitoring
  diagnostic_settings = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    storage_account_id         = azurerm_storage_account.example.id
  }

  tags = {
    Environment   = "Production"
    SecurityLevel = "High"
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