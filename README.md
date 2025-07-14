# Azure Terraform Modules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![AzureRM Provider](https://img.shields.io/badge/AzureRM_Provider-4.36.0-blue?logo=terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0)

<!-- MODULE BADGES START -->
[![Storage Account](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=SAv*&label=Storage%20Account&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=SAv1.0.0)
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
├── modules/                     # Terraform modules
│   └── azurerm_storage_account/ # Storage Account module
├── docs/                        # Shared documentation
├── scripts/                     # Automation scripts
├── examples/                    # Cross-module examples
├── tests/                       # Shared test utilities
├── security-policies/           # Custom security policies
├── build-templates/             # Azure Pipelines templates (coming soon)
│   ├── versioning/              # Versioning pipeline templates
│   ├── documentation/           # Documentation generation templates
│   ├── security/                # Security scanning templates
│   ├── testing/                 # Testing pipeline templates
│   └── release/                 # Release pipeline templates
├── .github/workflows/           # CI/CD workflows
└── .claude/references/          # AI development guides
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
| [Storage Account](./modules/azurerm_storage_account/) | ✅ Completed | [SAv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SAv1.0.0) | Azure Storage Account with enterprise features |

### In Development

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| Networking | 🔧 Development | - | Virtual networks with subnets and security |
| SQL Server | 🔧 Development | - | Azure SQL Server and database management |
| AKS | 🔧 Development | - | Azure Kubernetes Service cluster |
| Key Vault | 🔧 Development | - | Key management and secrets storage |
| App Service | 🔧 Development | - | Web Apps and Function Apps hosting |

### Development Roadmap

- **Phase 1**: Storage Account module with comprehensive features ✅
- **Phase 2**: Networking module with virtual networks and security
- **Phase 3**: Key Vault module with enterprise security
- **Phase 4**: SQL Server module with database management
- **Phase 5**: AKS module for Kubernetes workloads
- **Phase 6**: App Service module for web applications

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

**Built with ❤️ by PatrykIti**

*This repository follows enterprise-grade standards for infrastructure as code. For development guidelines and AI-assisted workflows, see [CLAUDE.md](./CLAUDE.md).*