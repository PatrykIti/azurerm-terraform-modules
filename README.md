# Azure Terraform Modules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![AzureRM Provider](https://img.shields.io/badge/AzureRM_Provider-4.36.0-blue?logo=terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0)

<!-- MODULE BADGES START -->
[![Storage Account](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=SAv*&label=Storage%20Account&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=SAv1.1.0)
[![Virtual Network](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=VNv*&label=Virtual%20Network&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=VNv1.0.1)
<!-- MODULE BADGES END -->

A comprehensive collection of production-ready Terraform modules for Azure infrastructure, following HashiCorp best practices and enterprise security standards.

## 📚 Quick Navigation

- [**Development Guide**](./CLAUDE.md) - AI-assisted development guidelines and reference documentation
- [**Terraform Best Practices**](./docs/TERRAFORM_BEST_PRACTICES_GUIDE.md) - Module development standards and conventions
- [**Testing Guide**](./docs/TERRAFORM_TESTING_GUIDE.md) - Comprehensive testing strategies and examples
- [**Workflows Documentation**](./docs/WORKFLOWS.md) - GitHub Actions CI/CD implementation details
- [**Security Policy**](./docs/SECURITY.md) - Security guidelines and vulnerability reporting

## Repository Structure

```
azurerm-terraform-modules/
├── modules/                             # Terraform modules
│   ├── azurerm_kubernetes_cluster/     # AKS Kubernetes cluster module
│   ├── azurerm_network_security_group/ # Network Security Group module
│   ├── azurerm_route_table/            # Route Table module
│   ├── azurerm_storage_account/        # Storage Account module
│   ├── azurerm_subnet/                 # Subnet module
│   └── azurerm_virtual_network/        # Virtual Network module
├── docs/                                # Shared documentation
├── scripts/                             # Automation scripts
├── examples/                            # Cross-module examples
├── tests/                               # Shared test utilities
├── security-policies/                   # Custom security policies
├── build-templates/                     # Azure Pipelines templates (coming soon)
│   ├── versioning/                      # Versioning pipeline templates
│   ├── documentation/                   # Documentation generation templates
│   ├── security/                        # Security scanning templates
│   ├── testing/                         # Testing pipeline templates
│   └── release/                         # Release pipeline templates
├── .github/workflows/                   # CI/CD workflows
└── .claude/references/                  # AI development guides
```

## 🚀 Quick Start

Each module contains comprehensive documentation and examples:

1. **Browse modules** in the [`modules/`](./modules/) directory
2. **Read module documentation** - Each module has its own README with:
   - Usage examples
   - Input/output specifications
   - Requirements and prerequisites
3. **Check examples** - Each module includes `examples/` directory with:
   - Simple usage
   - Advanced configurations
   - Security-hardened setups
   - Multi-region deployments

Example module reference:
```hcl
module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"
  # See module README for configuration details
}
```


## 📦 Available Modules

### Production Ready

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| [Storage Account](./modules/azurerm_storage_account/) | ✅ Completed | [SAv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SAv1.0.0) | Azure Storage Account with enterprise features |
| [Virtual Network](./modules/azurerm_virtual_network/) | ✅ Completed | [VNv1.0.1](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=VNv1.0.0) | Virtual Network with full networking capabilities |
| [Kubernetes Cluster](./modules/azurerm_kubernetes_cluster/) | ✅ Completed | v1.0.0 | Azure Kubernetes Service (AKS) cluster with enterprise features |
| [Network Security Group](./modules/azurerm_network_security_group/) | ✅ Completed | v1.0.0 | Network Security Group with comprehensive rule management |
| [Route Table](./modules/azurerm_route_table/) | ✅ Completed | v1.0.0 | Route Table with custom routing rules and BGP support |
| [Subnet](./modules/azurerm_subnet/) | ✅ Completed | v1.0.0 | Subnet module with service endpoints and delegation support |

### In Development

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| SQL Server | 🔧 Development | - | Azure SQL Server |
| Key Vault | 🔧 Development | - | Key management all features |
| App Service Plan | 🔧 Development | - | App Service Plan with enterprise features |

### Development Roadmap

- **Phase 1**: Core Infrastructure Modules ✅
  - Storage Account with comprehensive features ✅
  - Virtual Network with full networking capabilities ✅
  - Subnet with service endpoints and delegation ✅
  - Network Security Group with rule management ✅
  - Route Table with custom routing ✅
- **Phase 2**: Container and Orchestration ✅
  - AKS (Azure Kubernetes Service) cluster ✅
- **Phase 3**: Security and Data (In Progress)
  - Key Vault module with enterprise security
  - SQL Server with high availability
- **Phase 4**: Application Platform (Planned)
  - App Service Plan with enterprise features
  - Application Gateway
  - API Management
### Storage Account Module Examples

The Storage Account module includes comprehensive examples demonstrating various use cases:

| Example | Description |
|---------|-------------|
| [basic](./modules/azurerm_storage_account/examples/basic/README.md) | Basic storage account with minimal configuration |
| [secure](./modules/azurerm_storage_account/examples/secure/README.md) | Security-hardened configuration with maximum protection |
| [secure-private-endpoint](./modules/azurerm_storage_account/examples/secure-private-endpoint/README.md) | Private endpoint configuration for network isolation |
| [data-lake-gen2](./modules/azurerm_storage_account/examples/data-lake-gen2/README.md) | Data Lake Storage Gen2 with SFTP and NFSv3 |
| [advanced-policies](./modules/azurerm_storage_account/examples/advanced-policies/README.md) | Advanced policies (SAS, immutability, routing) |
| [identity-access](./modules/azurerm_storage_account/examples/identity-access/README.md) | Microsoft Entra ID authentication and RBAC |
| [complete](./modules/azurerm_storage_account/examples/complete/README.md) | Full-featured storage account with all enterprise capabilities |
| [multi-region](./modules/azurerm_storage_account/examples/multi-region/README.md) | Multi-region setup with disaster recovery |


## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.0
- [Go](https://golang.org/doc/install) >= 1.19 (for testing)
- [TFLint](https://github.com/terraform-linters/tflint) >= 0.48.0 (for code quality)
- Azure subscription with appropriate permissions


## Contributing

We welcome contributions! This project is optimized for AI-assisted development with TaskMaster and MCP tools integration.

For development guidelines and contribution process, see:
- [**CLAUDE.md**](./CLAUDE.md) - AI development guidelines
- [**Contributing Guide**](./docs/CONTRIBUTING.md) - Contribution process (when available)



## Versioning

Each module uses [Semantic Versioning](https://semver.org/) with module-specific prefixes (e.g., `SAv1.2.3` for Storage Account v1.2.3).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Support

- **Issues**: Report bugs via GitHub Issues
- **Security**: See [Security Policy](./docs/SECURITY.md)
- **Documentation**: Check module-specific README files

---

**Built with ❤️ by PatrykIti for Infrastructure Teams**

*This repository follows enterprise-grade standards for infrastructure as code. For development guidelines and AI-assisted workflows, see [CLAUDE.md](./CLAUDE.md).*