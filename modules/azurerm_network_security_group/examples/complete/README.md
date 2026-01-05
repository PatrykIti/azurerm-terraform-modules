# Complete Network Security Group Example

This example demonstrates a comprehensive deployment of Azure Network Security Group with advanced security rules and diagnostic settings.

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

- **Supporting Infrastructure**:
  - Storage Account for diagnostic settings.
  - Log Analytics Workspace for diagnostics.
  - Event Hub for streaming diagnostic logs.
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
