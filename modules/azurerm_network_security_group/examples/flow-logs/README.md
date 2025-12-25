# Flow Logs Network Security Group Example

This example demonstrates Network Watcher flow logs with traffic analytics.

## Features

- **Flow Logs v2** for NSG traffic visibility (optional)
- **Retention policy** for log storage
- **Traffic Analytics** with Log Analytics Workspace

## Usage

```bash
terraform init
terraform plan
terraform apply
```

> Flow logs are disabled by default (`enable_flow_log = false`) and require an
> existing Network Watcher. Enable them explicitly only if your subscription
> supports creating new NSG flow logs.

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
