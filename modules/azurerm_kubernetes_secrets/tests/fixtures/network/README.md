# Network Kubernetes Secrets Test Fixture

This fixture provisions an AKS cluster with custom networking and validates the secrets module with a manual strategy.

## Resources Created

- Resource Group: `rg-akssec-net-${random_suffix}`
- Virtual Network: `vnet-akssec-net-${random_suffix}`
- Subnet: `snet-akssec-net-${random_suffix}`
- AKS Cluster: `akssec-net-${random_suffix}`
- Key Vault: `kv-akssec-net-${random_suffix}`
- Kubernetes Secret: `app-secrets`

## Test Scenario

This fixture is used for the network test suite and validates that the module works with a cluster configured for Azure CNI networking.
