# Azure Terraform Modules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.12.2-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![AzureRM Provider](https://img.shields.io/badge/AzureRM_Provider-4.57.0-blue?logo=terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0)
[![Azure DevOps Provider](https://img.shields.io/badge/Azure_DevOps_Provider-1.12.2-blue?logo=azuredevops)](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2)

<!-- MODULE BADGES START -->
[![Azure DevOps Artifacts Feed](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOAFv*&label=Azure%20DevOps%20Artifacts%20Feed&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOAFv)
[![Azure DevOps Agent Pools](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOAPv*&label=Azure%20DevOps%20Agent%20Pools&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOAPv)
[![Azure DevOps Work Items](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOWK*&label=Azure%20DevOps%20Work%20Items&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOWK)
[![Azure DevOps Wiki](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOWI*&label=Azure%20DevOps%20Wiki&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOWI)
[![Azure DevOps Variable Groups](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOVG*&label=Azure%20DevOps%20Variable%20Groups&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOVG)
[![Azure DevOps Team](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOT*&label=Azure%20DevOps%20Team&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOT)
[![Azure DevOps Service Hooks](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOSH*&label=Azure%20DevOps%20Service%20Hooks&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOSH)
[![Azure DevOps Service Endpoints](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOSE*&label=Azure%20DevOps%20Service%20Endpoints&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOSE)
[![Azure DevOps Repository](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOR*&label=Azure%20DevOps%20Repository&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOR)
[![Azure DevOps Pipelines](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOPI*&label=Azure%20DevOps%20Pipelines&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOPI)
[![Azure DevOps Identity](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOI*&label=Azure%20DevOps%20Identity&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOI)
[![Azure DevOps Extension](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOEX*&label=Azure%20DevOps%20Extension&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOEX)
[![Azure DevOps Environments](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOE*&label=Azure%20DevOps%20Environments&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOE)
[![Azure DevOps Artifacts Feed](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOAF*&label=Azure%20DevOps%20Artifacts%20Feed&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOAF)
[![Azure DevOps Agent Pools](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOAP*&label=Azure%20DevOps%20Agent%20Pools&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOAP)
[![Azure DevOps Project Permissions](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOPP*&label=Azure%20DevOps%20Project%20Permissions&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOPP)
[![Azure DevOps Project](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOP*&label=Azure%20DevOps%20Project&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=ADOP)
[![Storage Account](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=SAv*&label=Storage%20Account&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=SAv)
[![Virtual Network](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=VNv*&label=Virtual%20Network&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=VNv)
<!-- MODULE BADGES END -->

A comprehensive collection of production-ready Terraform modules for Azure and Azure DevOps, aligned with HashiCorp best practices and security-first defaults.

## 📚 Quick Navigation

- [**Repository Standards**](./AGENTS.md) - Module layout, naming, and security-first conventions
- [**Docs Index**](./docs/README.md) - Entry point for all documentation
- [**Modules Index**](./modules/README.md) - Index of all modules with tag prefixes and descriptions
- [**Module Creation Guide**](./docs/MODULE_GUIDE/README.md) - End-to-end module scaffolding guide
- [**Terraform Best Practices**](./docs/TERRAFORM_BEST_PRACTICES_GUIDE.md) - Implementation standards and conventions
- [**Testing Guide**](./docs/TESTING_GUIDE/README.md) - Testing expectations and patterns
- [**Workflows Documentation**](./docs/WORKFLOWS.md) - CI/CD pipeline details
- [**Security Policy**](./docs/SECURITY.md) - Security guidelines and reporting

## Repository Structure

```
azurerm-terraform-modules/
├── modules/                             # Terraform modules (azurerm_* and azuredevops_*)
│   ├── azurerm_<resource>/              # Azure Resource Manager modules
│   └── azuredevops_<resource>/          # Azure DevOps modules
├── docs/                                # Global documentation
│   ├── MODULE_GUIDE/                    # Module creation guide
│   └── TESTING_GUIDE/                   # Testing reference
├── scripts/                             # Automation scripts
├── security-policies/                   # Security policy definitions
├── examples/                            # Cross-module examples (if any)
└── .github/                             # GitHub Actions workflows and templates
```

## 🚀 Quick Start

Each module includes usage documentation and ready-to-run examples:

1. **Browse modules** in the [`modules/`](./modules/) directory
2. **Read module documentation** - Each module has its own README and `docs/IMPORT.md` where applicable
3. **Start with examples** - Every module includes `examples/basic`, `examples/complete`, and `examples/secure`

Azure DevOps modules use the `azuredevops` provider and typically require a PAT or service connection.

Example module reference:
```hcl
module "storage_account" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.2"
  # See module README for configuration details
}
```

## 📦 Available Modules

### AzureRM Modules

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| [Kubernetes Cluster](./modules/azurerm_kubernetes_cluster/) | ✅ Completed | [AKSv1.0.4](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AKSv1.0.4) | Azure Kubernetes Service (AKS) Terraform module for managing clusters with node pools, addons, and enterprise-grade security features |
| [Kubernetes Secrets](./modules/azurerm_kubernetes_secrets/) | 🔧 Development | - | Azure Kubernetes Secrets Terraform module with enterprise-grade features |
| [Network Security Group](./modules/azurerm_network_security_group/) | ✅ Completed | [NSGv1.0.3](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/NSGv1.0.3) | Manages Azure Network Security Groups with comprehensive security rules configuration |
| [Route Table](./modules/azurerm_route_table/) | ✅ Completed | [RTv1.0.3](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RTv1.0.3) | Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations |
| [Storage Account](./modules/azurerm_storage_account/) | ✅ Completed | [SAv1.2.2](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SAv1.2.2) | Azure Storage Account Terraform module with enterprise-grade security features |
| [Subnet](./modules/azurerm_subnet/) | ✅ Completed | [SNv1.0.3](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SNv1.0.3) | Azure Subnet Terraform module for managing subnets with service endpoints, delegations, network policies, and enterprise-grade security features |
| [Virtual Network](./modules/azurerm_virtual_network/) | ✅ Completed | [VNv1.1.3](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/VNv1.1.3) | Azure Virtual Network Terraform module with advanced networking features |

### Azure DevOps Modules

| Module | Status | Version | Description |
|--------|--------|---------|-------------|
| [Azure DevOps Agent Pools](./modules/azuredevops_agent_pools/) | ✅ Completed | [ADOAPv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOAPv1.0.0) | Azure DevOps agent pools module for managing pools, queues, and elastic pools |
| [Azure DevOps Artifacts Feed](./modules/azuredevops_artifacts_feed/) | ✅ Completed | [ADOAFv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOAFv1.0.0) | Azure DevOps artifacts feed module for managing feeds, retention, and permissions |
| [Azure DevOps Environments](./modules/azuredevops_environments/) | ✅ Completed | [ADOE1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOE1.0.0) | Azure DevOps environments module for managing environments, resources, and checks |
| [Azure DevOps Extension](./modules/azuredevops_extension/) | ✅ Completed | [ADOEX1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEX1.0.0) | Azure DevOps extension module for managing Marketplace extensions |
| [Azure DevOps Identity](./modules/azuredevops_identity/) | ✅ Completed | [ADOI1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOI1.0.0) | Azure DevOps identity module for managing groups, entitlements, memberships, and role assignments |
| [Azure DevOps Pipelines](./modules/azuredevops_pipelines/) | ✅ Completed | [ADOPI1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOPI1.0.0) | Azure DevOps pipelines module for managing build definitions, folders, permissions, and authorizations |
| [Azure DevOps Project](./modules/azuredevops_project/) | ✅ Completed | [ADOP1.1.1](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOP1.1.1) | Azure DevOps project module for managing project settings, tags, and dashboards |
| [Azure DevOps Project Permissions](./modules/azuredevops_project_permissions/) | ✅ Completed | [ADOPP1.1.1](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOPP1.1.1) | Azure DevOps project permissions module for assigning group permissions |
| [Azure DevOps Repository](./modules/azuredevops_repository/) | ✅ Completed | [ADOR1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOR1.0.0) | Azure DevOps repository module for managing Git repositories and policies |
| [Azure DevOps Service Endpoints](./modules/azuredevops_serviceendpoint/) | ✅ Completed | [ADOSE1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOSE1.0.0) | Azure DevOps service endpoints module for managing service connections and permissions |
| [Azure DevOps Service Hooks](./modules/azuredevops_servicehooks/) | ✅ Completed | [ADOSH1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOSH1.0.0) | Azure DevOps service hooks module for managing subscriptions and permissions |
| [Azure DevOps Team](./modules/azuredevops_team/) | ✅ Completed | [ADOT1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOT1.0.0) | Azure DevOps team module for managing teams, members, and administrators |
| [Azure DevOps Variable Groups](./modules/azuredevops_variable_groups/) | ✅ Completed | [ADOVG1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOVG1.0.0) | Azure DevOps variable groups module for managing variables and library permissions |
| [Azure DevOps Wiki](./modules/azuredevops_wiki/) | ✅ Completed | [ADOWI1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOWI1.0.0) | Azure DevOps wiki module for managing wikis and pages |
| [Azure DevOps Work Items](./modules/azuredevops_work_items/) | ✅ Completed | [ADOWK1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOWK1.0.0) | Azure DevOps work items module for managing processes, queries, and permissions |

Versions are sourced from module changelogs and release tags. Modules without a tagged release remain in Development.

### Storage Account Module Examples

The Storage Account module ships with a full example catalog:

| Example | Description |
|---------|-------------|
| [basic](./modules/azurerm_storage_account/examples/basic/README.md) | Minimal storage account with secure defaults |
| [complete](./modules/azurerm_storage_account/examples/complete/README.md) | Full feature coverage |
| [secure](./modules/azurerm_storage_account/examples/secure/README.md) | Hardened configuration |
| [secure-private-endpoint](./modules/azurerm_storage_account/examples/secure-private-endpoint/README.md) | Private endpoints and security controls |
| [data-lake-gen2](./modules/azurerm_storage_account/examples/data-lake-gen2/README.md) | ADLS Gen2 with SFTP/NFS |
| [advanced-policies](./modules/azurerm_storage_account/examples/advanced-policies/README.md) | SAS/immutability/routing policies |
| [identity-access](./modules/azurerm_storage_account/examples/identity-access/README.md) | Managed identities and keyless auth |
| [multi-region](./modules/azurerm_storage_account/examples/multi-region/README.md) | Multi-region replication patterns |

Other modules include their own example catalogs under `modules/<module>/examples`.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.12.2
- [AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm) 4.57.0 (for `azurerm_*` modules)
- [Azure DevOps Provider](https://registry.terraform.io/providers/microsoft/azuredevops) 1.12.2 (for `azuredevops_*` modules)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure authentication and examples)
- [Go](https://golang.org/doc/install) >= 1.21 (for Terratest)

## Contributing

We welcome contributions! Start with the repository guidelines and contribution docs:
- [**AGENTS.md**](./AGENTS.md) - Standards and conventions
- [**CONTRIBUTING.md**](./CONTRIBUTING.md) - Contribution process
- [**Module Creation Guide**](./docs/MODULE_GUIDE/README.md) - Scaffold new modules

## Versioning

Each module uses Semantic Versioning with a module-specific tag prefix defined in `module.json` (for example: `SAv1.2.2`, `AKSv1.0.4`). Release notes live in each module's `CHANGELOG.md` and in GitHub releases.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Support

- **Issues**: Report bugs via GitHub Issues
- **Security**: See [Security Policy](./docs/SECURITY.md)
- **Documentation**: Module README files and the [docs index](./docs/README.md)

---

**Built with ❤️ by PatrykIti for Infrastructure Teams**

*This repository follows enterprise-grade standards for infrastructure as code. For development guidelines, see [AGENTS.md](./AGENTS.md) or browse the [Documentation](./docs/README.md).*
