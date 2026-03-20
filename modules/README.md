# Modules Index

This directory contains all Terraform modules published from this repository. Each module has its own README, examples, and changelog. Modules are atomic and manage a single primary resource; cross-resource glue (private endpoints, RBAC, budgets) lives in dedicated modules or higher-level compositions.

- Naming convention: `azurerm_<resource>` for AzureRM, `kubernetes_<resource>` for in-cluster Kubernetes, and `azuredevops_<resource>` for Azure DevOps.
- Release tag prefixes come from each module's `module.json` (for example: `SAv1.2.2`).

## AzureRM Modules

<!-- MODULES_INDEX_AZURERM_START -->
| Module | Tag Prefix | Description |
| --- | --- | --- |
| [AI Services](./azurerm_ai_services/) (`azurerm_ai_services`) | `AISv` | Azure AI Services Terraform module with identity, CMK, network ACLs, and diagnostics support |
| [Application Insights](./azurerm_application_insights/) (`azurerm_application_insights`) | `APPINSv` | Azure Application Insights Terraform module with enterprise-grade features |
| [Application Insights Workbook](./azurerm_application_insights_workbook/) (`azurerm_application_insights_workbook`) | `AIWBv` | Azure Application Insights Workbook Terraform module |
| [Bastion Host](./azurerm_bastion_host/) (`azurerm_bastion_host`) | `BASTIONv` | Azure Bastion Host Terraform module with diagnostic settings support |
| [Cognitive Account](./azurerm_cognitive_account/) (`azurerm_cognitive_account`) | `COGv` | Azure Cognitive Services account module for OpenAI, Language, and Speech |
| [Event Hub](./azurerm_eventhub/) (`azurerm_eventhub`) | `EHv` | Azure Event Hub Terraform module with enterprise-grade features |
| [Event Hub Namespace](./azurerm_eventhub_namespace/) (`azurerm_eventhub_namespace`) | `EHNSv` | Azure Event Hub Namespace Terraform module with enterprise-grade features |
| [Key Vault](./azurerm_key_vault/) (`azurerm_key_vault`) | `KVv` | Azure Key Vault Terraform module with full data-plane coverage |
| [Kubernetes Cluster](./azurerm_kubernetes_cluster/) (`azurerm_kubernetes_cluster`) | `AKSv` | Azure Kubernetes Service (AKS) Terraform module for managing clusters with node pools, addons, and enterprise-grade security features |
| [Kubernetes Secrets](./azurerm_kubernetes_secrets/) (`azurerm_kubernetes_secrets`) | `AKSSv` | Azure Kubernetes Secrets Terraform module with enterprise-grade features |
| [Linux Function App](./azurerm_linux_function_app/) (`azurerm_linux_function_app`) | `LFUNCv` | Azure Linux Function App Terraform module with enterprise-grade features |
| [Linux Virtual Machine](./azurerm_linux_virtual_machine/) (`azurerm_linux_virtual_machine`) | `LINUXVMv` | Azure Linux Virtual Machine Terraform module with enterprise-grade features |
| [Log Analytics Workspace](./azurerm_log_analytics_workspace/) (`azurerm_log_analytics_workspace`) | `LAWv` | Azure Log Analytics Workspace Terraform module with workspace and sub-resource management |
| [Managed Redis](./azurerm_managed_redis/) (`azurerm_managed_redis`) | `AMRv` | Azure Managed Redis Terraform module with enterprise-grade features |
| [Monitor Data Collection Endpoint](./azurerm_monitor_data_collection_endpoint/) (`azurerm_monitor_data_collection_endpoint`) | `DCEv` | Azure Monitor Data Collection Endpoint Terraform module with enterprise-grade features |
| [Monitor Data Collection Rule](./azurerm_monitor_data_collection_rule/) (`azurerm_monitor_data_collection_rule`) | `DCRv` | Azure Monitor Data Collection Rule Terraform module with enterprise-grade features |
| [Monitor Private Link Scope](./azurerm_monitor_private_link_scope/) (`azurerm_monitor_private_link_scope`) | `AMPLSv` | Azure Monitor Private Link Scope Terraform module with enterprise-grade features |
| [Network Security Group](./azurerm_network_security_group/) (`azurerm_network_security_group`) | `NSGv` | Manages Azure Network Security Groups with comprehensive security rules configuration |
| [PostgreSQL Flexible Server](./azurerm_postgresql_flexible_server/) (`azurerm_postgresql_flexible_server`) | `PGFSv` | Azure PostgreSQL Flexible Server Terraform module with enterprise-grade features |
| [PostgreSQL Flexible Server Database](./azurerm_postgresql_flexible_server_database/) (`azurerm_postgresql_flexible_server_database`) | `PGFSDBv` | Azure PostgreSQL Flexible Server Database Terraform module with enterprise-grade features |
| [Private DNS Zone](./azurerm_private_dns_zone/) (`azurerm_private_dns_zone`) | `PDNSZv` | Manages Azure Private DNS Zones |
| [Private DNS Zone Virtual Network Link](./azurerm_private_dns_zone_virtual_network_link/) (`azurerm_private_dns_zone_virtual_network_link`) | `PDNSZLNKv` | Manages Azure Private DNS Zone Virtual Network Links |
| [Private Endpoint](./azurerm_private_endpoint/) (`azurerm_private_endpoint`) | `PEv` | Azure Private Endpoint Terraform module |
| [Redis Cache](./azurerm_redis_cache/) (`azurerm_redis_cache`) | `REDISv` | Azure Redis Cache Terraform module with enterprise-grade features |
| [Role Assignment](./azurerm_role_assignment/) (`azurerm_role_assignment`) | `RAv` | Manages Azure RBAC role assignments |
| [Role Definition](./azurerm_role_definition/) (`azurerm_role_definition`) | `RDv` | Manages Azure RBAC role definitions |
| [Route Table](./azurerm_route_table/) (`azurerm_route_table`) | `RTv` | Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations |
| [Storage Account](./azurerm_storage_account/) (`azurerm_storage_account`) | `SAv` | Azure Storage Account Terraform module with enterprise-grade security features |
| [Subnet](./azurerm_subnet/) (`azurerm_subnet`) | `SNv` | Azure Subnet Terraform module for managing subnets with service endpoints, delegations, network policies, and enterprise-grade security features |
| [User Assigned Identity](./azurerm_user_assigned_identity/) (`azurerm_user_assigned_identity`) | `UAIv` | Manages Azure User Assigned Identities and federated identity credentials |
| [Virtual Network](./azurerm_virtual_network/) (`azurerm_virtual_network`) | `VNv` | Azure Virtual Network Terraform module with advanced networking features |
| [Windows Function App](./azurerm_windows_function_app/) (`azurerm_windows_function_app`) | `WFUNCv` | Azure Windows Function App Terraform module with enterprise-grade features |
| [Windows Virtual Machine](./azurerm_windows_virtual_machine/) (`azurerm_windows_virtual_machine`) | `WINDOWSVMv` | Azure Windows Virtual Machine Terraform module with enterprise-grade features |
<!-- MODULES_INDEX_AZURERM_END -->

## Kubernetes Modules

<!-- MODULES_INDEX_KUBERNETES_START -->
| Module | Tag Prefix | Description |
| --- | --- | --- |
| [Kubernetes Cluster Role](./kubernetes_cluster_role/) (`kubernetes_cluster_role`) | `KCRv` | Kubernetes ClusterRole Terraform module for managing a single cluster-scoped RBAC role |
| [Kubernetes Cluster Role Binding](./kubernetes_cluster_role_binding/) (`kubernetes_cluster_role_binding`) | `KCRBv` | Kubernetes ClusterRoleBinding Terraform module for binding a cluster role to subjects |
| [Kubernetes Namespace](./kubernetes_namespace/) (`kubernetes_namespace`) | `KNSv` | Kubernetes namespace Terraform module for managing a single namespace in an existing cluster |
| [Kubernetes Role](./kubernetes_role/) (`kubernetes_role`) | `KROLEv` | Kubernetes Role Terraform module for managing a single namespace-scoped RBAC role |
| [Kubernetes Role Binding](./kubernetes_role_binding/) (`kubernetes_role_binding`) | `KRBv` | Kubernetes RoleBinding Terraform module for binding a namespace-scoped role to subjects |
<!-- MODULES_INDEX_KUBERNETES_END -->

## Azure DevOps Modules

Note: `azuredevops_identity` has been split into `azuredevops_group`, `azuredevops_user_entitlement`, `azuredevops_service_principal_entitlement`, and `azuredevops_securityrole_assignment`.

<!-- MODULES_INDEX_AZUREDEVOPS_START -->
| Module | Tag Prefix | Description |
| --- | --- | --- |
| [Azure DevOps Agent Pools](./azuredevops_agent_pools/) (`azuredevops_agent_pools`) | `ADOAPv` | Azure DevOps agent pools module for managing a single agent pool |
| [Azure DevOps Artifacts Feed](./azuredevops_artifacts_feed/) (`azuredevops_artifacts_feed`) | `ADOAFv` | Azure DevOps artifacts feed module for managing a feed, retention policies, and permissions |
| [Azure DevOps Elastic Pool](./azuredevops_elastic_pool/) (`azuredevops_elastic_pool`) | `ADOEPv` | Azure DevOps elastic pool module for managing a single elastic pool |
| [Azure DevOps Environments](./azuredevops_environments/) (`azuredevops_environments`) | `ADOEv` | Azure DevOps environments module for a single environment with optional resources and checks |
| [Azure DevOps Extension](./azuredevops_extension/) (`azuredevops_extension`) | `ADOEXv` | Azure DevOps extension module for managing a single Marketplace extension |
| [Azure DevOps Group](./azuredevops_group/) (`azuredevops_group`) | `ADOGv` | Azure DevOps group module for managing a single group with optional strict-child memberships |
| [Azure DevOps Group Entitlement](./azuredevops_group_entitlement/) (`azuredevops_group_entitlement`) | `ADOGEv` | Azure DevOps module for managing a single group entitlement |
| [Azure DevOps Pipelines](./azuredevops_pipelines/) (`azuredevops_pipelines`) | `ADOPIv` | Azure DevOps pipelines module for managing a build definition with strict-child permissions and resource authorizations |
| [Azure DevOps Project](./azuredevops_project/) (`azuredevops_project`) | `ADOPv` | Azure DevOps project module for managing project settings, tags, and dashboards |
| [Azure DevOps Project Permissions](./azuredevops_project_permissions/) (`azuredevops_project_permissions`) | `ADOPPv` | Azure DevOps project permissions module for assigning group permissions |
| [Azure DevOps Repository](./azuredevops_repository/) (`azuredevops_repository`) | `ADORv` | Azure DevOps repository module for managing a Git repository, branches, permissions, and policies |
| [Azure DevOps Security Role Assignment](./azuredevops_securityrole_assignment/) (`azuredevops_securityrole_assignment`) | `ADOSRAv` | Azure DevOps module for managing security role assignments |
| [Azure DevOps Service Endpoints](./azuredevops_serviceendpoint/) (`azuredevops_serviceendpoint`) | `ADOSEv` | Azure DevOps service endpoints module for managing a single generic service endpoint and strict-child permissions |
| [Azure DevOps Service Hooks](./azuredevops_servicehooks/) (`azuredevops_servicehooks`) | `ADOSHv` | Azure DevOps service hooks module for managing single webhook subscription (use module-level for_each for multiples) |
| [Azure DevOps Service Principal Entitlement](./azuredevops_service_principal_entitlement/) (`azuredevops_service_principal_entitlement`) | `ADOSPEv` | Azure DevOps module for managing a service principal entitlement |
| [Azure DevOps Team](./azuredevops_team/) (`azuredevops_team`) | `ADOTv` | Azure DevOps team module for managing a team, members, and administrators |
| [Azure DevOps User Entitlement](./azuredevops_user_entitlement/) (`azuredevops_user_entitlement`) | `ADOUv` | Azure DevOps module for managing user entitlements |
| [Azure DevOps Variable Groups](./azuredevops_variable_groups/) (`azuredevops_variable_groups`) | `ADOVGv` | Azure DevOps variable groups module for managing a single variable group, strict-child permissions, and optional Key Vault integration |
| [Azure DevOps Wiki](./azuredevops_wiki/) (`azuredevops_wiki`) | `ADOWIv` | Azure DevOps wiki module for managing a single wiki and strict-child pages |
| [Azure DevOps Work Items](./azuredevops_work_items/) (`azuredevops_work_items`) | `ADOWKv` | Azure DevOps work items module for managing a single work item resource |
<!-- MODULES_INDEX_AZUREDEVOPS_END -->
