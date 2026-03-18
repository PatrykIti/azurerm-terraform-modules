# Azure Terraform Modules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.12.2-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![AzureRM Provider](https://img.shields.io/badge/AzureRM_Provider-4.57.0-blue?logo=terraform)](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0)
[![Azure DevOps Provider](https://img.shields.io/badge/Azure_DevOps_Provider-1.12.2-blue?logo=azuredevops)](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2)

<!-- MODULE BADGES START -->
[![AI Services](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=AISv*&label=AI%20Services&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AISv1.0.0)
[![Application Insights](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=APPINSv*&label=Application%20Insights&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/APPINSv1.1.0)
[![Application Insights Workbook](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=AIWBv*&label=Application%20Insights%20Workbook&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AIWBv1.0.0)
[![Azure DevOps Agent Pools](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOAPv*&label=Azure%20DevOps%20Agent%20Pools&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOAPv2.0.0)
[![Azure DevOps Artifacts Feed](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOAFv*&label=Azure%20DevOps%20Artifacts%20Feed&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOAFv2.0.0)
[![Azure DevOps Elastic Pool](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOEPv*&label=Azure%20DevOps%20Elastic%20Pool&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEPv1.0.0)
[![Azure DevOps Environments](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOEv*&label=Azure%20DevOps%20Environments&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEv2.0.0)
[![Azure DevOps Extension](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOEXv*&label=Azure%20DevOps%20Extension&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEXv2.0.0)
[![Azure DevOps Group](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOGv*&label=Azure%20DevOps%20Group&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOGv2.0.0)
[![Azure DevOps Group Entitlement](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOGEv*&label=Azure%20DevOps%20Group%20Entitlement&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOGEv1.0.0)
[![Azure DevOps Project](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOPv*&label=Azure%20DevOps%20Project&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOPv1.0.0)
[![Azure DevOps Project Permissions](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOPPv*&label=Azure%20DevOps%20Project%20Permissions&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOPPv1.0.0)
[![Azure DevOps Repository](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADORv*&label=Azure%20DevOps%20Repository&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADORv1.0.3)
[![Azure DevOps Security Role Assignment](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOSRAv*&label=Azure%20DevOps%20Security%20Role%20Assignment&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOSRAv1.0.0)
[![Azure DevOps Service Principal Entitlement](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOSPEv*&label=Azure%20DevOps%20Service%20Principal%20Entitlement&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOSPEv1.0.0)
[![Azure DevOps User Entitlement](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=ADOUv*&label=Azure%20DevOps%20User%20Entitlement&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOUv1.0.0)
[![Bastion Host](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=BASTIONv*&label=Bastion%20Host&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/BASTIONv1.0.0)
[![Cognitive Account](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=COGv*&label=Cognitive%20Account&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/COGv1.0.0)
[![Event Hub](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=EHv*&label=Event%20Hub&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/EHv1.0.0)
[![Event Hub Namespace](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=EHNSv*&label=Event%20Hub%20Namespace&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/EHNSv1.0.0)
[![Key Vault](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=KVv*&label=Key%20Vault&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/KVv1.0.0)
[![Kubernetes Cluster](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=AKSv*&label=Kubernetes%20Cluster&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AKSv2.1.0)
[![Kubernetes Secrets](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=AKSSv*&label=Kubernetes%20Secrets&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AKSSv1.0.0)
[![Linux Function App](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=LFUNCv*&label=Linux%20Function%20App&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/LFUNCv1.0.0)
[![Linux Virtual Machine](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=LINUXVMv*&label=Linux%20Virtual%20Machine&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/LINUXVMv1.0.0)
[![Log Analytics Workspace](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=LAWv*&label=Log%20Analytics%20Workspace&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/LAWv1.1.0)
[![Monitor Data Collection Endpoint](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=DCEv*&label=Monitor%20Data%20Collection%20Endpoint&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/DCEv1.0.0)
[![Monitor Data Collection Rule](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=DCRv*&label=Monitor%20Data%20Collection%20Rule&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/DCRv1.0.0)
[![Monitor Private Link Scope](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=AMPLSv*&label=Monitor%20Private%20Link%20Scope&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AMPLSv1.0.0)
[![Network Security Group](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=NSGv*&label=Network%20Security%20Group&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/NSGv1.1.0)
[![PostgreSQL Flexible Server](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=PGFSv*&label=PostgreSQL%20Flexible%20Server&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PGFSv1.1.0)
[![PostgreSQL Flexible Server Database](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=PGFSDBv*&label=PostgreSQL%20Flexible%20Server%20Database&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PGFSDBv1.0.0)
[![Private DNS Zone](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=PDNSZv*&label=Private%20DNS%20Zone&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PDNSZv1.0.0)
[![Private DNS Zone Virtual Network Link](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=PDNSZLNKv*&label=Private%20DNS%20Zone%20Virtual%20Network%20Link&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PDNSZLNKv1.0.0)
[![Private Endpoint](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=PEv*&label=Private%20Endpoint&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PEv1.0.0)
[![Redis Cache](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=REDISv*&label=Redis%20Cache&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/REDISv1.0.0)
[![Role Assignment](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=RAv*&label=Role%20Assignment&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RAv1.0.0)
[![Role Definition](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=RDv*&label=Role%20Definition&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RDv1.0.0)
[![Route Table](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=RTv*&label=Route%20Table&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RTv1.1.0)
[![Storage Account](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=SAv*&label=Storage%20Account&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SAv2.1.0)
[![Subnet](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=SNv*&label=Subnet&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SNv1.1.0)
[![User Assigned Identity](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=UAIv*&label=User%20Assigned%20Identity&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/UAIv1.0.0)
[![Virtual Network](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=VNv*&label=Virtual%20Network&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/VNv1.2.0)
[![Windows Function App](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=WFUNCv*&label=Windows%20Function%20App&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/WFUNCv1.0.0)
[![Windows Virtual Machine](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=WINDOWSVMv*&label=Windows%20Virtual%20Machine&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/WINDOWSVMv1.0.0)
<!-- MODULE BADGES END -->

A comprehensive collection of production-ready Terraform modules for Azure and Azure DevOps, aligned with HashiCorp best practices and security-first defaults.

Modules are **atomic**: each module manages a single primary resource with no nested modules. Cross-resource glue such as private endpoints, RBAC/role assignments, or budgets lives in dedicated modules or higher-level environment configurations. Diagnostic settings stay inline in each module (duplication is intentional to avoid coupling releases). Cross-module compositions will be published in the root `examples/` catalog as it grows.

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
4. **See compositions** - Cross-module compositions will be added under the root [`examples/`](./examples/) catalog as it expands

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

<!-- AZURERM_MODULES_TABLE_START -->
| Module | Status | Version | Description |
| --- | --- | --- | --- |
| [AI Services](./modules/azurerm_ai_services/) | ✅ Completed | [AISv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AISv1.0.0) | Azure AI Services Terraform module with identity, CMK, network ACLs, and diagnostics support |
| [Application Insights](./modules/azurerm_application_insights/) | ✅ Completed | [APPINSv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/APPINSv1.1.0) | Azure Application Insights Terraform module with enterprise-grade features |
| [Application Insights Workbook](./modules/azurerm_application_insights_workbook/) | ✅ Completed | [AIWBv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AIWBv1.0.0) | Azure Application Insights Workbook Terraform module |
| [Bastion Host](./modules/azurerm_bastion_host/) | ✅ Completed | [BASTIONv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/BASTIONv1.0.0) | Azure Bastion Host Terraform module with diagnostic settings support |
| [Cognitive Account](./modules/azurerm_cognitive_account/) | ✅ Completed | [COGv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/COGv1.0.0) | Azure Cognitive Services account module for OpenAI, Language, and Speech |
| [Event Hub](./modules/azurerm_eventhub/) | ✅ Completed | [EHv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/EHv1.0.0) | Azure Event Hub Terraform module with enterprise-grade features |
| [Event Hub Namespace](./modules/azurerm_eventhub_namespace/) | ✅ Completed | [EHNSv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/EHNSv1.0.0) | Azure Event Hub Namespace Terraform module with enterprise-grade features |
| [Key Vault](./modules/azurerm_key_vault/) | ✅ Completed | [KVv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/KVv1.0.0) | Azure Key Vault Terraform module with full data-plane coverage |
| [Kubernetes Cluster](./modules/azurerm_kubernetes_cluster/) | ✅ Completed | [AKSv2.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AKSv2.1.0) | Azure Kubernetes Service (AKS) Terraform module for managing clusters with node pools, addons, and enterprise-grade security features |
| [Kubernetes Secrets](./modules/azurerm_kubernetes_secrets/) | ✅ Completed | [AKSSv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AKSSv1.0.0) | Azure Kubernetes Secrets Terraform module with enterprise-grade features |
| [Linux Function App](./modules/azurerm_linux_function_app/) | ✅ Completed | [LFUNCv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/LFUNCv1.0.0) | Azure Linux Function App Terraform module with enterprise-grade features |
| [Linux Virtual Machine](./modules/azurerm_linux_virtual_machine/) | ✅ Completed | [LINUXVMv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/LINUXVMv1.0.0) | Azure Linux Virtual Machine Terraform module with enterprise-grade features |
| [Log Analytics Workspace](./modules/azurerm_log_analytics_workspace/) | ✅ Completed | [LAWv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/LAWv1.1.0) | Azure Log Analytics Workspace Terraform module with workspace and sub-resource management |
| [Monitor Data Collection Endpoint](./modules/azurerm_monitor_data_collection_endpoint/) | ✅ Completed | [DCEv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/DCEv1.0.0) | Azure Monitor Data Collection Endpoint Terraform module with enterprise-grade features |
| [Monitor Data Collection Rule](./modules/azurerm_monitor_data_collection_rule/) | ✅ Completed | [DCRv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/DCRv1.0.0) | Azure Monitor Data Collection Rule Terraform module with enterprise-grade features |
| [Monitor Private Link Scope](./modules/azurerm_monitor_private_link_scope/) | ✅ Completed | [AMPLSv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/AMPLSv1.0.0) | Azure Monitor Private Link Scope Terraform module with enterprise-grade features |
| [Network Security Group](./modules/azurerm_network_security_group/) | ✅ Completed | [NSGv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/NSGv1.1.0) | Manages Azure Network Security Groups with comprehensive security rules configuration |
| [PostgreSQL Flexible Server](./modules/azurerm_postgresql_flexible_server/) | ✅ Completed | [PGFSv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PGFSv1.1.0) | Azure PostgreSQL Flexible Server Terraform module with enterprise-grade features |
| [PostgreSQL Flexible Server Database](./modules/azurerm_postgresql_flexible_server_database/) | ✅ Completed | [PGFSDBv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PGFSDBv1.0.0) | Azure PostgreSQL Flexible Server Database Terraform module with enterprise-grade features |
| [Private DNS Zone](./modules/azurerm_private_dns_zone/) | ✅ Completed | [PDNSZv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PDNSZv1.0.0) | Manages Azure Private DNS Zones |
| [Private DNS Zone Virtual Network Link](./modules/azurerm_private_dns_zone_virtual_network_link/) | ✅ Completed | [PDNSZLNKv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PDNSZLNKv1.0.0) | Manages Azure Private DNS Zone Virtual Network Links |
| [Private Endpoint](./modules/azurerm_private_endpoint/) | ✅ Completed | [PEv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/PEv1.0.0) | Azure Private Endpoint Terraform module |
| [Redis Cache](./modules/azurerm_redis_cache/) | ✅ Completed | [REDISv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/REDISv1.0.0) | Azure Redis Cache Terraform module with enterprise-grade features |
| [Role Assignment](./modules/azurerm_role_assignment/) | ✅ Completed | [RAv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RAv1.0.0) | Manages Azure RBAC role assignments |
| [Role Definition](./modules/azurerm_role_definition/) | ✅ Completed | [RDv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RDv1.0.0) | Manages Azure RBAC role definitions |
| [Route Table](./modules/azurerm_route_table/) | ✅ Completed | [RTv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/RTv1.1.0) | Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations |
| [Storage Account](./modules/azurerm_storage_account/) | ✅ Completed | [SAv2.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SAv2.1.0) | Azure Storage Account Terraform module with enterprise-grade security features |
| [Subnet](./modules/azurerm_subnet/) | ✅ Completed | [SNv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SNv1.1.0) | Azure Subnet Terraform module for managing subnets with service endpoints, delegations, network policies, and enterprise-grade security features |
| [User Assigned Identity](./modules/azurerm_user_assigned_identity/) | ✅ Completed | [UAIv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/UAIv1.0.0) | Manages Azure User Assigned Identities and federated identity credentials |
| [Virtual Network](./modules/azurerm_virtual_network/) | ✅ Completed | [VNv1.2.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/VNv1.2.0) | Azure Virtual Network Terraform module with advanced networking features |
| [Windows Function App](./modules/azurerm_windows_function_app/) | ✅ Completed | [WFUNCv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/WFUNCv1.0.0) | Azure Windows Function App Terraform module with enterprise-grade features |
| [Windows Virtual Machine](./modules/azurerm_windows_virtual_machine/) | ✅ Completed | [WINDOWSVMv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/WINDOWSVMv1.0.0) | Azure Windows Virtual Machine Terraform module with enterprise-grade features |
<!-- AZURERM_MODULES_TABLE_END -->

### Azure DevOps Modules

Note: `azuredevops_identity` has been split into `azuredevops_group`, `azuredevops_user_entitlement`, `azuredevops_service_principal_entitlement`, and `azuredevops_securityrole_assignment`.

<!-- AZUREDEVOPS_MODULES_TABLE_START -->
| Module | Status | Version | Description |
| --- | --- | --- | --- |
| [Azure DevOps Agent Pools](./modules/azuredevops_agent_pools/) | ✅ Completed | [ADOAPv2.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOAPv2.0.0) | Azure DevOps agent pools module for managing a single agent pool |
| [Azure DevOps Artifacts Feed](./modules/azuredevops_artifacts_feed/) | ✅ Completed | [ADOAFv2.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOAFv2.0.0) | Azure DevOps artifacts feed module for managing a feed, retention policies, and permissions |
| [Azure DevOps Elastic Pool](./modules/azuredevops_elastic_pool/) | ✅ Completed | [ADOEPv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEPv1.0.0) | Azure DevOps elastic pool module for managing a single elastic pool |
| [Azure DevOps Environments](./modules/azuredevops_environments/) | ✅ Completed | [ADOEv2.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEv2.0.0) | Azure DevOps environments module for a single environment with optional resources and checks |
| [Azure DevOps Extension](./modules/azuredevops_extension/) | ✅ Completed | [ADOEXv2.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOEXv2.0.0) | Azure DevOps extension module for managing a single Marketplace extension |
| [Azure DevOps Group](./modules/azuredevops_group/) | ✅ Completed | [ADOGv2.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOGv2.0.0) | Azure DevOps group module for managing a single group with optional strict-child memberships |
| [Azure DevOps Group Entitlement](./modules/azuredevops_group_entitlement/) | ✅ Completed | [ADOGEv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOGEv1.0.0) | Azure DevOps module for managing a single group entitlement |
| [Azure DevOps Pipelines](./modules/azuredevops_pipelines/) | 🧪 Development | vUnreleased | Azure DevOps pipelines module for managing a build definition with strict-child permissions and resource authorizations |
| [Azure DevOps Project](./modules/azuredevops_project/) | ✅ Completed | [ADOPv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOPv1.0.0) | Azure DevOps project module for managing project settings, tags, and dashboards |
| [Azure DevOps Project Permissions](./modules/azuredevops_project_permissions/) | ✅ Completed | [ADOPPv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOPPv1.0.0) | Azure DevOps project permissions module for assigning group permissions |
| [Azure DevOps Repository](./modules/azuredevops_repository/) | ✅ Completed | [ADORv1.0.3](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADORv1.0.3) | Azure DevOps repository module for managing a Git repository, branches, permissions, and policies |
| [Azure DevOps Security Role Assignment](./modules/azuredevops_securityrole_assignment/) | ✅ Completed | [ADOSRAv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOSRAv1.0.0) | Azure DevOps module for managing security role assignments |
| [Azure DevOps Service Endpoints](./modules/azuredevops_serviceendpoint/) | 🧪 Development | vUnreleased | Azure DevOps service endpoints module for managing a single generic service endpoint and strict-child permissions |
| [Azure DevOps Service Hooks](./modules/azuredevops_servicehooks/) | 🧪 Development | vUnreleased | Azure DevOps service hooks module for managing single webhook subscription (use module-level for_each for multiples) |
| [Azure DevOps Service Principal Entitlement](./modules/azuredevops_service_principal_entitlement/) | ✅ Completed | [ADOSPEv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOSPEv1.0.0) | Azure DevOps module for managing a service principal entitlement |
| [Azure DevOps Team](./modules/azuredevops_team/) | 🧪 Development | vUnreleased | Azure DevOps team module for managing a team, members, and administrators |
| [Azure DevOps User Entitlement](./modules/azuredevops_user_entitlement/) | ✅ Completed | [ADOUv1.0.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/ADOUv1.0.0) | Azure DevOps module for managing user entitlements |
| [Azure DevOps Variable Groups](./modules/azuredevops_variable_groups/) | 🧪 Development | vUnreleased | Azure DevOps variable groups module for managing a single variable group, strict-child permissions, and optional Key Vault integration |
| [Azure DevOps Wiki](./modules/azuredevops_wiki/) | 🧪 Development | vUnreleased | Azure DevOps wiki module for managing a single wiki and strict-child pages |
| [Azure DevOps Work Items](./modules/azuredevops_work_items/) | 🧪 Development | vUnreleased | Azure DevOps work items module for managing a single work item resource |
<!-- AZUREDEVOPS_MODULES_TABLE_END -->

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
