# Secure Storage Account with Private Endpoints Example

This example demonstrates how to deploy a highly secure Azure Storage Account suitable for production environments handling sensitive data.

## Features

### Security Configuration
- ✅ **HTTPS-only traffic** - All communication encrypted in transit
- ✅ **TLS 1.2 minimum** - Modern encryption protocols only
- ✅ **Public blob access disabled** - No anonymous access to blobs
- ✅ **Infrastructure encryption** - Double encryption at rest (configurable)
- ✅ **Customer-managed keys** - Bring your own encryption keys with rotation
- ✅ **Network isolation** - Default deny with private endpoints
- ✅ **Private DNS zones** - Automatic name resolution for all storage services
- ✅ **Comprehensive logging** - All operations tracked in Log Analytics
- ✅ **Microsoft Defender** - Advanced threat protection for storage
- ✅ **Network Security Groups** - Traffic filtering at subnet level
- ✅ **Flow Logs** - Network traffic analysis and forensics
- ✅ **Azure Policy** - Automated compliance enforcement
- ✅ **Security Alerts** - Real-time threat detection

### Network Architecture
- **Virtual Network**: Isolated network with DDoS protection (optional)
- **Private Endpoints**: All storage services (blob, file, queue, table, dfs, web)
- **Private DNS Zones**: Complete DNS setup for all storage services
- **Service Endpoints**: Additional network-level security
- **Network ACLs**: Deny all public access by default
- **Network Security Groups**: Strict inbound/outbound rules
- **Flow Logs**: Traffic monitoring with analytics
- **Network Watcher**: Advanced network diagnostics

### Data Protection
- **Blob versioning**: Automatic version history
- **Soft delete**: 30-day recovery window
- **Change feed**: Audit trail of all changes
- **Diagnostic logging**: Comprehensive activity logs

### Compliance Features
- **Audit logging**: All operations logged to Log Analytics
- **Encryption at rest**: AES-256 with customer-managed keys
- **Key rotation**: Automatic reminders and rotation policy
- **Access controls**: Azure AD authentication required
- **Azure Policy**: 6 built-in policies + custom policies
- **Compliance reporting**: Automated compliance dashboards
- **Resource locks**: Prevent accidental deletion
- **Monitoring**: Real-time security alerts with anomaly detection

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.3.0
- AzureRM Provider 4.36.0 (correctly pinned to match the module version)
- Network connectivity for private endpoints
- Permissions to create:
  - Virtual Networks and Subnets
  - Private Endpoints and DNS Zones
  - Key Vault with encryption keys
  - Log Analytics workspace

**Note**: The module uses a pinned version of the AzureRM provider (4.36.0) to ensure consistent behavior across all deployments.

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Azure Virtual Network                            │
│                            10.0.0.0/16                                   │
│                                                                          │
│  ┌─────────────────────────────┐     ┌────────────────────────────┐    │
│  │   Private Endpoints Subnet   │     │    Application Subnet      │    │
│  │       10.0.1.0/24            │     │       10.0.2.0/24          │    │
│  │                              │     │                            │    │
│  │  Private Endpoints:          │     │  • Service Endpoints       │    │
│  │  • Blob PE  ─┐               │     │  • Apps/VMs                │    │
│  │  • File PE  ─┼─┐             │     │  • Allowed in Network ACL  │    │
│  │  • Queue PE ─┼─┼─┐           │     │                            │    │
│  │  • Table PE ─┼─┼─┼─┐         │     │                            │    │
│  └──────────────┼─┼─┼─┼─────────┘     └────────────────────────────┘    │
│                 │ │ │ │                                                  │
│  ┌──────────────▼─▼─▼─▼─────────────────────────────────────────────┐   │
│  │                    Private DNS Zones                              │   │
│  │  • privatelink.blob.core.windows.net                              │   │
│  │  • privatelink.file.core.windows.net                              │   │
│  │  • privatelink.queue.core.windows.net                             │   │
│  │  • privatelink.table.core.windows.net                             │   │
│  └───────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Private Connectivity Only
                                   │ (No Public Access)
                                   │
                       ┌───────────▼──────────────┐
                       │     Storage Account      │
                       │   stsecureexample01      │
                       │                          │
                       │ Security Features:       │
                       │ • CMK Encryption (KEK)   │
                       │ • Infrastructure Encrypt │
                       │ • Network ACL: Deny All  │
                       │ • Private Endpoints Only │
                       │ • TLS 1.2 Minimum       │
                       │ • Versioning Enabled     │
                       │ • Soft Delete (30 days) │
                       └──────────────────────────┘
                                   │
                                   │ Logs & Metrics
                                   │
                       ┌───────────▼──────────────┐
                       │   Log Analytics          │
                       │   Workspace              │
                       │                          │
                       │ • Storage Operations     │
                       │ • Security Events        │
                       │ • Performance Metrics    │
                       └──────────────────────────┘
```

## Security Considerations

1. **Key Management**
   - Keys are stored in Azure Key Vault with purge protection
   - Access to keys requires explicit permissions
   - Regular key rotation is recommended

2. **Network Security**
   - No public endpoints exposed
   - All traffic flows through private endpoints
   - DNS resolution handled by private DNS zones

3. **Access Control**
   - Shared key access enabled (required for Terraform management)
   - Consider disabling shared keys post-deployment for maximum security
   - Use Azure AD authentication and RBAC for application access

4. **Monitoring**
   - All operations logged to Log Analytics
   - Advanced threat protection alerts
   - Regular security reviews recommended

## Cost Optimization

While this configuration prioritizes security, consider:
- Private endpoints incur additional costs
- Advanced threat protection is a premium feature
- Customer-managed keys require Key Vault
- Comprehensive logging increases storage costs

## Customization

To adapt this example for your needs:

1. **Network Configuration**
   ```hcl
   # Add your IP ranges if needed (not recommended for production)
   network_rules = {
     ip_rules = ["YOUR_IP_RANGE"]
   }
   ```

2. **Retention Policies**
   ```hcl
   # Adjust retention based on compliance requirements
   delete_retention_policy = {
     days = 90  # Increase for longer retention
   }
   ```

3. **Diagnostic Settings**
   ```hcl
   # Add additional log categories as needed
   logs = [
     { category = "StorageRead" },
     { category = "StorageWrite" },
     { category = "StorageDelete" },
     { category = "Transaction" }  # Additional category
   ]
   ```

## Private Endpoint Setup Observations

### Key Implementation Details

1. **Network Policy Configuration**
   - The subnet for private endpoints has `private_endpoint_network_policies = "Disabled"`
   - This is required for private endpoints to function properly
   - Previously known as `enforce_private_link_endpoint_network_policies`

2. **DNS Integration**
   - Each storage service (blob, file, queue, table) requires its own private DNS zone
   - DNS zones follow the pattern: `privatelink.<service>.core.windows.net`
   - Virtual network links connect the DNS zones to the VNet for automatic resolution

3. **Service-Specific Endpoints**
   - Each storage service gets its own private endpoint
   - Subresource names map to storage services: blob, file, queue, table
   - All endpoints are created in a dedicated subnet for better management

4. **Network Isolation**
   - Network ACLs are set to "Deny" by default
   - Only the application subnet is allowed via service endpoints
   - Private endpoints bypass network ACLs by design

5. **Public Access Note**
   - The module currently doesn't support the `public_network_access_enabled` parameter
   - Network isolation is achieved through network ACLs with `default_action = "Deny"`
   - This provides similar security but allows Azure services to bypass if needed

### Best Practices Demonstrated

- **Dedicated Subnet**: Private endpoints are isolated in their own subnet
- **Complete DNS Setup**: All required DNS zones and links are pre-configured
- **Multiple Services**: Example shows how to configure all storage services
- **Dependencies**: Proper dependency management ensures resources are created in order
- **Security Layers**: Multiple security controls work together for defense in depth

## Security Enhancements in This Example

### 1. Advanced Threat Protection
- Microsoft Defender for Storage with malware scanning
- Sensitive data discovery
- Anomaly detection for data access patterns
- Real-time security alerts

### 2. Network Security Hardening
- Network Security Groups with restrictive rules
- NSG Flow Logs for traffic analysis
- Traffic Analytics integration
- Optional DDoS Protection Standard

### 3. Policy Compliance
- 6 Azure Policy assignments for security compliance
- Custom policy for TLS version enforcement
- Automated compliance reporting
- Policy violation alerts

### 4. Enhanced Monitoring
- Authentication failure alerts
- Data exfiltration detection
- Key Vault access monitoring
- Security-focused Log Analytics queries
- Application Insights for security dashboards

### 5. Key Management
- Automatic key rotation policy (90 days)
- Key expiration reminders
- Comprehensive Key Vault access policies
- Key Vault diagnostic logging

## Configuration Variables

Key variables to customize the deployment:

| Variable | Description | Default |
|----------|-------------|---------||
| `enable_advanced_threat_protection` | Enable Microsoft Defender | true |
| `enable_network_flow_logs` | Enable NSG flow logs | true |
| `enable_azure_policy_compliance` | Enable policy assignments | true |
| `enable_infrastructure_encryption` | Double encryption at rest | true |
| `key_rotation_reminder_days` | Days before key expiry alert | 30 |
| `log_retention_days` | Log retention period | 90 |
| `enable_ddos_protection` | DDoS Protection Standard | false |

## Security Operations

### Daily Tasks
1. Review security alerts in Azure Security Center
2. Check authentication failure logs
3. Monitor data access patterns

### Weekly Tasks
1. Review policy compliance status
2. Analyze flow logs for anomalies
3. Check Key Vault access logs

### Monthly Tasks
1. Review and update network rules
2. Audit user permissions
3. Test incident response procedures

### Quarterly Tasks
1. Rotate encryption keys
2. Review and update security policies
3. Conduct security assessment

## Cost Considerations

Premium security features that incur additional costs:
- Microsoft Defender for Storage (~$0.02/GB scanned)
- Private Endpoints (~$0.01/hour per endpoint)
- DDoS Protection Standard (~$2,944/month)
- Flow Logs and Traffic Analytics
- Extended log retention

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: 
- Due to Key Vault soft-delete and purge protection, the Key Vault and keys will remain in a soft-deleted state for 90 days
- Resource locks must be removed before deletion
- Some policy assignments may need manual cleanup
<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.41.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_secure_storage"></a> [secure\_storage](#module\_secure\_storage) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.security](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/application_insights) | resource |
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.current_user](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.storage](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.storage](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/key_vault_key) | resource |
| [azurerm_log_analytics_saved_search.data_exfiltration](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/log_analytics_saved_search) | resource |
| [azurerm_log_analytics_saved_search.policy_compliance](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/log_analytics_saved_search) | resource |
| [azurerm_log_analytics_saved_search.storage_failures](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/log_analytics_saved_search) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_management_lock.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/management_lock) | resource |
| [azurerm_monitor_action_group.security](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_diagnostic_setting.blob_service](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.anomalous_access](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.auth_failures](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_scheduled_query_rules_alert.kv_unknown_access](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/monitor_scheduled_query_rules_alert) | resource |
| [azurerm_network_ddos_protection_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/network_ddos_protection_plan) | resource |
| [azurerm_network_security_group.app](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/network_security_group) | resource |
| [azurerm_network_watcher.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/network_watcher) | resource |
| [azurerm_network_watcher_flow_log.app](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_network_watcher_flow_log.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_policy_definition.min_tls_version](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/policy_definition) | resource |
| [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.dfs](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.file](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.queue](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.table](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.web](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.dfs](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.file](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.queue](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.table](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.web](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.file](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.queue](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.table](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group) | resource |
| [azurerm_resource_group_policy_assignment.https_only](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.infrastructure_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.min_tls](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.network_restrictions](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.storage_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_security_center_storage_defender.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/security_center_storage_defender) | resource |
| [azurerm_storage_account.flow_logs](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/storage_account) | resource |
| [azurerm_subnet.app](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/subnet) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.app](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.storage](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.41.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip_ranges"></a> [allowed\_ip\_ranges](#input\_allowed\_ip\_ranges) | List of IP ranges allowed to access storage (use with caution in production) | `list(string)` | `[]` | no |
| <a name="input_enable_advanced_threat_protection"></a> [enable\_advanced\_threat\_protection](#input\_enable\_advanced\_threat\_protection) | Enable Microsoft Defender for Storage (Advanced Threat Protection) | `bool` | `true` | no |
| <a name="input_enable_azure_policy_compliance"></a> [enable\_azure\_policy\_compliance](#input\_enable\_azure\_policy\_compliance) | Enable Azure Policy assignments for compliance | `bool` | `true` | no |
| <a name="input_enable_ddos_protection"></a> [enable\_ddos\_protection](#input\_enable\_ddos\_protection) | Enable DDoS Protection Standard on the virtual network | `bool` | `false` | no |
| <a name="input_enable_infrastructure_encryption"></a> [enable\_infrastructure\_encryption](#input\_enable\_infrastructure\_encryption) | Enable infrastructure encryption for double encryption at rest | `bool` | `true` | no |
| <a name="input_enable_key_vault_monitoring"></a> [enable\_key\_vault\_monitoring](#input\_enable\_key\_vault\_monitoring) | Enable detailed monitoring for Key Vault operations | `bool` | `true` | no |
| <a name="input_enable_network_flow_logs"></a> [enable\_network\_flow\_logs](#input\_enable\_network\_flow\_logs) | Enable NSG flow logs for network traffic analysis | `bool` | `true` | no |
| <a name="input_enable_network_watcher"></a> [enable\_network\_watcher](#input\_enable\_network\_watcher) | Enable Network Watcher for network diagnostics | `bool` | `true` | no |
| <a name="input_enable_private_endpoint_policies"></a> [enable\_private\_endpoint\_policies](#input\_enable\_private\_endpoint\_policies) | Enable network policies on private endpoint subnet | `bool` | `false` | no |
| <a name="input_key_rotation_reminder_days"></a> [key\_rotation\_reminder\_days](#input\_key\_rotation\_reminder\_days) | Days before key expiration to send reminder | `number` | `30` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resource deployment | `string` | `"West Europe"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain logs in Log Analytics | `number` | `90` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for all resource names | `string` | `"secure"` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | Replication type for the storage account | `string` | `"ZRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | Performance tier for the storage account | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags to apply to all resources | `map(string)` | <pre>{<br/>  "DataClassification": "Confidential",<br/>  "Environment": "Production",<br/>  "ManagedBy": "Terraform",<br/>  "SecurityLevel": "Maximum"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compliance_status"></a> [compliance\_status](#output\_compliance\_status) | Policy compliance configuration |
| <a name="output_deployment_instructions"></a> [deployment\_instructions](#output\_deployment\_instructions) | Post-deployment security recommendations |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the storage account's managed identity |
| <a name="output_key_vault_configuration"></a> [key\_vault\_configuration](#output\_key\_vault\_configuration) | Key Vault configuration for encryption |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault used for encryption |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace for diagnostics |
| <a name="output_monitoring_configuration"></a> [monitoring\_configuration](#output\_monitoring\_configuration) | Monitoring and alerting configuration |
| <a name="output_network_security"></a> [network\_security](#output\_network\_security) | Network security configuration details |
| <a name="output_private_dns_zones"></a> [private\_dns\_zones](#output\_private\_dns\_zones) | The private DNS zones created for storage services |
| <a name="output_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#output\_private\_endpoint\_subnet\_id) | The ID of the subnet used for private endpoints |
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | Details of the private endpoints |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Summary of security settings applied |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the virtual network |
<!-- END_TF_DOCS -->
