# 1. Introduction to New Module Creation

This guide provides a comprehensive overview of the philosophy and standards for creating new Terraform modules in this repository. Adhering to these guidelines ensures consistency, quality, and maintainability across all modules.

## Guiding Principles

- **Comprehensive & Flexible**: Our goal is to build the world's leading repository of Terraform modules for Azure. Each module should be designed to be maximally flexible, exposing the full set of configuration options available for the underlying Azure resource(s). This ensures they can satisfy the widest possible range of use cases, from simple deployments to complex, enterprise-grade scenarios.
- **Consistency**: All modules should have a similar structure, file organization, and coding style. This makes them easier to understand, use, and maintain.
- **Security-First**: Modules must implement security best practices by default. Secure configurations should be the easiest to deploy.
- **Production-Ready**: Every module should be robust enough for production use, with comprehensive testing, documentation, and examples.
- **Automation**: Leverage automation for documentation, testing, and releases to minimize manual effort and reduce errors.
- **Clarity**: Code, variables, and documentation should be clear and self-explanatory.

## Module Naming Convention

Module names are critical for identification and organization. They MUST follow the pattern: `azurerm_<main_resource_type>`.

The name should reflect the primary Azure resource the module manages. If the module orchestrates multiple primary resources, choose the most significant one.

### Examples

- **Correct**: `azurerm_storage_account`, `azurerm_virtual_network`, `azurerm_kubernetes_cluster`
- **Incorrect**: `storage`, `vnet_module`, `Azure-AKS`
