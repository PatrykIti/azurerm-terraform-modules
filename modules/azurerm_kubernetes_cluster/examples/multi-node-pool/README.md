# Multi Node Pool AKS Cluster Example

This example demonstrates an Azure Kubernetes Service (AKS) cluster with multiple node pools, optimized for cost-effective testing scenarios.

## Features

- Creates an AKS cluster with multiple node pools
- System pool with 2 nodes for control plane operations
- User pool with 1 node for general workloads
- Cost-optimized configuration without expensive features
- Uses regular VMs (no spot instances for reliability)
- Basic configuration suitable for development/testing

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24)
└── AKS Cluster
    ├── System Node Pool (2 nodes, Standard_D2s_v3)
    └── User Node Pool (1 node, Standard_D2s_v3)
```

## Key Configuration

This example demonstrates:
- **Multi-pool architecture**: Separate system and user node pools
- **Cost optimization**: Minimal node counts and basic VM sizes
- **No expensive features**: No spot instances, GPU nodes, or premium add-ons
- **Node pool labeling**: User pool labeled for workload identification
- **Free SKU tier**: Uses free tier to minimize costs
- **System-assigned identity**: Secure authentication without service principals

## Node Pools

### System Pool
- **Purpose**: Runs system pods and control plane components
- **Configuration**: 2 nodes (minimum for reliability), Standard_D2s_v3
- **Mode**: System (dedicated to system workloads)

### User Pool
- **Purpose**: Runs application workloads
- **Configuration**: 1 node (minimal for testing), Standard_D2s_v3
- **Mode**: User (for application workloads)
- **Labels**: `workload-type=general`, `pool-type=user`

## Cost Considerations

This example is designed to minimize costs while testing multi-node pool functionality:
- Uses Standard_D2s_v3 VMs (cost-effective general-purpose VMs)
- Minimal node counts (2 system + 1 user = 3 total nodes)
- No auto-scaling to prevent unexpected cost increases
- Free SKU tier (no SLA)
- No expensive add-ons or features
- Regular priority VMs (no spot instances)

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

4. Get credentials for kubectl:
```bash
$(terraform output -raw connect_command)
```

5. Verify node pools:
```bash
kubectl get nodes -L agentpool
```

## Testing Multi-Pool Functionality

After deployment, you can test node pool functionality:

```bash
# View all nodes with their pool assignments
kubectl get nodes -L agentpool,workload-type,pool-type

# Deploy a workload to the user pool
kubectl run test-app --image=nginx --overrides='{"spec":{"nodeSelector":{"agentpool":"userpool"}}}'

# Scale the user pool (would require enabling auto-scaling or manual intervention)
# This example keeps auto-scaling disabled for cost control
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Customization

To add more node pools or modify existing ones:

1. Add entries to the `node_pools` list in `main.tf`
2. Consider different VM sizes for different workload types
3. Add node taints for specialized workloads
4. Configure node labels for workload scheduling

Remember to balance functionality needs with cost considerations when adding resources.