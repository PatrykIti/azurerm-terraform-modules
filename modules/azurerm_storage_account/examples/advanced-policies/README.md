# Advanced Policies Example

This example demonstrates the implementation of advanced storage account policies including SAS policies, immutability policies, routing preferences, custom domains, and SMB configurations.

## Features Demonstrated

### 1. SAS Policy
- **Purpose**: Automatically expire Shared Access Signatures (SAS) tokens after a specified period
- **Configuration**: 
  - Expiration period: 30 days (`P30D` in ISO 8601 format)
  - Expiration action: Log (records when tokens expire)
- **Benefits**: 
  - Enhances security by limiting token lifetime
  - Provides audit trail of expired tokens
  - Prevents indefinite access through forgotten SAS tokens

### 2. Immutability Policy (WORM - Write Once Read Many)
- **Purpose**: Enforce data immutability for compliance requirements
- **Configuration**:
  - State: `Unlocked` (can be changed to `Locked` for permanent immutability)
  - Period: 7 days (files cannot be modified or deleted during this period)
  - Allow protected append writes: `true` (allows appending to immutable blobs)
- **Use Cases**:
  - Regulatory compliance (SEC 17a-4, CFTC, FINRA)
  - Legal hold scenarios
  - Audit log protection

### 3. Routing Preferences
- **Purpose**: Control how data is routed between Microsoft data centers and clients
- **Configuration**:
  - Choice: `InternetRouting` (routes via public internet for cost optimization)
  - Alternative: `MicrosoftRouting` (routes via Microsoft global network for better performance)
  - Publish internet endpoints: `true`
  - Publish Microsoft endpoints: `false`
- **Trade-offs**:
  - Internet routing: Lower cost, potentially higher latency
  - Microsoft routing: Higher cost, lower latency, better reliability

### 4. Custom Domain
- **Purpose**: Use your own domain name for storage account access
- **Configuration**:
  - Domain: `storage.example.com`
  - Use subdomain: `false` (direct CNAME validation)

**IMPORTANT - Manual Prerequisites**:
1. **Before applying this configuration**, you MUST create a CNAME record in your DNS:
   ```
   CNAME: storage.example.com -> stadvancedpoliciesex.blob.core.windows.net
   ```
2. DNS propagation can take up to 48 hours
3. For subdomain validation (indirect), set `use_subdomain = true` and create:
   ```
   CNAME: asverify.storage.example.com -> asverify.stadvancedpoliciesex.blob.core.windows.net
   ```

### 5. Share Properties with SMB Settings
- **Purpose**: Configure file share access protocols and security
- **Configuration**:
  - **CORS Rules**: Allow cross-origin requests from `https://example.com`
  - **Retention Policy**: Keep file share snapshots for 30 days
  - **SMB Settings**:
    - Versions: SMB 3.0 and 3.1.1
    - Authentication: NTLMv2 and Kerberos
    - Encryption: AES-256 for Kerberos tickets
    - Channel encryption: AES-128-GCM and AES-256-GCM
    - Multichannel: Enabled for improved performance

## Additional Features

- **Data Lake Gen2**: Enabled for hierarchical namespace support
- **SFTP**: Enabled for secure file transfer protocol access
- **Local Users**: Enabled for SFTP authentication
- **Blob Versioning**: Automatic versioning of all blob changes
- **Soft Delete**: 30-day retention for deleted blobs and containers
- **Point-in-time Restore**: Restore blobs to a previous state (29 days)
- **Lifecycle Management**: Automatic tiering to cool/archive storage

## Deployment

1. **Prerequisites**:
   - Azure subscription
   - Terraform >= 1.0
   - Azure CLI for authentication
   - DNS access to create CNAME records (for custom domain)

2. **Deploy**:
   ```bash
   # Initialize Terraform
   terraform init

   # Review the plan
   terraform plan

   # Apply (Note: This will fail at custom domain if CNAME is not configured)
   terraform apply
   ```

3. **Custom Domain Setup**:
   - If custom domain fails, comment it out temporarily
   - Create the required CNAME record
   - Wait for DNS propagation
   - Uncomment and reapply

## Verifying Policies

### 1. Verify SAS Policy
```bash
# Check storage account properties
az storage account show --name stadvancedpoliciesex --resource-group rg-storage-advanced-policies-example --query sasPolicy
```

### 2. Verify Immutability Policy
```bash
# Check immutability policy
az storage account show --name stadvancedpoliciesex --resource-group rg-storage-advanced-policies-example --query immutabilityPolicy
```

### 3. Verify Routing Preferences
```bash
# Check routing preferences and endpoints
az storage account show --name stadvancedpoliciesex --resource-group rg-storage-advanced-policies-example --query routingPreference
```

### 4. Verify Custom Domain
```bash
# Check custom domain configuration
az storage account show --name stadvancedpoliciesex --resource-group rg-storage-advanced-policies-example --query customDomain
```

### 5. Verify SMB Settings
```bash
# Check file service properties
az storage account file-service-properties show --account-name stadvancedpoliciesex --resource-group rg-storage-advanced-policies-example
```

## Cost Considerations

- **Internet Routing**: Reduces egress costs but may increase latency
- **Lifecycle Policies**: Automatically move data to cheaper tiers
- **Soft Delete**: Retains deleted data (storage costs continue)
- **Versioning**: Stores multiple versions (increases storage costs)
- **SFTP**: Additional charges apply for SFTP endpoint

## Security Notes

1. **SAS Tokens**: Always use time-limited tokens with minimal permissions
2. **Immutability**: Once locked, policies cannot be reversed
3. **Custom Domain**: Does not provide SSL/TLS by default (use Azure CDN for HTTPS)
4. **SMB Multichannel**: Requires proper network configuration for optimal performance

## Troubleshooting

1. **Custom Domain Fails**: 
   - Verify CNAME record exists
   - Check DNS propagation: `nslookup storage.example.com`
   - Try indirect validation with subdomain

2. **Immutability Policy Conflicts**:
   - Cannot delete blobs during immutability period
   - Locked policies are permanent

3. **SMB Access Issues**:
   - Verify network connectivity
   - Check firewall rules
   - Ensure proper authentication configuration

## Clean Up

```bash
# Destroy all resources
terraform destroy
```

**Note**: Immutable blobs cannot be deleted until the retention period expires.
<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compliance_features"></a> [compliance\_features](#output\_compliance\_features) | Summary of compliance and security features enabled |
| <a name="output_custom_domain"></a> [custom\_domain](#output\_custom\_domain) | The custom domain configuration |
| <a name="output_immutability_policy_state"></a> [immutability\_policy\_state](#output\_immutability\_policy\_state) | The state of the immutability policy |
| <a name="output_internet_routing_enabled"></a> [internet\_routing\_enabled](#output\_internet\_routing\_enabled) | Whether internet routing is enabled |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | The primary Data Lake Storage Gen2 endpoint |
| <a name="output_routing_choice"></a> [routing\_choice](#output\_routing\_choice) | The routing preference choice |
| <a name="output_sas_expiration_period"></a> [sas\_expiration\_period](#output\_sas\_expiration\_period) | The SAS token expiration period |
| <a name="output_smb_multichannel_enabled"></a> [smb\_multichannel\_enabled](#output\_smb\_multichannel\_enabled) | Whether SMB Multichannel is enabled |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->
