# Modules Index

This directory contains all Terraform modules published from this repository. Each module has its own README, examples, and changelog. Modules are atomic and manage a single primary resource; cross-resource glue (private endpoints, RBAC, budgets) lives in dedicated modules or higher-level compositions.

- Naming convention: `azurerm_<resource>` for AzureRM and `azuredevops_<resource>` for Azure DevOps.
- Release tag prefixes come from each module's `module.json` (for example: `SAv1.2.2`).

## AzureRM Modules

| Module | Tag Prefix | Description |
| --- | --- | --- |
| [Kubernetes Cluster](./azurerm_kubernetes_cluster/) (`azurerm_kubernetes_cluster`) | `AKSv` | Azure Kubernetes Service (AKS) Terraform module for managing clusters with node pools, addons, and enterprise-grade security features |
| [Kubernetes Secrets](./azurerm_kubernetes_secrets/) (`azurerm_kubernetes_secrets`) | `AKSSv` | Azure Kubernetes Secrets Terraform module with enterprise-grade features |
| [Network Security Group](./azurerm_network_security_group/) (`azurerm_network_security_group`) | `NSGv` | Manages Azure Network Security Groups with comprehensive security rules configuration |
| [PostgreSQL Flexible Server](./azurerm_postgresql_flexible_server/) (`azurerm_postgresql_flexible_server`) | `PGFSv` | Azure PostgreSQL Flexible Server Terraform module with enterprise-grade features |
| [Route Table](./azurerm_route_table/) (`azurerm_route_table`) | `RTv` | Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations |
| [Storage Account](./azurerm_storage_account/) (`azurerm_storage_account`) | `SAv` | Azure Storage Account Terraform module with enterprise-grade security features |
| [Subnet](./azurerm_subnet/) (`azurerm_subnet`) | `SNv` | Azure Subnet Terraform module for managing subnets with service endpoints, delegations, network policies, and enterprise-grade security features |
| [Virtual Network](./azurerm_virtual_network/) (`azurerm_virtual_network`) | `VNv` | Azure Virtual Network Terraform module with advanced networking features |

## Azure DevOps Modules

Note: `azuredevops_identity` has been split into `azuredevops_group`, `azuredevops_user_entitlement`, `azuredevops_service_principal_entitlement`, and `azuredevops_securityrole_assignment`.

| Module | Tag Prefix | Description |
| --- | --- | --- |
| [Azure DevOps Agent Pools](./azuredevops_agent_pools/) (`azuredevops_agent_pools`) | `ADOAPv` | Azure DevOps agent pools module for managing pools and elastic pools |
| [Azure DevOps Artifacts Feed](./azuredevops_artifacts_feed/) (`azuredevops_artifacts_feed`) | `ADOAFv` | Azure DevOps artifacts feed module for managing a feed, retention policies, and permissions |
| [Azure DevOps Environments](./azuredevops_environments/) (`azuredevops_environments`) | `ADOEv` | Azure DevOps environments module for a single environment with optional resources and checks |
| [Azure DevOps Extension](./azuredevops_extension/) (`azuredevops_extension`) | `ADOEXv` | Azure DevOps extension module for managing a single Marketplace extension |
| [Azure DevOps Group](./azuredevops_group/) (`azuredevops_group`) | `ADOGv` | Azure DevOps group module for managing groups, memberships, and group entitlements |
| [Azure DevOps Security Role Assignment](./azuredevops_securityrole_assignment/) (`azuredevops_securityrole_assignment`) | `ADOSRAv` | Azure DevOps module for managing security role assignments |
| [Azure DevOps Service Principal Entitlement](./azuredevops_service_principal_entitlement/) (`azuredevops_service_principal_entitlement`) | `ADOSPEv` | Azure DevOps module for managing a service principal entitlement |
| [Azure DevOps User Entitlement](./azuredevops_user_entitlement/) (`azuredevops_user_entitlement`) | `ADOUv` | Azure DevOps module for managing user entitlements |
| [Azure DevOps Pipelines](./azuredevops_pipelines/) (`azuredevops_pipelines`) | `ADOPIv` | Azure DevOps pipelines module for managing a build definition with folders, permissions, and authorizations |
| [Azure DevOps Project](./azuredevops_project/) (`azuredevops_project`) | `ADOPv` | Azure DevOps project module for managing project settings, tags, and dashboards |
| [Azure DevOps Project Permissions](./azuredevops_project_permissions/) (`azuredevops_project_permissions`) | `ADOPPv` | Azure DevOps project permissions module for assigning group permissions |
| [Azure DevOps Repository](./azuredevops_repository/) (`azuredevops_repository`) | `ADORv` | Azure DevOps repository module for managing a Git repository, branches, permissions, and policies |
| [Azure DevOps Service Endpoints](./azuredevops_serviceendpoint/) (`azuredevops_serviceendpoint`) | `ADOSEv` | Azure DevOps service endpoints module for managing a single service connection and permissions |
| [Azure DevOps Service Hooks](./azuredevops_servicehooks/) (`azuredevops_servicehooks`) | `ADOSHv` | Azure DevOps service hooks module for managing single webhook/storage queue subscriptions and permissions (use module-level for_each for multiples) |
| [Azure DevOps Team](./azuredevops_team/) (`azuredevops_team`) | `ADOTv` | Azure DevOps team module for managing a team, members, and administrators |
| [Azure DevOps Variable Groups](./azuredevops_variable_groups/) (`azuredevops_variable_groups`) | `ADOVGv` | Azure DevOps variable groups module for managing variables, permissions, and optional Key Vault integration |
| [Azure DevOps Wiki](./azuredevops_wiki/) (`azuredevops_wiki`) | `ADOWIv` | Azure DevOps wiki module for managing wikis and pages |
| [Azure DevOps Work Items](./azuredevops_work_items/) (`azuredevops_work_items`) | `ADOWKv` | Azure DevOps work items module for managing work items, processes, queries, and permissions |
