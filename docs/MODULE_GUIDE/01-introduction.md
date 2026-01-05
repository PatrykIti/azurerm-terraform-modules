# 1. Introduction to New Module Creation

This guide provides a comprehensive overview of the philosophy and standards for creating new Terraform modules in this repository. Adhering to these guidelines ensures consistency, quality, and maintainability across all modules.

## Guiding Principles

- **Comprehensive & Flexible**: Our goal is to build the world's leading repository of Terraform modules for Azure. Each module should be designed to be maximally flexible, exposing the full set of configuration options available for the underlying Azure resource(s). This ensures they can satisfy the widest possible range of use cases, from simple deployments to complex, enterprise-grade scenarios.
- **Consistency**: All modules should have a similar structure, file organization, and coding style. This makes them easier to understand, use, and maintain.
- **AKS as Baseline**: `azurerm_kubernetes_cluster` is the reference layout, but other resources may require deviations. Document and justify any differences in module docs.
- **Security-First**: Modules must implement security best practices by default. Secure configurations should be the easiest to deploy.
- **Production-Ready**: Every module should be robust enough for production use, with comprehensive testing, documentation, and examples.
- **Automation**: Leverage automation for documentation, testing, and releases to minimize manual effort and reduce errors.
- **Clarity**: Code, variables, and documentation should be clear and self-explanatory.

## Module Naming Convention

Module names are critical for identification and organization. They MUST follow the provider prefix pattern:

- `azurerm_<main_resource_type>` for AzureRM provider modules
- `azuredevops_<main_resource_type>` for Azure DevOps provider modules

The name should reflect the primary Azure resource the module manages. If the module orchestrates multiple primary resources, choose the most significant one.

Note: The repository name may still reference AzureRM. Azure DevOps modules are still expected to use the `azuredevops_` prefix and live alongside `azurerm_` modules.

### Examples

- **Correct**: `azurerm_storage_account`, `azurerm_virtual_network`, `azuredevops_project`, `azuredevops_repository`
- **Incorrect**: `storage`, `vnet_module`, `Azure-AKS`, `azdo_project`

## Primary Resource Requirement

Each module must manage its primary/root resource in `main.tf`. Sub-resources
(child resources) belong in the same module only when they are attached to that
primary resource. Do not create modules that manage only sub-resources without
the primary resource.
