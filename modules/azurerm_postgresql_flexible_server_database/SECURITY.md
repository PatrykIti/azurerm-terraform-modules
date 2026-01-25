# azurerm_postgresql_flexible_server_database Module Security

## Overview

This module manages a PostgreSQL database on an existing Azure PostgreSQL
Flexible Server. Security controls are applied at the server and network
layers, which are out of scope for this module.

## Security Considerations

### 1) Server Access

- **Authentication** is configured on the hosting server (password or Entra ID).
- **Network isolation** (private networking or firewall rules) is configured on
  the server and its surrounding network resources.

### 2) Data Protection

- **Encryption at rest** and **in transit** are enforced by the server.
- **Customer-managed keys (CMK)**, if required, must be configured on the server.

### 3) Auditing and Monitoring

- **Diagnostic settings** and log routing are configured on the server.

## Secure Configuration Example

Use `examples/secure` to see a private-networked server and a database created
on that server.

## Security Hardening Checklist

Before deploying to production:

- [ ] Ensure the hosting server uses private networking or strict firewall rules
- [ ] Prefer Entra ID authentication where possible
- [ ] Use CMK if required by policy
- [ ] Enable diagnostic settings on the server
- [ ] Restrict administrative access and rotate credentials

## Common Security Mistakes to Avoid

1) **Relying on public access without restrictions**
   ```hcl
   # Avoid open public access on the hosting server
   network = {
     public_network_access_enabled = true
   }
   ```

2) **Skipping audit logs**
   ```hcl
   # Avoid leaving diagnostic settings disabled on the hosting server
   monitoring = []
   ```

---

**Module Version**: vUnreleased
