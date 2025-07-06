# Azure Terraform Modules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)

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
├── azurerm_storage_account/     # Storage Account Module (SAv1.x.x)
├── azurerm_virtual_network/     # Virtual Network Module (VNv1.x.x)
├── azurerm_key_vault/          # Key Vault Module (KVv1.x.x)
├── azurerm_application_gateway/ # Application Gateway Module (AGv1.x.x)
├── docs/                       # Shared documentation and guides
├── scripts/                    # Shared automation scripts
├── .github/workflows/          # CI/CD workflows
└── .claude/references/         # AI development reference docs
```

## 🚀 Quick Start

### Using a Module

```hcl
module "storage_account" {
  source = "github.com/your-org/azurerm-terraform-modules//azurerm_storage_account?ref=SAv1.0.0"

  name                = "mystorageaccount"
  resource_group_name = "my-resource-group"
  location           = "West Europe"
  
  account_config = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic     = true
    min_tls_version         = "TLS1_2"
  }

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```


## 📦 Available Modules

### In Development

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| [Storage Account](./azurerm_storage_account/) | 🔧 Development | - | Azure Storage Account with enterprise features |
| [Virtual Network](./azurerm_virtual_network/) | 📅 Planned | - | Virtual networks with subnets and security |
| [Key Vault](./azurerm_key_vault/) | 📅 Planned | - | Key management and secrets storage |
| [Application Gateway](./azurerm_application_gateway/) | 📅 Planned | - | Application-layer load balancing |

### Development Roadmap

- **Phase 1**: Storage Account module with comprehensive features
- **Phase 2**: Virtual Network module with advanced networking
- **Phase 3**: Key Vault module with enterprise security
- **Phase 4**: Application Gateway module with SSL/WAF


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