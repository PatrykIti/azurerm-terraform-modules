# Workload Identity AKS Cluster Example

This example demonstrates an Azure Kubernetes Service (AKS) cluster with Azure AD RBAC and Workload Identity enabled for secure, passwordless authentication.

## Features

- Azure AD RBAC enabled for cluster authentication
- Workload Identity with OIDC issuer enabled
- Demonstrates federated identity credential setup
- Example Key Vault integration with workload identity
- Local accounts disabled for enhanced security
- Cost-optimized with basic cluster configuration

## Architecture

```
Resource Group
├── Virtual Network (10.0.0.0/16)
│   └── Subnet (10.0.1.0/24)
├── AKS Cluster (with OIDC & Workload Identity)
│   └── Default Node Pool (2 nodes)
├── User Assigned Identity (for workload)
├── Federated Identity Credential
└── Key Vault (example resource)
    └── Role Assignment for Workload Identity
```

## Key Configuration

This example demonstrates:
- **Azure AD RBAC**: Cluster authentication using Azure AD groups
- **Workload Identity**: Passwordless pod authentication to Azure resources
- **OIDC Issuer**: Enabled for workload identity federation
- **Federated Credentials**: Links Kubernetes service accounts to Azure identities
- **Security First**: Local accounts disabled, Azure AD authentication only
- **Example Integration**: Key Vault access using workload identity

## Security Features

### Azure AD RBAC
- Cluster access controlled by Azure AD group membership
- No local accounts (kubectl with certificates disabled)
- Admin group automatically created and current user added

### Workload Identity
- Pods authenticate to Azure using federated identity
- No secrets or certificates stored in the cluster
- Service account annotations link to Azure identity
- OIDC tokens automatically injected into pods

## Prerequisites

- Azure subscription
- Terraform >= 1.3.0
- Azure CLI (for kubectl configuration)
- Appropriate Azure AD permissions to create groups

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

5. Set up workload identity in the cluster:
```bash
# Run the setup commands from the output
terraform output -raw workload_identity_setup_commands | bash
```

## Testing Workload Identity

After deployment, test the workload identity configuration:

1. **Check OIDC issuer URL**:
```bash
terraform output oidc_issuer_url
```

2. **Verify the test pod is running**:
```bash
kubectl get pod workload-identity-test
```

3. **Test Azure authentication inside the pod**:
```bash
# Enter the pod
kubectl exec -it workload-identity-test -- bash

# Inside the pod, test Azure CLI authentication
az login --federated-token $(cat /var/run/secrets/azure/tokens/azure-identity-token) \
  --service-principal -u <CLIENT_ID> -t <TENANT_ID>

# List Key Vault secrets (should succeed with proper permissions)
az keyvault secret list --vault-name <KEY_VAULT_NAME>
```

## Workload Identity Setup Steps

The example automatically:

1. Creates a user-assigned managed identity
2. Creates a federated identity credential linking to the AKS OIDC issuer
3. Creates a service account in Kubernetes
4. Annotates the service account with the Azure identity client ID
5. Deploys a test pod using the service account

## Cost Considerations

This example minimizes costs while demonstrating workload identity:
- Uses Standard_D2s_v3 VMs (2 nodes only)
- Free SKU tier (no SLA)
- No expensive add-ons
- Basic Key Vault SKU for demonstration

## Security Best Practices Demonstrated

1. **No passwords or keys**: Workload identity eliminates secret management
2. **Azure AD authentication**: No local cluster accounts
3. **Least privilege**: Workload identity has minimal Key Vault permissions
4. **Federated trust**: OIDC-based authentication between AKS and Azure

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Next Steps

To use workload identity in your applications:

1. Create a managed identity for each application
2. Set up federated credentials for the Kubernetes namespace/service account
3. Grant the identity necessary Azure RBAC permissions
4. Deploy pods with the appropriate service account
5. Use Azure SDKs that support workload identity authentication

## Troubleshooting

Common issues and solutions:

1. **Authentication fails**: Ensure the service account annotation matches the client ID
2. **OIDC URL not available**: Wait a few minutes after cluster creation
3. **Permission denied**: Check Azure RBAC assignments for the managed identity
4. **Token not found**: Verify the pod is using the correct service account

For more information, see the [Azure Workload Identity documentation](https://azure.github.io/azure-workload-identity/).