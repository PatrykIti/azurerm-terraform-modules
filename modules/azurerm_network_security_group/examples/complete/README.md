# Complete Network Security Group Example

This example demonstrates a comprehensive deployment of Azure Network Security Group with advanced security rules, diagnostic settings, and flow logs with traffic analytics.

## Features

This example showcases:

- **Comprehensive Security Rules**:
  - Inbound rules using service tags (Internet, VirtualNetwork, AzureLoadBalancer).
  - Outbound rules with multiple destination ports and prefixes.
  - Rules leveraging Application Security Groups (ASGs).
  - Complex rule patterns with multiple source/destination configurations.

- **Diagnostic Settings**:
  - Log Analytics, Storage Account, and Event Hub destinations.
  - Log categories for events and rule counters.
  - Metrics enabled for NSG.

- **Flow Logs & Traffic Analytics**:
  - Version 2 flow logs for enhanced data capture.
  - Configurable retention period (30 days in this example).
  - Log Analytics integration with 10-minute processing interval.

- **Supporting Infrastructure**:
  - Storage Account for flow logs and diagnostic settings.
  - Log Analytics Workspace for diagnostics and traffic analytics.
  - Event Hub for streaming diagnostic logs.
  - Network Watcher for flow log management.
  - Application Security Groups for logical grouping.

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
