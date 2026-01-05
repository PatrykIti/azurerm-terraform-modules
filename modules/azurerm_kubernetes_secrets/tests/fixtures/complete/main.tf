# Complete fixture for kubernetes secrets (CSI)

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
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "rg-akssec-cmp-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-akssec-cmp-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "snet-akssec-cmp-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.1.0/24"]
}

module "kubernetes_cluster" {
  source = "../../../../azurerm_kubernetes_cluster"

  name                = "akssec-cmp-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dns_config = {
    dns_prefix = "akssec-cmp-${var.random_suffix}"
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v4"
    node_count     = 2
    vnet_subnet_id = azurerm_subnet.test.id
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
    Environment = "Test"
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

  depends_on = [module.kubernetes_cluster]
}

resource "azurerm_key_vault" "test" {
  name                       = "kv-akssec-cmp-${var.random_suffix}"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  rbac_authorization_enabled = true
  sku_name                   = "standard"
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_csi" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.kubernetes_cluster.key_vault_secrets_provider.secret_identity.object_id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.test.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

module "kubernetes_secrets" {
  source = "../../.."

  strategy  = "csi"
  namespace = kubernetes_namespace_v1.app.metadata[0].name
  name      = "app-spc"

  csi = {
    tenant_id                        = module.kubernetes_cluster.identity.tenant_id
    key_vault_name                   = azurerm_key_vault.test.name
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
