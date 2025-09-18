# Complete Network Security Group Example

This example demonstrates a comprehensive deployment of Azure Network Security Group with all available features including flow logs, traffic analytics, and complex security rule configurations.

## Features

This example showcases:

- **Comprehensive Security Rules**:
  - Inbound rules using service tags (Internet, VirtualNetwork, AzureLoadBalancer).
  - Outbound rules with multiple destination ports and prefixes.
  - Rules leveraging Application Security Groups (ASGs).
  - Complex rule patterns with multiple source/destination configurations.

- **NSG Flow Logs**:
  - Version 2 flow logs for enhanced data capture.
  - Configurable retention period (30 days in this example).
  - Dedicated storage account for flow log storage.

- **Traffic Analytics**:
  - Integration with Log Analytics Workspace.
  - 10-minute processing interval for near real-time insights.
  - Network traffic patterns and security analysis.

- **Supporting Infrastructure**:
  - Storage Account for flow logs.
  - Log Analytics Workspace for traffic analytics.
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