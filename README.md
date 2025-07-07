# Azure Terraform Modules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![AzureRM Provider](https://img.shields.io/badge/AzureRM_Provider-4.35.0-blue?logo=terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0)

<!-- MODULE BADGES START -->
<!-- MODULE BADGES END -->

A comprehensive collection of production-ready Terraform modules for Azure infrastructure, following HashiCorp best practices and enterprise security standards.

## 📚 Quick Navigation

- [**Development Guide**](./CLAUDE.md) - AI-assisted development guidelines and reference documentation
- [**Terraform Best Practices**](./docs/TERRAFORM_BEST_PRACTISES_GUIDE.md) - Module development standards and conventions
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
  source = "github.com/your-org/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"
  # See module README for configuration details
}
```


## 📦 Available Modules

### In Development

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| [Storage Account](./modules/azurerm_storage_account/) | 🔧 Development | - | Azure Storage Account with enterprise features |
| Virtual Network | 📅 Planned | - | Virtual networks with subnets and security |
| Key Vault | 📅 Planned | - | Key management and secrets storage |
| Application Gateway | 📅 Planned | - | Application-layer load balancing |

### Development Roadmap

- **Phase 1**: Storage Account module with comprehensive features
- **Phase 2**: Virtual Network module with advanced networking
- **Phase 3**: Key Vault module with enterprise security
- **Phase 4**: Application Gateway module with SSL/WAF

### Storage Account Module Examples

The Storage Account module includes comprehensive examples demonstrating various use cases:

| Example | Description |
|---------|-------------|
| [simple](./modules/azurerm_storage_account/examples/simple/) | Basic storage account with minimal configuration |
| [secure](./modules/azurerm_storage_account/examples/secure/) | Security-hardened configuration with maximum protection |
| [secure-private-endpoint](./modules/azurerm_storage_account/examples/secure-private-endpoint/) | Private endpoint configuration for network isolation |
| [data-lake-gen2](./modules/azurerm_storage_account/examples/data-lake-gen2/) | Data Lake Storage Gen2 with SFTP and NFSv3 |
| [advanced-policies](./modules/azurerm_storage_account/examples/advanced-policies/) | Advanced policies (SAS, immutability, routing) |
| [identity-access](./modules/azurerm_storage_account/examples/identity-access/) | Microsoft Entra ID authentication and RBAC |
| [complete](./modules/azurerm_storage_account/examples/complete/) | Full-featured storage account with all enterprise capabilities |
| [multi-region](./modules/azurerm_storage_account/examples/multi-region/) | Multi-region setup with disaster recovery |


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

**Built with ❤️ by the Platform Engineering Team**

*This repository follows enterprise-grade standards for infrastructure as code. For development guidelines and AI-assisted workflows, see [CLAUDE.md](./CLAUDE.md).*