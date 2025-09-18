# Azure Data Lake Storage Gen2 Example

This example demonstrates how to configure an Azure Storage Account as a Data Lake Storage Gen2 with hierarchical namespace, SFTP, and NFSv3 support.

## Overview

Azure Data Lake Storage Gen2 is a set of capabilities dedicated to big data analytics, built on Azure Blob Storage. It provides:

- **Hierarchical Namespace (HNS)**: File system semantics, directory operations, and enhanced performance
- **Multi-protocol access**: Blob API, DFS API, SFTP, and NFSv3
- **Enterprise-grade security**: ACLs at directory and file level
- **Optimized performance**: For big data analytics workloads

## Architecture

This example creates a Data Lake Storage Gen2 account with the following architecture:

```
Data Lake Storage Gen2
├── Bronze Layer (Raw Data)
│   ├── raw-data/
│   └── staging/
├── Silver Layer (Cleaned Data)
│   └── processed/
└── Gold Layer (Business-Ready)
    └── reports/
```

### Key Components

1. **Storage Account**: Configured with HNS enabled for Data Lake Gen2
2. **Filesystems**: Three containers representing Bronze, Silver, and Gold data layers
3. **Network Security**: VNet integration for NFSv3 access
4. **Access Protocols**: SFTP and NFSv3 enabled for multi-protocol access
5. **Monitoring**: Diagnostic settings for audit and performance tracking

## Features Demonstrated

- ✅ Hierarchical Namespace (HNS) enabled
- ✅ SFTP protocol support with local users
- ✅ NFSv3 protocol support
- ✅ Multi-layer data architecture (Bronze/Silver/Gold)
- ✅ Lifecycle management policies
- ✅ Network isolation with VNet integration
- ✅ Comprehensive monitoring and diagnostics

## Prerequisites

- Azure subscription
- Terraform >= 1.3.0
- AzureRM Provider >= 3.0.0
- Network connectivity for NFSv3 (if using from on-premises)

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Connecting to Data Lake Storage Gen2

### 1. Using SFTP

Connect using SFTP with the created local user:

```bash
# Get the SFTP endpoint from outputs
terraform output sftp_endpoint

# Connect using sftp (replace with actual values)
sftp sftpuser@<storage-account-name>.sftp.core.windows.net
```

For password authentication, retrieve the password from the Azure Portal or use SSH key authentication.

### 2. Using NFSv3

Mount the storage account using NFSv3 protocol from a Linux VM in the same VNet:

```bash
# Install NFS utilities
sudo apt-get update
sudo apt-get install nfs-common

# Create mount point
sudo mkdir -p /mnt/datalake

# Get the NFS mount point from outputs
terraform output nfs_mount_point

# Mount the storage account
sudo mount -t nfs -o vers=3,proto=tcp,sec=sys <storage-account-name>.blob.core.windows.net:/<storage-account-name>/<filesystem-name> /mnt/datalake
```

### 3. Using Azure Storage Explorer

1. Download and install [Azure Storage Explorer](https://azure.microsoft.com/features/storage-explorer/)
2. Connect using the storage account name and key
3. Navigate through the hierarchical structure

### 4. Using DFS API

Access data using the DFS endpoint for hierarchical operations:

```python
from azure.storage.filedatalake import DataLakeServiceClient

# Get the DFS endpoint from outputs
dfs_endpoint = terraform_output["primary_dfs_endpoint"]

# Create service client
service_client = DataLakeServiceClient(
    account_url=dfs_endpoint,
    credential=credential
)

# List filesystems
for filesystem in service_client.list_file_systems():
    print(filesystem.name)
```

## Hierarchical Namespace Benefits

### 1. Atomic Directory Operations
- Rename, move, or delete entire directories atomically
- No need to process individual blobs

### 2. Improved Performance
- Optimized for analytics workloads
- Faster directory traversal and metadata operations

### 3. POSIX Permissions
- Fine-grained access control at file and directory level
- Compatible with Hadoop and Spark workloads

### 4. Multi-Protocol Access
- Same data accessible via Blob API, DFS API, SFTP, and NFSv3
- Choose the right protocol for your workload

## Security Considerations

1. **Network Security**:
   - Storage account is accessible from specified VNet subnet
   - Configure firewall rules for additional IP ranges
   - Consider private endpoints for production use

2. **Authentication**:
   - SFTP uses local users with SSH keys or passwords
   - NFSv3 uses storage account keys
   - DFS API supports Azure AD authentication

3. **Encryption**:
   - Data encrypted at rest by default
   - TLS 1.2 minimum for data in transit
   - Consider customer-managed keys for additional control

## Lifecycle Management

The example includes lifecycle policies for:

1. **Archival**: Move old data to cooler tiers
2. **Cleanup**: Automatically delete temporary data
3. **Cost Optimization**: Tier data based on access patterns

## Advanced Features

### Change Feed
- **Enabled**: Tracks all changes to blobs in the storage account
- **Retention**: 7 days of change history
- **Use Cases**: Data pipeline triggers, audit trails, incremental processing
- **Access**: Available through the DFS API or change feed processor

### Query Acceleration
- Available on-demand for specific queries
- Not configured via Terraform (runtime feature)
- Enables SQL-like queries on CSV/JSON files
- Reduces data transfer and improves query performance

### ACL (Access Control Lists)
- **POSIX-style permissions**: Fine-grained access control at file/directory level
- **Inheritance**: Default ACLs apply to new items in directories
- **Integration**: Works alongside Azure RBAC for defense in depth
- **Example**: Data Engineers have full access, Data Analysts have read-only to raw data

## Analytics Integration

The example includes commented-out configurations for:

### Azure Databricks
- Mount Data Lake filesystems in Databricks
- Use service principal authentication
- Access data using Spark DataFrames

### Azure Synapse Analytics
- Native integration with Data Lake Gen2
- SQL on-demand queries over data lake
- Spark pools for big data processing

### Azure Data Factory
- Orchestrate data pipelines
- Copy data between tiers
- Transform data using mapping data flows

## Monitoring and Diagnostics

- Storage metrics tracked in Log Analytics
- Read/Write/Delete operations logged
- Transaction and capacity metrics available
- Change feed provides detailed change tracking

## Cost Considerations

1. **Storage Costs**: Based on data volume and access tier
2. **Transaction Costs**: Higher for hot tier, lower for cool/archive
3. **Protocol Costs**: SFTP and NFSv3 may have additional charges
4. **Egress Costs**: Data transfer out of Azure region

## Clean Up

To remove all resources:

```bash
terraform destroy
```

## Additional Resources

- [Azure Data Lake Storage Gen2 Documentation](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-introduction)
- [Multi-protocol access on Data Lake Storage](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-multi-protocol-access)
- [SFTP support for Azure Blob Storage](https://docs.microsoft.com/azure/storage/blobs/secure-file-transfer-protocol-support)
- [Mount Blob Storage by using NFS 3.0](https://docs.microsoft.com/azure/storage/blobs/network-file-system-protocol-support)
<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.43.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_lake_storage"></a> [data\_lake\_storage](#module\_data\_lake\_storage) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuread_application.data_analyst](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application.data_engineer](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.data_analyst](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.data_engineer](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.current_user_owner](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.data_analyst_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.data_analyst_reader_gold](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.data_engineer_owner](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/role_assignment) | resource |
| [azurerm_storage_account_local_user.sftp_user](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_account_local_user) | resource |
| [azurerm_storage_data_lake_gen2_filesystem.bronze](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_storage_data_lake_gen2_filesystem.gold](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_storage_data_lake_gen2_filesystem.silver](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_storage_data_lake_gen2_path.bronze_raw](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_path) | resource |
| [azurerm_storage_data_lake_gen2_path.bronze_staging](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_path) | resource |
| [azurerm_storage_data_lake_gen2_path.gold_reports](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_path) | resource |
| [azurerm_storage_data_lake_gen2_path.sample_data_dir](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_path) | resource |
| [azurerm_storage_data_lake_gen2_path.silver_processed](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/storage_data_lake_gen2_path) | resource |
| [azurerm_subnet.nfs_clients](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bronze_filesystem_id"></a> [bronze\_filesystem\_id](#output\_bronze\_filesystem\_id) | The ID of the bronze data lake filesystem |
| <a name="output_data_lake_features"></a> [data\_lake\_features](#output\_data\_lake\_features) | Summary of enabled Data Lake Gen2 features |
| <a name="output_gold_filesystem_id"></a> [gold\_filesystem\_id](#output\_gold\_filesystem\_id) | The ID of the gold data lake filesystem |
| <a name="output_nfs_mount_point"></a> [nfs\_mount\_point](#output\_nfs\_mount\_point) | The NFSv3 mount point for the storage account |
| <a name="output_nfs_subnet_id"></a> [nfs\_subnet\_id](#output\_nfs\_subnet\_id) | The ID of the subnet configured for NFSv3 access |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint (also supports DFS operations) |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | The primary DFS endpoint for Data Lake Storage Gen2 |
| <a name="output_primary_dfs_host"></a> [primary\_dfs\_host](#output\_primary\_dfs\_host) | The primary DFS host for Data Lake Storage Gen2 |
| <a name="output_primary_dfs_internet_endpoint"></a> [primary\_dfs\_internet\_endpoint](#output\_primary\_dfs\_internet\_endpoint) | The internet routing DFS endpoint for Data Lake Storage Gen2 |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_sftp_endpoint"></a> [sftp\_endpoint](#output\_sftp\_endpoint) | The SFTP endpoint for the storage account |
| <a name="output_sftp_user_name"></a> [sftp\_user\_name](#output\_sftp\_user\_name) | The name of the SFTP user |
| <a name="output_silver_filesystem_id"></a> [silver\_filesystem\_id](#output\_silver\_filesystem\_id) | The ID of the silver data lake filesystem |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the Data Lake Storage Gen2 account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Data Lake Storage Gen2 account |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the virtual network for NFSv3 access |
<!-- END_TF_DOCS -->
