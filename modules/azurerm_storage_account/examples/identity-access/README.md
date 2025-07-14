# Azure Storage Account with Identity-Based Access Example

This example demonstrates how to configure an Azure Storage Account with **keyless authentication** using managed identities and Microsoft Entra ID (formerly Azure AD) integration. This approach eliminates the need for shared access keys, providing enhanced security through identity-based access control.

## Key Features

- **System-Assigned Managed Identity**: Enables the storage account to authenticate to other Azure services
- **Keyless Authentication**: Shared access keys are disabled (`shared_access_key_enabled = false`)
- **Microsoft Entra ID Integration**: Default authentication method is set to OAuth (`default_to_oauth_authentication = true`)
- **RBAC-Based Access Control**: All access is managed through Azure role assignments
- **Enhanced Security**: No keys to rotate, steal, or accidentally expose

## Benefits of Keyless Authentication

### 1. **Enhanced Security**
- **No Shared Keys**: Eliminates the risk of key exposure in code, configuration files, or logs
- **No Key Rotation**: Removes the operational overhead of regular key rotation
- **Audit Trail**: All access is logged with user/service identity information
- **Conditional Access**: Can apply Microsoft Entra ID conditional access policies

### 2. **Simplified Access Management**
- **Centralized Control**: Manage access through Azure RBAC instead of distributing keys
- **Granular Permissions**: Assign specific roles (Reader, Contributor, etc.) at different scopes
- **Group-Based Access**: Leverage Azure AD groups for team access management
- **Temporary Access**: Use Privileged Identity Management (PIM) for time-bound access

### 3. **Better Developer Experience**
- **No Secrets in Code**: Developers authenticate using their Azure AD credentials
- **Local Development**: Same authentication method works locally and in production
- **Tool Integration**: Azure CLI, Azure PowerShell, and SDKs support identity-based auth

## Testing with Azure CLI

After deploying this example, you can test identity-based access using the Azure CLI:

```bash
# First, ensure you're logged in to Azure CLI
az login

# List blobs using identity-based authentication (--auth-mode login)
az storage blob list \
  --account-name <storage_account_name> \
  --container-name test-container \
  --auth-mode login

# Upload a file using identity-based authentication
az storage blob upload \
  --account-name <storage_account_name> \
  --container-name test-container \
  --file ./test-file.txt \
  --name test-file.txt \
  --auth-mode login

# Download a file using identity-based authentication
az storage blob download \
  --account-name <storage_account_name> \
  --container-name test-container \
  --name test-file.txt \
  --file ./downloaded-file.txt \
  --auth-mode login
```

**Note**: The `--auth-mode login` parameter tells Azure CLI to use your Azure AD credentials instead of storage account keys.

## RBAC Best Practices

### 1. **Principle of Least Privilege**
- Grant only the minimum permissions required
- Use specific roles rather than broad ones
- Prefer built-in roles over custom roles when possible

### 2. **Common Storage RBAC Roles**
- **Storage Blob Data Reader**: Read access to blob data
- **Storage Blob Data Contributor**: Read, write, and delete access to blob data
- **Storage Blob Data Owner**: Full access including POSIX ACL management
- **Storage Account Contributor**: Manage storage account but not access data

### 3. **Scope Management**
```hcl
# Account-level access
resource "azurerm_role_assignment" "account_level" {
  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.user_object_id
}

# Container-level access (more restrictive)
resource "azurerm_role_assignment" "container_level" {
  scope                = "${module.storage_account.id}/blobServices/default/containers/specific-container"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.service_principal_id
}
```

### 4. **Service Principal Access**
For applications and services:
```hcl
# Create a service principal for your application
resource "azuread_application" "app" {
  display_name = "storage-access-app"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

# Grant the service principal access
resource "azurerm_role_assignment" "app_access" {
  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.app.object_id
}
```

## Microsoft Entra ID Integration

### 1. **Authentication Flow**
1. User/Application authenticates to Microsoft Entra ID
2. Azure AD issues a token with user's identity and permissions
3. Storage service validates the token and checks RBAC assignments
4. Access is granted or denied based on assigned roles

### 2. **Conditional Access Policies**
When using Microsoft Entra ID authentication, you can apply conditional access policies:
- Require multi-factor authentication
- Restrict access from specific locations
- Require compliant devices
- Block legacy authentication protocols

### 3. **Managed Identity Benefits**
The storage account's system-assigned managed identity can:
- Access Key Vault for encryption keys
- Write to Log Analytics workspaces
- Trigger Azure Functions
- Access other storage accounts

Example usage in the code:
```hcl
# Storage account can now access Key Vault using its managed identity
resource "azurerm_role_assignment" "storage_identity_keyvault_access" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.storage_account.identity.principal_id
}
```

## Migration from Key-Based to Identity-Based Access

If migrating existing applications:

1. **Enable Dual Authentication**: Keep keys enabled initially while adding RBAC assignments
2. **Update Applications**: Modify applications to use identity-based authentication
3. **Monitor Access**: Use Azure Monitor to track authentication methods
4. **Disable Keys**: Once all applications are migrated, disable shared access keys

## Monitoring and Auditing

With identity-based access, you get enhanced monitoring capabilities:

```bash
# View storage account activity logs
az monitor activity-log list \
  --resource-id $(az storage account show --name <storage_account_name> --query id -o tsv) \
  --start-time 2024-01-01T00:00:00Z
```

All access is logged with:
- User/Service identity
- Operation performed
- Timestamp
- Source IP address
- Success/Failure status

## Common Scenarios

### 1. **CI/CD Pipeline Access**
```yaml
# GitHub Actions example using Azure login
- uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

# Now CLI commands work without keys
- run: |
    az storage blob upload \
      --account-name ${{ env.STORAGE_ACCOUNT }} \
      --container-name artifacts \
      --file ./build/app.zip \
      --name app-${{ github.sha }}.zip \
      --auth-mode login
```

### 2. **Application Access with Managed Identity**
```csharp
// .NET example using DefaultAzureCredential
var blobServiceClient = new BlobServiceClient(
    new Uri($"https://{storageAccountName}.blob.core.windows.net"),
    new DefaultAzureCredential());

// No connection strings or keys needed!
```

### 3. **Cross-Service Access**
The storage account's managed identity can access other services:
- Write diagnostic logs to another storage account
- Retrieve secrets from Key Vault for encryption
- Send events to Event Grid
- Trigger Logic Apps or Azure Functions

## Troubleshooting

### Common Issues

1. **Access Denied Errors**
   - Verify RBAC assignment is at the correct scope
   - Check if assignment has propagated (can take up to 30 minutes)
   - Ensure the principal ID is correct

2. **Cannot List Containers**
   - Need at least "Storage Blob Data Reader" at account level
   - "Reader" role only allows management plane operations, not data plane

3. **CLI Commands Fail**
   - Ensure using `--auth-mode login` parameter
   - Check Azure CLI is up to date: `az upgrade`
   - Verify logged in: `az account show`

## Security Considerations

1. **Network Security**: Combine identity-based access with network restrictions
2. **Encryption**: Use customer-managed keys with Key Vault integration
3. **Monitoring**: Enable diagnostic settings and alerts for suspicious activity
4. **Compliance**: Identity-based access helps meet many compliance requirements

## Additional Resources

- [Authorize access to data in Azure Storage](https://learn.microsoft.com/azure/storage/common/authorize-data-access)
- [Azure Storage RBAC roles](https://learn.microsoft.com/azure/storage/blobs/authorize-access-azure-active-directory)
- [Managed identities for Azure resources](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [Azure CLI storage commands](https://learn.microsoft.com/cli/azure/storage)
<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_combined"></a> [storage\_combined](#module\_storage\_combined) | github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0 | n/a |
| <a name="module_storage_system_assigned"></a> [storage\_system\_assigned](#module\_storage\_system\_assigned) | github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0 | n/a |
| <a name="module_storage_user_assigned"></a> [storage\_user\_assigned](#module\_storage\_user\_assigned) | github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0 | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.combined_system_identity_kv_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.container_level_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.current_user_combined](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.current_user_kv_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.current_user_system](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.current_user_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.system_identity_kv_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.uai_kv_crypto_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_combined_storage_account_id"></a> [combined\_storage\_account\_id](#output\_combined\_storage\_account\_id) | The ID of the combined identities storage account |
| <a name="output_combined_storage_account_name"></a> [combined\_storage\_account\_name](#output\_combined\_storage\_account\_name) | The name of the combined identities storage account |
| <a name="output_combined_system_principal_id"></a> [combined\_system\_principal\_id](#output\_combined\_system\_principal\_id) | The principal ID of the system-assigned identity for the combined account |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault used for customer-managed keys |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault |
| <a name="output_storage_encryption_key_id"></a> [storage\_encryption\_key\_id](#output\_storage\_encryption\_key\_id) | The ID of the storage encryption key |
| <a name="output_system_assigned_principal_id"></a> [system\_assigned\_principal\_id](#output\_system\_assigned\_principal\_id) | The principal ID of the system-assigned identity |
| <a name="output_system_assigned_storage_account_id"></a> [system\_assigned\_storage\_account\_id](#output\_system\_assigned\_storage\_account\_id) | The ID of the system-assigned identity storage account |
| <a name="output_system_assigned_storage_account_name"></a> [system\_assigned\_storage\_account\_name](#output\_system\_assigned\_storage\_account\_name) | The name of the system-assigned identity storage account |
| <a name="output_system_assigned_tenant_id"></a> [system\_assigned\_tenant\_id](#output\_system\_assigned\_tenant\_id) | The tenant ID of the system-assigned identity |
| <a name="output_testing_instructions"></a> [testing\_instructions](#output\_testing\_instructions) | Instructions for testing identity-based access |
| <a name="output_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#output\_user\_assigned\_identity\_id) | The ID of the user-assigned identity |
| <a name="output_user_assigned_identity_principal_id"></a> [user\_assigned\_identity\_principal\_id](#output\_user\_assigned\_identity\_principal\_id) | The principal ID of the user-assigned identity |
| <a name="output_user_assigned_storage_account_id"></a> [user\_assigned\_storage\_account\_id](#output\_user\_assigned\_storage\_account\_id) | The ID of the user-assigned identity storage account |
| <a name="output_user_assigned_storage_account_name"></a> [user\_assigned\_storage\_account\_name](#output\_user\_assigned\_storage\_account\_name) | The name of the user-assigned identity storage account |
<!-- END_TF_DOCS -->
