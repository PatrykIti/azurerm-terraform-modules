# Complete fixture for kubernetes role

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

resource "azurerm_resource_group" "test" {
  name     = "rg-krole-com-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-krole-com-${var.random_suffix}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.11.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "snet-krole-com-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.11.1.0/24"]
}

module "kubernetes_cluster" {
  source = "../../../../azurerm_kubernetes_cluster"

  name                = "krole-com-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  dns_config = {
    dns_prefix = "krole-com-${var.random_suffix}"
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2_v4"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.test.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.20.0.0/16"
    dns_service_ip = "172.20.0.10"
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
    name = "intent-resolver"
  }

  depends_on = [module.kubernetes_cluster]
}

module "kubernetes_role" {
  source = "../../.."

  name      = "intent-resolver-read-portforward"
  namespace = kubernetes_namespace_v1.app.metadata[0].name

  rules = [
    {
      api_groups = [""]
      resources  = ["pods", "services", "endpoints"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups     = [""]
      resources      = ["pods/portforward"]
      verbs          = ["create"]
      resource_names = ["intent-resolver-api"]
    }
  ]

  depends_on = [kubernetes_namespace_v1.app]
}
