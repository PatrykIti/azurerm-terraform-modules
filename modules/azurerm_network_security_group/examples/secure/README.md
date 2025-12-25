# Secure Network Security Group Example

This example demonstrates a maximum-security Network Security Group configuration suitable for a three-tier application (web, app, db) using a zero-trust approach.

## Features

- **Zero-Trust Ruleset**: Denies all traffic by default and only allows specific, required communication paths.
- **Application Security Groups (ASGs)**: Uses ASGs to create logical, application-based security boundaries instead of relying on IP subnets.
- **Diagnostic Settings**: Sends NSG logs and metrics to Log Analytics.
- **Service Tag Integration**: Uses service tags for secure communication with Azure services.

## Architecture & Security Rules

This example implements the following security model:

```
      Internet
         |
 (HTTPS Inbound on Port 443)
         |
+--------v--------+
|   ASG: Web-Tier |
+-----------------+
         |
 (API Traffic on Port 8080)
         |
+--------v--------+
|   ASG: App-Tier |
+-----------------+
         |
 (Database Traffic on Port 1433)
         |
+--------v--------+
|   ASG: DB-Tier  |
+-----------------+
```

### Inbound Rules
- **DenyAllInbound** (Priority 4096): Blocks all inbound traffic that doesn't match a higher-priority rule.
- **AllowHttpsToWeb** (Priority 100): Allows inbound HTTPS traffic from the `Internet` to the `Web-Tier` ASG.
- **AllowWebToApp** (Priority 110): Allows traffic from the `Web-Tier` ASG to the `App-Tier` ASG on port 8080.
- **AllowAppToDb** (Priority 120): Allows traffic from the `App-Tier` ASG to the `DB-Tier` ASG on port 1433.

### Outbound Rules
- **DenyAllOutbound** (Priority 4096): Blocks all outbound traffic by default.
- **AllowPaasOutbound** (Priority 100): Allows outbound traffic from all ASGs to essential Azure PaaS services (`Storage`, `Sql`, `AzureKeyVault`) for diagnostics and operations.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
