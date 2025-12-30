# Diagnostic Settings AKS Cluster Example

This example demonstrates configuring AKS control plane diagnostic settings with a Log Analytics workspace.

## Features

- Creates a resource group, virtual network, subnet, and Log Analytics workspace
- Deploys an AKS cluster with system-assigned identity and Azure CNI
- Enables diagnostic settings for API server, audit, and metrics categories
- Shows how to route diagnostic logs and metrics to Log Analytics

## Architecture

```
Resource Group
├── Log Analytics Workspace
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24)
└── AKS Cluster
    └── Default Node Pool (1 node)
```

## Key Configuration

This example demonstrates:
- Control plane diagnostic settings using the `diagnostic_settings` input
- Multiple diagnostic areas in a single settings entry (api_plane, audit, metrics)
- Log Analytics as the diagnostics destination

## Prerequisites

- Azure subscription
- Terraform >= 1.12.2
- Azure CLI (for kubectl configuration)

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. Configure kubectl:
```bash
az aks get-credentials --resource-group rg-aks-diagnostic-settings-example --name aks-diagnostic-settings-example
```

5. Verify cluster access:
```bash
kubectl get nodes
```

## Cleanup

```bash
terraform destroy
```

## Cost Estimation

This example creates:
- 1 AKS cluster (control plane is free)
- 1 Standard_D2s_v3 VM for nodes
- 1 Log Analytics workspace
- 1 Virtual Network (no charge)

Estimated monthly cost: ~$110-160 USD (varies by region)

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes_cluster"></a> [kubernetes\_cluster](#module\_kubernetes\_cluster) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |
| [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the AKS cluster | `string` | `"aks-diagnostic-settings-example"` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix for the AKS cluster | `string` | `"aks-diagnostic-settings-example"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | `"West Europe"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace | `string` | `"law-aks-diagnostic-settings-example"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | `"rg-aks-diagnostic-settings-example"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet | `string` | `"snet-aks-diagnostic-settings-example"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network | `string` | `"vnet-aks-diagnostic-settings-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster |
| <a name="output_connect_command"></a> [connect\_command](#output\_connect\_command) | Command to connect to the cluster using kubectl |
| <a name="output_kubernetes_cluster_endpoint"></a> [kubernetes\_cluster\_endpoint](#output\_kubernetes\_cluster\_endpoint) | The endpoint for the Kubernetes API server |
| <a name="output_kubernetes_cluster_fqdn"></a> [kubernetes\_cluster\_fqdn](#output\_kubernetes\_cluster\_fqdn) | The FQDN of the Azure Kubernetes Service |
| <a name="output_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#output\_kubernetes\_cluster\_id) | The ID of the created Kubernetes Cluster |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | The name of the created Kubernetes Cluster |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace |
<!-- END_TF_DOCS -->
