# Modules Index

This directory contains all Terraform modules published from this repository. Each module has its own README, examples, and changelog. Modules are atomic and manage a single primary resource; cross-resource glue (private endpoints, RBAC, budgets) lives in dedicated modules or higher-level compositions.

- Naming convention: `azurerm_<resource>` for AzureRM and `azuredevops_<resource>` for Azure DevOps.
- Release tag prefixes come from each module's `module.json` (for example: `SAv1.2.2`).

## AzureRM Modules

| Module | Tag Prefix | Description |
| --- | --- | --- |
| [AI Services](./azurerm_ai_services/) (`azurerm_ai_services`) | `AISv` | Azure AI Services module with identity, CMK, network ACLs, and diagnostics support |
| [Cognitive Account](./azurerm_cognitive_account/) (`azurerm_cognitive_account`) | `COGv` | Azure Cognitive Services account module for OpenAI, Language, and Speech workloads |
| [Event Hub](./azurerm_eventhub/) (`azurerm_eventhub`) | `EHv` | Azure Event Hub module with capture, consumer groups, and authorization rules |
| [Event Hub Namespace](./azurerm_eventhub_namespace/) (`azurerm_eventhub_namespace`) | `EHNSv` | Azure Event Hub Namespace module with auth rules, network rules, CMK, and diagnostics |
| [Application Insights](./azurerm_application_insights/) (`azurerm_application_insights`) | `APPINSv` | Azure Application Insights module with diagnostics, web tests, and smart detection rules |
| [Application Insights Workbook](./azurerm_application_insights_workbook/) (`azurerm_application_insights_workbook`) | `AIWBv` | Azure Application Insights Workbook module |
| [Bastion Host](./azurerm_bastion_host/) (`azurerm_bastion_host`) | `BASTIONv` | Azure Bastion Host module with diagnostic settings support |
| [Key Vault](./azurerm_key_vault/) (`azurerm_key_vault`) | `KVv` | Azure Key Vault module with data-plane resources and diagnostic settings |
| [Log Analytics Workspace](./azurerm_log_analytics_workspace/) (`azurerm_log_analytics_workspace`) | `LAWv` | Azure Log Analytics Workspace module with workspace-linked sub-resources and diagnostics |
| [Linux Function App](./azurerm_linux_function_app/) (`azurerm_linux_function_app`) | `LFUNCv` | Azure Linux Function App module with slots and diagnostic settings |
| [Windows Function App](./azurerm_windows_function_app/) (`azurerm_windows_function_app`) | `WFUNCv` | Azure Windows Function App module with slots and diagnostic settings |
| [Linux Virtual Machine](./azurerm_linux_virtual_machine/) (`azurerm_linux_virtual_machine`) | `LINUXVMv` | Azure Linux Virtual Machine module with extensions and diagnostic settings |
| [Kubernetes Cluster](./azurerm_kubernetes_cluster/) (`azurerm_kubernetes_cluster`) | `AKSv` | Azure Kubernetes Service (AKS) Terraform module for managing clusters with node pools, addons, and enterprise-grade security features |
| [Kubernetes Secrets](./azurerm_kubernetes_secrets/) (`azurerm_kubernetes_secrets`) | `AKSSv` | Azure Kubernetes Secrets Terraform module with enterprise-grade features |
| [Windows Virtual Machine](./azurerm_windows_virtual_machine/) (`azurerm_windows_virtual_machine`) | `WINDOWSVMv` | Azure Windows Virtual Machine module with managed data disks, extensions, and diagnostic settings |
| [Network Security Group](./azurerm_network_security_group/) (`azurerm_network_security_group`) | `NSGv` | Manages Azure Network Security Groups with comprehensive security rules configuration |
| [Monitor Data Collection Endpoint](./azurerm_monitor_data_collection_endpoint/) (`azurerm_monitor_data_collection_endpoint`) | `DCEv` | Azure Monitor Data Collection Endpoint module for configuring ingestion endpoints |
| [Monitor Data Collection Rule](./azurerm_monitor_data_collection_rule/) (`azurerm_monitor_data_collection_rule`) | `DCRv` | Azure Monitor Data Collection Rule module for defining data sources and flows |
| [PostgreSQL Flexible Server](./azurerm_postgresql_flexible_server/) (`azurerm_postgresql_flexible_server`) | `PGFSv` | Azure PostgreSQL Flexible Server Terraform module with enterprise-grade features |
| [PostgreSQL Flexible Server Database](./azurerm_postgresql_flexible_server_database/) (`azurerm_postgresql_flexible_server_database`) | `PGFSDBv` | Manages a PostgreSQL Flexible Server database on an existing server |
| [Redis Cache](./azurerm_redis_cache/) (`azurerm_redis_cache`) | `REDISv` | Azure Redis Cache module with patch schedules, firewall rules, linked servers, and diagnostic settings |
| [Route Table](./azurerm_route_table/) (`azurerm_route_table`) | `RTv` | Manages Azure Route Tables with custom routes configuration, BGP route propagation settings, and subnet associations |
| [Role Assignment](./azurerm_role_assignment/) (`azurerm_role_assignment`) | `RAv` | Manages Azure RBAC role assignments |
| [Role Definition](./azurerm_role_definition/) (`azurerm_role_definition`) | `RDv` | Manages custom Azure RBAC role definitions |
| [Storage Account](./azurerm_storage_account/) (`azurerm_storage_account`) | `SAv` | Azure Storage Account Terraform module with enterprise-grade security features |
| [User Assigned Identity](./azurerm_user_assigned_identity/) (`azurerm_user_assigned_identity`) | `UAIv` | Azure User Assigned Identity module with federated identity credential support |
| [Monitor Private Link Scope](./azurerm_monitor_private_link_scope/) (`azurerm_monitor_private_link_scope`) | `AMPLSv` | Azure Monitor Private Link Scope module with scoped services and diagnostic settings |
| [Private DNS Zone](./azurerm_private_dns_zone/) (`azurerm_private_dns_zone`) | `PDNSZv` | Manages Azure Private DNS Zones |
| [Private DNS Zone Virtual Network Link](./azurerm_private_dns_zone_virtual_network_link/) (`azurerm_private_dns_zone_virtual_network_link`) | `PDNSZLNKv` | Manages Azure Private DNS Zone Virtual Network Links |
| [Private Endpoint](./azurerm_private_endpoint/) (`azurerm_private_endpoint`) | `PEv` | Manages Azure Private Endpoints with optional DNS zone group attachment |
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
