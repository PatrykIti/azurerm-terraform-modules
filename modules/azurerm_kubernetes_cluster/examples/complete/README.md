# Complete AKS Cluster Example

This example demonstrates a comprehensive Azure Kubernetes Service (AKS) cluster configuration showcasing advanced features and production-ready settings.

## Features

- **Advanced Identity**: User-assigned managed identity with workload identity and OIDC issuer
- **Comprehensive Networking**: Azure CNI with separate pod subnet, NSG associations, and load balancer configuration
- **Auto-scaling**: Cluster autoscaler with custom profile settings and node pool auto-scaling
- **Monitoring**: Container Insights with Log Analytics integration
- **Security**: Azure AD RBAC, Azure Policy, Key Vault Secrets Provider
- **High Availability**: Multi-zone deployment with 3 availability zones
- **Maintenance Windows**: Scheduled maintenance for both cluster and node OS upgrades
- **Advanced Node Configuration**: Custom kubelet settings, Linux OS tuning, and sysctl parameters
- **Cost Optimization**: Cost analysis enabled, image cleaner, and optimized autoscaler settings

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   ├── Node Subnet (10.0.1.0/24) - With NSG
│   └── Pod Subnet (10.0.2.0/22) - Delegated to AKS
├── Log Analytics Workspace
├── User Assigned Identity
└── AKS Cluster
    ├── System Node Pool (2-5 nodes, D4s_v3)
    ├── Container Insights
    ├── Azure AD RBAC
    ├── Workload Identity + OIDC
    └── Advanced Autoscaling
```

## Key Configuration Details

### Identity & Security
- User-assigned managed identity for cluster
- Workload identity enabled with OIDC issuer
- Azure AD RBAC with admin groups
- Key Vault Secrets Provider with rotation
- Azure Policy add-on enabled

### Networking
- Azure CNI with overlay mode
- Separate subnets for nodes and pods
- Standard SKU load balancer with 2 managed IPs
- Network Security Group on node subnet
- Custom service CIDR (172.16.0.0/16)

### Node Pool Configuration
- Auto-scaling enabled (2-5 nodes)
- Standard_D4s_v3 VMs across 3 zones
- 100GB OS disks
- Custom kubelet configuration
- Optimized Linux kernel parameters
- System node pool with critical addons only

### Monitoring & Management
- Container Insights with MSI authentication
- Cost analysis enabled
- Image cleaner (48-hour interval)
- KEDA and Vertical Pod Autoscaler
- Weekly maintenance windows

## Prerequisites

- Azure subscription
- Terraform >= 1.3.0
- Azure CLI with kubelogin extension
- Azure AD tenant (for RBAC features)
- Appropriate permissions to create resources

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region for resources | West Europe |
| `kubernetes_version` | Kubernetes version | 1.29.2 |
| `authorized_ip_ranges` | API server authorized IPs | [] |
| `tenant_id` | Azure AD tenant ID | null |
| `admin_group_object_ids` | Admin group IDs | [] |

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Configure variables (optional):
```bash
# Set authorized IPs (your public IP)
export TF_VAR_authorized_ip_ranges='["YOUR_PUBLIC_IP/32"]'

# Set Azure AD configuration
export TF_VAR_tenant_id="YOUR_TENANT_ID"
export TF_VAR_admin_group_object_ids='["GROUP_OBJECT_ID"]'
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. Configure kubectl:
```bash
# Get credentials
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)

# Install kubelogin if using Azure AD
az aks install-cli

# Convert kubeconfig to use Azure AD
kubelogin convert-kubeconfig -l azurecli
```

6. Verify cluster access:
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Post-Deployment Tasks

1. **Configure Azure AD Groups**: Add users to the admin groups specified
2. **Deploy Ingress Controller**: Consider NGINX or Application Gateway
3. **Configure GitOps**: Set up Flux or ArgoCD for deployments
4. **Set up Monitoring Dashboards**: Configure Azure Monitor workbooks
5. **Configure Backup**: Set up Velero or Azure Backup

## Cost Estimation

Monthly costs (approximate):
- AKS management plane: Free
- Node pool (2-5 D4s_v3 VMs): $280-700
- Log Analytics: $50-100 (depending on data)
- Load Balancer + IPs: $25
- Total: ~$355-825 USD (varies by region and usage)

## Security Considerations

- API server has public endpoint (configure authorized IPs)
- Workload identity reduces need for service principal credentials
- Network policies should be configured for pod-to-pod traffic
- Consider private cluster for enhanced security
- Regular security scanning with Azure Defender

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Remove local kubeconfig context
kubectl config delete-context aks-complete-*
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
