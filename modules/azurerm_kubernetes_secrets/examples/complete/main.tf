# Complete AKS Secrets Example (CSI)

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
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.1.0/24"]
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
    vm_size        = "Standard_D2s_v3"
    node_count     = 2
    vnet_subnet_id = azurerm_subnet.example.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.kube_config.host
  client_certificate     = base64decode(module.kubernetes_cluster.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes_cluster.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.kube_config.cluster_ca_certificate)
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "app"
  }
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

resource "azurerm_role_assignment" "kv_csi" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.kubernetes_cluster.key_vault_secrets_provider.secret_identity.object_id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.example.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

module "kubernetes_secrets" {
  source = "../.."

  strategy  = "csi"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  name      = "app-spc"

  csi = {
    tenant_id                        = module.kubernetes_cluster.identity.tenant_id
    key_vault_name                   = azurerm_key_vault.example.name
    user_assigned_identity_client_id = module.kubernetes_cluster.key_vault_secrets_provider.secret_identity.client_id
    sync_to_kubernetes_secret        = true
    kubernetes_secret_name           = "app-secrets"
    objects = [
      {
        name        = "db-password"
        object_name = "db-password"
        object_type = "secret"
        secret_key  = "DB_PASSWORD"
      }
    ]
  }

  depends_on = [kubernetes_namespace_v1.app]
}
