# Network AKS Test Fixture

This test fixture creates an AKS cluster with network configuration for testing network-related scenarios.

## Resources Created

- Resource Group: `rg-dpc-net-${random_suffix}`
- Virtual Network: `vnet-dpc-net-${random_suffix}`
- Subnet: `snet-dpc-net-${random_suffix}`
- AKS Cluster: `aks-dpc-net-${random_suffix}`

## Naming Convention

All resources follow the pattern: `{type}-{project}-{scenario}-${var.random_suffix}`
- Project identifier: `dpc`
- Scenario abbreviation: `net` (network)

## Test Scenario

This fixture tests:
- Basic AKS cluster deployment with custom network configuration
- Azure CNI networking
- Azure network policy
- Custom service CIDR and DNS service IP