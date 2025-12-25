# azurerm_network_security_group Module Security

## Overview

This document describes the security posture and recommended hardening steps for the
`azurerm_network_security_group` module. NSGs are foundational for network access
control in Azure. This module focuses on secure rule definitions and optional
observability for audit and compliance.

## Security Features

### 1. **Network Access Control**

- **Explicit allow/deny rules** with priority management.
- **Least privilege** rule design (narrow source/destination + ports).
- **Service tags** for Microsoft-managed ranges.
- **Application Security Groups (ASGs)** for logical workload grouping.

### 2. **Monitoring and Auditing**

- **Diagnostic settings** for NSG logs and metrics (Log Analytics, Storage, Event Hub).
- **Network Watcher flow logs** with optional **traffic analytics**.
- **Retention policy** controls for flow logs.

### 3. **Governance and Compliance**

- **Tags** for ownership, environment, and classification.
- **Consistent naming** to simplify policy enforcement and audits.

## Secure Configuration Example

```hcl
module "network_security_group" {
  source = "./modules/azurerm_network_security_group"

  name                = "nsg-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = [
    {
      name                       = "deny_all_inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all inbound traffic by default"
    },
    {
      name                       = "allow_https_inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from Internet"
    }
  ]

  diagnostic_settings = [
    {
      name                       = "nsg-security-logs"
      areas                      = ["event", "rule_counter", "metrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  flow_log = {
    name                                 = "nsg-flow-logs"
    storage_account_id                   = azurerm_storage_account.flow_logs.id
    network_watcher_name                 = azurerm_network_watcher.example.name
    network_watcher_resource_group_name  = azurerm_network_watcher.example.resource_group_name
    retention_policy = {
      enabled = true
      days    = 30
    }
    traffic_analytics = {
      enabled               = true
      workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
      workspace_region      = azurerm_log_analytics_workspace.example.location
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
      interval_in_minutes   = 10
    }
  }

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

## Security Hardening Checklist

Before deploying to production:

- [ ] Use **explicit deny** rules for inbound and outbound traffic.
- [ ] Allow only required ports and protocols.
- [ ] Prefer **service tags** over raw IP ranges.
- [ ] Group workloads with **ASGs** where possible.
- [ ] Enable **diagnostic settings** for logs and metrics.
- [ ] Enable **flow logs** with a retention policy.
- [ ] Review and document all rule exceptions.
- [ ] Apply tags for ownership and compliance tracking.

## Common Security Mistakes to Avoid

1. **Overly permissive inbound rules**
   ```hcl
   # ❌ AVOID
   source_address_prefix      = "*"
   destination_port_range     = "*"
   access                     = "Allow"
   ```

2. **No explicit deny rule**
   ```hcl
   # ❌ AVOID
   # Missing final deny rule at low priority (4096)
   ```

3. **Missing observability**
   ```hcl
   # ❌ AVOID
   diagnostic_settings = []
   flow_log            = null
   ```

## Incident Response

If a security incident occurs:

1. **Immediate Actions**
   - Review NSG rules and audit logs
   - Block suspicious IP ranges
   - Increase logging verbosity (diagnostic settings + flow logs)

2. **Investigation**
   - Use Log Analytics queries
   - Correlate flow logs with security alerts
   - Validate rule changes and recent deployments

3. **Remediation**
   - Tighten rule scope
   - Add explicit deny rules
   - Document lessons learned

## Compliance Mapping

### SOC 2 Controls
| Control | Implementation |
|---------|---------------|
| CC6.1 | NSG rules + RBAC |
| CC7.2 | Diagnostic settings + flow logs |

### ISO 27001 Controls
| Control | Implementation |
|---------|---------------|
| A.9.1.2 | Network access controls |
| A.12.4.1 | Event logging |

## Additional Resources

- [Azure NSG Overview](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [NSG Flow Logs](https://learn.microsoft.com/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Diagnostic Settings](https://learn.microsoft.com/azure/azure-monitor/essentials/diagnostic-settings)

---

**Module Version**: 1.0.3  
**Last Updated**: 2025-12-24  
**Security Contact**: security@yourorganization.com
