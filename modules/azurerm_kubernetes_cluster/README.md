# Terraform Azure Kubernetes Cluster Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This module creates a comprehensive Azure Kubernetes Service (AKS) cluster with support for enterprise features including multiple node pools, advanced networking, security configurations, monitoring integration, and various add-ons. It provides secure defaults while allowing full customization for production workloads.

## Features

- ✅ **Multiple Node Pools** - System and user pools with different configurations
- ✅ **Advanced Networking** - Azure CNI, Kubenet, custom VNet integration
- ✅ **Security** - Azure AD RBAC, Workload Identity, OIDC, private clusters
- ✅ **Monitoring** - Azure Monitor, Log Analytics, Prometheus metrics
- ✅ **Add-ons** - Azure Policy, Key Vault Secrets Provider, Application Gateway Ingress
- ✅ **Auto-scaling** - Cluster autoscaler, KEDA, Vertical Pod Autoscaler
- ✅ **High Availability** - Multi-zone deployments, SLA configurations
- ✅ **Cost Optimization** - Spot instances, node pool scaling, maintenance windows

## Prerequisites

- Azure subscription with appropriate permissions
- Resource Group where the cluster will be deployed
- Virtual Network and Subnet (if using custom networking)
- Azure AD configuration (if using Azure AD RBAC)
- Log Analytics Workspace (optional, for monitoring)

## Usage

### Basic Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.0"

  # Core configuration
  name                = "aks-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # DNS configuration
  dns_config = {
    dns_prefix = "aks-example"
  }

  # Identity configuration (secure default)
  identity = {
    type = "SystemAssigned"
  }

  # Default node pool
  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v3"
    node_count     = 2
    vnet_subnet_id = azurerm_subnet.example.id
  }

  # Network configuration
  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

### Advanced Usage with Multiple Node Pools

```hcl
module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.0"

  # ... basic configuration ...

  # Additional node pools
  node_pools = [
    {
      name           = "userpool"
      vm_size        = "Standard_D4s_v3"
      node_count     = 3
      mode           = "User"
      vnet_subnet_id = azurerm_subnet.example.id
      node_labels = {
        workload = "applications"
      }
    },
    {
      name                = "spotpool"
      vm_size             = "Standard_D2s_v3"
      priority            = "Spot"
      eviction_policy     = "Delete"
      spot_max_price      = -1
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      vnet_subnet_id      = azurerm_subnet.example.id
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Security Considerations

This module implements several security best practices by default:

- **System-assigned managed identity** is used by default (no service principal passwords)
- **Azure RBAC** can be enabled for fine-grained access control
- **Private cluster** option available to restrict API server access
- **Network policies** supported for pod-to-pod security
- **Workload Identity** and OIDC for secure workload authentication
- **Disk encryption** enabled by default
- **Security patches** automated through upgrade channels

For production deployments, see the [secure example](examples/secure) which demonstrates all security features.

## Monitoring and Observability

The module supports comprehensive monitoring through:

- **Azure Monitor** integration with Container Insights
- **Log Analytics** workspace for centralized logging
- **Prometheus metrics** collection
- **Diagnostic settings** for control plane logs
- **Application Insights** integration for APM

## Cost Optimization

To optimize costs:

- Use **spot instances** for non-critical workloads
- Enable **cluster autoscaler** to scale nodes based on demand
- Configure **maintenance windows** during off-peak hours
- Use **Standard SKU** only when SLA is required
- Consider **B-series VMs** for development/testing

## Troubleshooting

Common issues and solutions:

1. **Subnet size too small**: Ensure subnet has enough IPs for nodes and pods
2. **DNS resolution issues**: Check DNS service IP is within service CIDR
3. **Node pool scaling**: Verify quota limits in your subscription
4. **Private cluster access**: Configure VPN or jump box for kubectl access

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [Module Documentation](docs/) - Additional guides and best practices

## External Resources

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [AKS Networking Concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [AKS Security Baseline](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/aks-security-baseline)