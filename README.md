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

This repository follows a **multi-module approach** where each Azure resource type has its own independent module with separate versioning and CI/CD pipelines.

```
azurerm-terraform-modules/
azurerm_storage_account/    # Storage Account Module (SAv1.x.x)
azurerm_virtual_network/    # Virtual Network Module (VNv1.x.x)
azurerm_key_vault/          # Key Vault Module (KVv1.x.x)
azurerm_application_gateway/ # Application Gateway Module (AGv1.x.x)
docs/                       # Shared documentation
scripts/                    # Shared automation scripts
.github/workflows/          # CI/CD workflows
```

## 🚀 Quick Start

### Using a Module

```hcl
module "storage_account" {
  source = "github.com/your-org/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0"

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

### Module Versioning

Each module uses semantic versioning with descriptive prefixes:

- **Storage Account**: `SAv1.0.0`, `SAv1.1.0`, `SAv2.0.0`
- **Virtual Network**: `VNv1.0.0`, `VNv1.1.0`, `VNv2.0.0`
- **Key Vault**: `KVv1.0.0`, `KVv1.1.0`, `KVv2.0.0`
- **Application Gateway**: `AGv1.0.0`, `AGv1.1.0`, `AGv2.0.0`

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

## Key Features

### Security by Default
- **HTTPS-only traffic** enforcement
- **Minimum TLS version** configuration
- **Network access controls** and firewall rules
- **Private endpoint** support for network isolation
- **Diagnostic settings** for audit logging

### Enterprise Ready
- **Compliance frameworks** support (SOC 2, ISO 27001, GDPR)
- **Azure Monitor** integration
- **Advanced threat protection**
- **Backup and recovery** configurations
- **Multi-region** deployment support

### Developer Experience
- **HashiCorp best practices** implementation
- **Comprehensive validation** with helpful error messages
- **Structured outputs** for easy consumption
- **Complete examples** (simple and advanced)
- **Auto-generated documentation** with terraform-docs

### Quality Assurance
- **Automated testing** with Terratest
- **Security scanning** with Checkov, tfsec, and Terrascan
- **Code quality** enforcement with TFLint
- **Continuous integration** with GitHub Actions
- **Pre-commit hooks** for local validation
- **Performance benchmarking**

## Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.0
- [Go](https://golang.org/doc/install) >= 1.19 (for testing)
- [TFLint](https://github.com/terraform-linters/tflint) >= 0.48.0 (for code quality)

### Azure Permissions
- Contributor access to target Azure subscription
- Ability to create and manage Azure resources
- Access to Azure Active Directory (for Key Vault)

## 📖 Documentation Structure

### Core Documentation
- [**CLAUDE.md**](./CLAUDE.md) - AI development assistant guidelines and reference index
- [**Terraform Best Practices Guide**](./docs/TERRAFORM_BEST_PRACTISES_GUIDE.md) - Comprehensive module development standards
- [**Terraform Testing Guide**](./docs/TERRAFORM_TESTING_GUIDE.md) - Testing strategies, frameworks, and examples
- [**GitHub Actions Workflows**](./docs/WORKFLOWS.md) - CI/CD pipeline implementation and architecture
- [**Security Policy**](./docs/SECURITY.md) - Security guidelines and vulnerability reporting

### Module Documentation
Each module includes:
- **README.md** - Module overview, requirements, and usage examples
- **CHANGELOG.md** - Version history and breaking changes
- **examples/** - Simple and advanced usage examples
- **tests/** - Unit and integration test suites
- **docs/** - Additional module-specific documentation

### Development References
Located in `.claude/references/`:
- MCP tools usage and integration patterns
- TaskMaster workflow guidelines
- GitHub Actions architecture patterns
- Multi-agent development coordination

## Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](./docs/CONTRIBUTING.md) to get started.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes following our standards
4. Add or update tests
5. Update documentation
6. Submit a pull request

### Development Tools

This project is optimized for AI-assisted development:
- **TaskMaster** integration for task management and workflow coordination
- **MCP tools** for enhanced development capabilities
- **Multi-agent support** for parallel development streams
- See [CLAUDE.md](./CLAUDE.md) for detailed development guidelines
## 🔍 Code Quality with TFLint

### Running TFLint Locally
```bash
# Initialize TFLint with Azure plugin
tflint --init

# Run TFLint on a specific module
tflint --format=default --force modules/azurerm_storage_account/

# Run TFLint on all modules
find modules -name "*.tf" -exec dirname {} \; | sort -u | xargs -I {} tflint --format=default --force {}
```

### TFLint Configuration
This repository includes a comprehensive `.tflint.hcl` configuration that enforces:
- **Terraform best practices** and naming conventions
- **Azure-specific rules** and resource tagging requirements
- **Deprecated syntax** detection
- **Unused variables** and declaration checks
- **Required version** and provider specifications

### Custom Rules per Module
Modules can override specific TFLint rules by creating a `.tflint.hcl` file in their directory:
```hcl
# modules/azurerm_storage_account/.tflint.hcl
rule "azurerm_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "ManagedBy", "Project", "Owner"]
}
```
## Security

### Security Features
- All modules implement **security-by-default** configurations
- Regular **security scanning** with automated tools
- **Private endpoint** support for network isolation
- **Encryption at rest** and in transit
- **Access control** and audit logging

### Reporting Security Issues
Please see our [Security Policy](./docs/SECURITY.md) for information on reporting security vulnerabilities.

## 🔄 CI/CD Pipeline

### Automated Workflows
- **Validation**: Terraform format, validate, and TFLint analysis
- **Security**: Checkov, tfsec, Terrascan, and TFLint security scanning
- **Testing**: Terratest suite execution
- **Documentation**: Auto-generation with terraform-docs
- **Release**: Semantic versioning and GitHub releases

### Quality Gates
All modules must pass:
- ✅ Terraform validation
- ✅ TFLint code quality checks
- ✅ Security scans (zero critical issues)
- ✅ Test coverage (>80%)
- ✅ Documentation completeness
- ✅ Example functionality

## ⚡ Performance

### Benchmarks
- Module deployment: < 5 minutes (basic configurations)
- Module initialization: < 30 seconds
- CI/CD pipeline: < 10 minutes
- Test suite execution: < 15 minutes

## Versioning

This project uses [Semantic Versioning](https://semver.org/) with module-specific prefixes:

- **MAJOR**: Breaking changes or new major features
- **MINOR**: New features without breaking changes
- **PATCH**: Bug fixes and small improvements

Example: `SAv1.2.3` (Storage Account module, version 1.2.3)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [HashiCorp](https://www.hashicorp.com/) for Terraform and best practices
- [Azure](https://azure.microsoft.com/) for comprehensive cloud services
- The Terraform community for inspiration and contributions

## Support

- **Documentation**: Check module-specific README files
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join our GitHub Discussions
- **Security**: See our Security Policy for reporting

---

**Built with ❤️ by the Platform Engineering Team**

*This repository follows enterprise-grade standards for infrastructure as code. For development guidelines and AI-assisted workflows, see [CLAUDE.md](./CLAUDE.md).*