# Import existing AKS into the module (Terraform import blocks)

This guide shows, step-by-step, how to import an existing AKS cluster into
`modules/azurerm_kubernetes_cluster` using Terraform **import blocks**.

The flow is based on the **basic example** from the module README and keeps
only the **module block** (no extra Terraform resources in the config).

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You already know the **AKS name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and copy the **module block** from the basic example.
Replace values with your **existing** AKS settings.

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.0"

  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location

  dns_config = {
    dns_prefix = var.dns_prefix
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = var.default_node_vm_size
    node_count     = var.default_node_count
    vnet_subnet_id = var.vnet_subnet_id
  }

  network_profile = {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  tags = var.tags
}
```

Create `terraform.tfvars` with **real values** from your AKS:

```hcl
cluster_name       = "aks-prod"
resource_group_name = "rg-aks-prod"
location           = "westeurope"

dns_prefix = "aks-prod"

vnet_subnet_id     = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"

default_node_vm_size = "Standard_D2s_v3"
default_node_count   = 2

network_plugin = "azure"
network_policy = "azure"
service_cidr   = "172.16.0.0/16"
dns_service_ip = "172.16.0.10"

tags = {
  Environment = "Prod"
  ManagedBy   = "Terraform"
}
```

### Where to get values (Azure CLI)

```bash
# AKS basics
az aks show -g <rg> -n <aks> --query '{name:name,location:location,dnsPrefix:dnsPrefix}' -o table

# Default node pool details
az aks nodepool show -g <rg> --cluster-name <aks> -n <pool> \
  --query '{vmSize:vmSize,nodeCount:count,vnetSubnetId:vnetSubnetId}' -o table

# Network profile
az aks show -g <rg> -n <aks> \
  --query '{networkPlugin:networkProfile.networkPlugin,networkPolicy:networkProfile.networkPolicy,serviceCidr:networkProfile.serviceCidr,dnsServiceIp:networkProfile.dnsServiceIp}' -o table
```

---

## 2) Add the import block

Create `import.tf` with a single import block for the module:

```hcl
import {
  to = module.kubernetes_cluster.azurerm_kubernetes_cluster.kubernetes_cluster
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<aks_name>"
}
```

To get the **exact ID**:

```bash
az aks show -g <rg> -n <aks> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the AKS resource
- **no other changes**

If you see **changes** (not only import), fix your inputs in `terraform.tfvars`
and re-run `plan`.

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg kubernetes_cluster
```

If the plan is clean, you can **remove the import block** (`import.tf`).

---

## Notes / common pitfalls

- Import blocks run **only on apply**. `plan` alone does not import.
- Values **must match** the existing AKS config.
- This guide covers **only the main AKS resource** (module block).
  If you want to manage:
  - **additional node pools**
  - **extensions**
  - **diagnostic settings**
  you must add those inputs and import blocks separately.
