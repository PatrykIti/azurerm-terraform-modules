# Security Considerations

This module deploys Azure Bastion, which provides managed RDP/SSH access to virtual machines. Review the following items before enabling additional features.

## Required Network Foundations

- The Bastion subnet must be named `AzureBastionSubnet` and sized at least `/26`.
- Public Bastion SKUs require a **Standard**, **static** public IP address.
- User-defined routes (UDR) are not supported on the Bastion subnet.

## Feature Flags and Risk

- **IP Connect, Tunneling, Shareable Link, File Copy, Kerberos** increase the exposed remote-access surface area. Enable only when required and restrict access via Azure RBAC, Conditional Access, and Just-In-Time practices.
- **Session Recording (Premium only)** stores session data. Ensure your storage and retention policies align with compliance requirements.
- **Copy/Paste** may enable data exfiltration paths; disable it for highly sensitive workloads.

## Recommended Hardening

- Use the `secure` example as a baseline: disable optional remote features and apply the recommended NSG rules to `AzureBastionSubnet`.
- Limit the number of users with Bastion access (least privilege).
- Monitor Bastion audit logs with diagnostic settings and alert on unexpected access patterns.
