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