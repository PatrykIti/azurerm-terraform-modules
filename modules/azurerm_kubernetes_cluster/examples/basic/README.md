# Basic AKS Cluster Example

This example demonstrates a basic Azure Kubernetes Service (AKS) cluster configuration using secure defaults and minimal setup.

## Features

- Creates a basic AKS cluster with standard configuration
- Uses system-assigned managed identity for secure authentication
- Creates a dedicated virtual network and subnet
- Uses Azure CNI with Azure network policy
- Enables all storage drivers with secure defaults
- Demonstrates basic module usage patterns

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24)
└── AKS Cluster
    └── Default Node Pool (2 nodes)
```

## Key Configuration

This example demonstrates:
- Basic AKS cluster with minimal configuration
- System-assigned managed identity (no service principal)
- Azure CNI networking with Azure network policy
- Default node pool with 2 Standard_D2s_v3 nodes
- All storage drivers enabled (blob, disk, file, snapshot)
- Secure defaults (no public IPs on nodes, managed OS disks)

## Prerequisites

- Azure subscription
- Terraform >= 1.3.0
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
az aks get-credentials --resource-group rg-aks-basic-example --name aks-basic-example
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
- 1 AKS cluster (management plane is free)
- 2 Standard_D2s_v3 VMs for nodes
- 1 Virtual Network (no charge)
- Standard managed disks for nodes

Estimated monthly cost: ~$140-200 USD (varies by region)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
