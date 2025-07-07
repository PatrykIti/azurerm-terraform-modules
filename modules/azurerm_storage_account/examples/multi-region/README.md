# Multi-Region Storage Account Example

This example demonstrates a comprehensive multi-region Azure Storage Account deployment strategy with enhanced disaster recovery capabilities, cross-tenant replication, and optimized geo-redundancy configurations.

## Architecture Overview

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  West Europe     │     │  North Europe    │     │  UK South        │
│  (Primary)       │     │  (Secondary)     │     │  (DR/Archive)    │
├──────────────────┤     ├──────────────────┤     ├──────────────────┤
│ • GZRS           │     │ • ZRS            │     │ • LRS            │
│ • Hot Tier       │     │ • Cool Tier      │     │ • Cool/Archive   │
│ • Active R/W     │     │ • Backup Copy    │     │ • Long-term      │
│ • Zone+Geo       │     │ • Zone Redundant │     │ • Compliance     │
│ • Cross-Tenant   │     │ • Cross-Tenant   │     │ • Archive Focus  │
└──────────────────┘     └──────────────────┘     └──────────────────┘
         │                        │                        │
         └────────────────────────┴────────────────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │  Shared Log Analytics     │
                    │  (Centralized Monitoring) │
                    │  + RAGRS Metadata Storage │
                    └────────────────────────────┘
```

## Storage Account Roles

### 1. Primary Storage (West Europe)
- **Purpose**: Active production workload with maximum availability
- **Replication**: Geo-Zone-Redundant Storage (GZRS)
- **Features**:
  - Zone redundancy within primary region (3 zones)
  - Geo-redundancy to secondary region
  - Automatic failover capability
  - Read access to secondary region
  - Hot tier for frequent access
  - Full versioning and change feed
  - Cross-tenant replication enabled
  - Lifecycle policies for cost optimization

### 2. Secondary Storage (North Europe)
- **Purpose**: Regional backup and read scaling
- **Replication**: Zone-Redundant Storage (ZRS)
- **Features**:
  - Zone redundancy within region (3 zones)
  - Cool tier for cost optimization
  - Lifecycle policies for automatic archival
  - Independent from primary for true redundancy
  - Cross-tenant replication enabled
  - Optimized for backup workloads

### 3. DR Storage (UK South)
- **Purpose**: Long-term archive and disaster recovery
- **Replication**: Locally Redundant Storage (LRS)
- **Features**:
  - Aggressive lifecycle policies
  - Immediate transition to archive tier
  - Extended retention periods
  - Lowest cost profile

### 4. Replication Metadata Storage
- **Purpose**: Track replication status and orchestration
- **Replication**: Read-Access Geo-Redundant Storage (RAGRS)
- **Services**: Table and Queue storage
- **Features**:
  - Read-access geo-redundancy for high availability
  - Stores replication metadata
  - Event-driven replication triggers
  - Cross-tenant replication enabled
  - Hot tier for real-time access
  - Secondary region readable for DR scenarios

## Deployment Strategy

### Phase 1: Initial Deployment
```bash
# Deploy all storage accounts with basic configuration
terraform init
terraform plan
terraform apply
```

### Phase 2: Enable Private Endpoints (Recommended for Production)
```bash
# Enable private endpoints for network isolation
terraform apply -var="enable_private_endpoints=true"
```

### Phase 3: Configure Replication Automation
```bash
# Enable Logic App for automated replication
terraform apply -var="enable_replication_automation=true"
```

### Phase 4: Enable Monitoring and Alerts
```bash
# Configure comprehensive monitoring
terraform apply -var="enable_monitoring_alerts=true"
```

### Phase 5: Test Failover
1. Verify read access to secondary endpoints
2. Test manual failover procedures:
   ```bash
   az storage account failover --name <primary-storage-name> --resource-group <rg-name>
   ```
3. Validate data consistency across regions
4. Monitor replication lag alerts

## Replication Patterns

### Active-Passive Replication
- Primary (West Europe) → Secondary (North Europe)
- Asynchronous replication via GRS
- Secondary available for read-only access

### Archive Replication
- Primary → DR (UK South)
- Scheduled batch replication
- Focus on compliance and long-term retention

### Metadata Synchronization
- All regions → Metadata Storage
- Real-time status updates
- Replication orchestration

## Cost Optimization Features

1. **Tiered Storage**:
   - Primary: Hot tier for active data
   - Secondary: Cool tier for backup
   - DR: Archive tier for long-term storage

2. **Lifecycle Policies**:
   - Automatic data movement between tiers
   - Age-based archival rules
   - Deletion policies for expired data

3. **Regional Optimization**:
   - LRS in DR region (sufficient for archive)
   - ZRS in secondary (balance of cost/availability)
   - RAGRS only where failover is critical

## Monitoring and Operations

### Centralized Monitoring
- Single Log Analytics workspace
- Cross-region metrics aggregation
- Unified alerting and dashboards

### Key Metrics to Monitor
- Replication lag between regions
- Storage capacity utilization
- Transaction patterns
- Failover readiness status

## Disaster Recovery Procedures

### Scenario 1: Primary Region Outage
1. Traffic automatically routes to secondary endpoint (RAGRS)
2. Initiate failover if outage is extended
3. Update DNS records if needed

### Scenario 2: Data Corruption
1. Restore from versioned blobs
2. Use point-in-time restore if enabled
3. Failback from secondary or DR storage

### Scenario 3: Complete Regional Failure
1. Activate DR site (UK South)
2. Restore from archive tier
3. Rebuild primary in alternate region

## Security Considerations

- **Encryption**: All storage accounts use Microsoft-managed keys with infrastructure encryption
- **Network**: Private endpoints available with full VNet isolation
- **Access**: System-assigned managed identities for all storage accounts
- **Monitoring**: Comprehensive alerts for availability, errors, and replication lag
- **Network Rules**: Restrictive by default when private endpoints are enabled
- **IP Whitelisting**: Configure allowed IP ranges via variables

## Prerequisites

- Azure subscription with multi-region access
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (correctly pinned to match the module version)
- Sufficient storage quota in all regions
- Network connectivity between regions (for private endpoints)
- Budget approval for multi-region storage costs

**Note**: The module uses a pinned version of the AzureRM provider (4.35.0) to ensure consistent behavior across all deployments.

## Customization Options

1. **Regions**: Adjust locations based on your requirements
2. **Replication Types**: Modify based on RPO/RTO needs
3. **Lifecycle Policies**: Tune retention periods
4. **Network Security**: Add private endpoints and firewalls
5. **Encryption**: Implement customer-managed keys

## Geo-Replication Benefits

### Enhanced Availability
1. **GZRS (Geo-Zone-Redundant Storage)**:
   - 16 nines (99.99999999999999%) durability
   - Protection against zone failures in primary region
   - Protection against regional disasters
   - Automatic failover capabilities

2. **Read Access Geo-Redundancy**:
   - Secondary region endpoints always available for read
   - Load distribution for read-heavy workloads
   - Near real-time data availability in secondary region

3. **Zone Redundancy**:
   - Data replicated across 3 availability zones
   - Protection against datacenter failures
   - No single point of failure within a region

### Performance Benefits
- Reduced latency for geographically distributed users
- Load balancing across regions for read operations
- Improved application responsiveness

## Cross-Tenant Replication Use Cases

### 1. Multi-Tenant SaaS Applications
- **Scenario**: SaaS provider serving multiple customer tenants
- **Benefit**: Each tenant's data can be replicated to their preferred regions
- **Implementation**: Enable cross-tenant replication for tenant-specific storage accounts

### 2. Mergers and Acquisitions
- **Scenario**: Company acquisition requiring data consolidation
- **Benefit**: Seamless data replication between different Azure tenants
- **Implementation**: Temporary cross-tenant replication during migration

### 3. Partner Data Sharing
- **Scenario**: B2B partnerships requiring secure data exchange
- **Benefit**: Controlled replication of specific datasets between partner tenants
- **Implementation**: Selective cross-tenant replication with access controls

### 4. Regulatory Compliance
- **Scenario**: Data sovereignty requirements across jurisdictions
- **Benefit**: Maintain data copies in required geographical locations
- **Implementation**: Cross-tenant replication to region-specific tenants

### 5. Disaster Recovery Partnerships
- **Scenario**: Organizations sharing DR infrastructure
- **Benefit**: Cost-effective DR solution through shared resources
- **Implementation**: Cross-tenant replication to partner's DR environment

## Disaster Recovery Scenarios

### Enhanced DR Capabilities

1. **Zone Failure Protection (GZRS)**:
   - Automatic failover within primary region
   - No data loss, minimal downtime
   - Transparent to applications

2. **Regional Disaster Protection**:
   - Manual failover to secondary region
   - RPO: < 15 minutes (typically)
   - RTO: < 1 hour with proper automation

3. **Cross-Tenant DR**:
   - Failover to completely separate Azure tenant
   - Protection against tenant-wide issues
   - Enhanced security isolation

### DR Implementation Steps

1. **Primary Region Failure**:
   ```bash
   # Initiate storage account failover
   az storage account failover --name <storage-account-name>
   
   # Update application connection strings
   # Point to secondary endpoints
   ```

2. **Zone Failure (Automatic)**:
   - No action required
   - GZRS handles automatically
   - Monitor through Azure Monitor

3. **Cross-Tenant Failover**:
   - Pre-configured replication partnerships
   - Automated failover scripts
   - DNS updates for seamless transition

## Best Practices

1. **Regular Testing**: Test failover procedures quarterly
2. **Documentation**: Maintain runbooks for DR procedures
3. **Automation**: Use Logic App or Azure Function for replication orchestration
4. **Cost Review**: Regular review of storage tiers and lifecycle policies
5. **Compliance**: Ensure retention meets regulatory requirements
6. **Cross-Tenant Security**: Implement proper RBAC and network controls
7. **Monitoring**: Configure alerts for:
   - Replication lag exceeding threshold (default: 30 minutes)
   - Storage availability dropping below 99.9%
   - High transaction error rates
   - Storage capacity exceeding 80%

## Enhanced Features in This Example

### 1. Private Endpoints
- Complete VNet isolation for all storage accounts
- Cross-region VNet peering for secure replication
- Private DNS zones for seamless name resolution
- Support for blob, table, and queue endpoints

### 2. Replication Automation
- Logic App-based replication orchestration
- Configurable replication schedule (CRON expression)
- System-assigned identity with proper RBAC
- Alternative Azure Function implementation (commented)

### 3. Advanced Monitoring
- Comprehensive metric alerts
- Log Analytics queries for analysis
- Application Insights integration
- Saved searches for common scenarios

### 4. Security Hardening
- Network rules deny by default with private endpoints
- Infrastructure encryption enabled
- Managed identities for all operations
- IP whitelisting support

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------||
| `primary_location` | Primary region | West Europe |
| `secondary_location` | Secondary region | North Europe |
| `dr_location` | DR region | UK South |
| `enable_private_endpoints` | Enable private endpoints | false |
| `enable_replication_automation` | Enable Logic App replication | false |
| `enable_monitoring_alerts` | Enable monitoring alerts | true |
| `replication_lag_threshold_minutes` | Alert threshold for lag | 30 |
| `allowed_ip_ranges` | Allowed public IPs | [] |