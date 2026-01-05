# Secure AKS Secrets Example (ESO + Workload Identity + Helm)

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.2.1.0/24"]
}

module "kubernetes_cluster" {
  source = "../../../azurerm_kubernetes_cluster"

  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  dns_config = {
    dns_prefix = var.dns_prefix
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_E2s_v3"
    node_count     = 2
    vnet_subnet_id = azurerm_subnet.example.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  features = {
    workload_identity_enabled = true
    oidc_issuer_enabled       = true
  }

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.kube_config.host
  client_certificate     = base64decode(module.kubernetes_cluster.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes_cluster.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes_cluster.kube_config.host
    client_certificate     = base64decode(module.kubernetes_cluster.kube_config.client_certificate)
    client_key             = base64decode(module.kubernetes_cluster.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes_cluster.kube_config.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "app"
  }

  depends_on = [module.kubernetes_cluster]
}

resource "azurerm_key_vault" "example" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  rbac_authorization_enabled = true
  sku_name                   = "standard"
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.example.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_user_assigned_identity" "eso" {
  name                = "id-aks-secrets-eso"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_federated_identity_credential" "eso" {
  name                = "eso-fic"
  resource_group_name = azurerm_resource_group.example.name
  parent_id           = azurerm_user_assigned_identity.eso.id
  issuer              = module.kubernetes_cluster.oidc_issuer_url
  subject             = "system:serviceaccount:app:eso-sa"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "kv_eso" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.eso.principal_id
}

resource "kubernetes_service_account_v1" "eso" {
  metadata {
    name      = "eso-sa"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.eso.client_id
    }
  }
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  wait             = true
  timeout          = 600

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [module.kubernetes_cluster]
}

module "kubernetes_secrets" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_secrets?ref=AKSS1.0.0"

  strategy  = "eso"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  name      = "app-eso"

  eso = {
    secret_store = {
      kind           = "SecretStore"
      name           = "kv-store"
      tenant_id      = module.kubernetes_cluster.identity.tenant_id
      key_vault_name = azurerm_key_vault.example.name
      auth = {
        type = "workload_identity"
        workload_identity = {
          service_account_name      = kubernetes_service_account_v1.eso.metadata[0].name
          service_account_namespace = kubernetes_namespace_v1.app.metadata[0].name
          client_id                 = azurerm_user_assigned_identity.eso.client_id
        }
      }
    }
    external_secrets = [
      {
        name             = "db-secret"
        refresh_interval = "1h"
        remote_ref = {
          name    = "db-password"
          version = null
        }
        target = {
          secret_name = "app-secrets"
          secret_key  = "DB_PASSWORD"
        }
      }
    ]
  }

  depends_on = [helm_release.external_secrets, kubernetes_namespace_v1.app]
}
