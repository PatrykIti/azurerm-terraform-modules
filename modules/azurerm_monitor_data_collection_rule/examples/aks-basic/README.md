# AKS Basic Container Insights Example

This example demonstrates a basic Container Insights Data Collection Rule (DCR) for AKS using the "basic" stream profile.

## Features

- Creates a resource group, VNet, subnet, and AKS cluster
- Enables the AKS monitoring add-on (OMS agent)
- Creates a Log Analytics workspace
- Creates a Data Collection Endpoint (DCE) and Data Collection Rule (DCR)
- Uses a JSON file for Container Insights data collection settings
- Associates the DCR with the AKS cluster

## Key Configuration

- Stream profile: `Microsoft-Perf`, `Microsoft-ContainerLogV2`
- `oms_agent.collection_profile` set to `basic`
- `data-collection-settings.json` drives `extension_json`

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
<!-- END_TF_DOCS -->
