# Private Endpoint Kubernetes Cluster Example

This example demonstrates a Kubernetes Cluster configuration with private endpoint connectivity for enhanced security and network isolation.

## Features

- Creates a kubernetes_cluster with private endpoint access
- Disables public network access for maximum security
- Configures virtual network and subnet for private connectivity
- Demonstrates private DNS integration
- Network isolation and secure connectivity patterns
- Enterprise-grade security configuration

## Key Configuration

This example showcases private endpoint implementation with complete network isolation, suitable for enterprise environments requiring secure connectivity without public internet exposure.

## Network Architecture

- Virtual Network with dedicated subnet for private endpoints
- Private endpoint connection to the kubernetes_cluster
- DNS resolution for private connectivity
- Network security group rules (if applicable)

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
