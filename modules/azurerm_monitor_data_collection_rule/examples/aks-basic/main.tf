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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  container_insights_settings = jsondecode(file("${path.module}/data-collection-settings.json"))
  container_insights_streams  = local.container_insights_settings.dataCollectionSettings.streams
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=main"

  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  dns_config = {
    dns_prefix = var.dns_prefix
  }

  identity = {
    type         = "SystemAssigned"
    identity_ids = null
  }

  default_node_pool = {
    name                 = "default"
    vm_size              = "Standard_D2s_v3"
    node_count           = 2
    auto_scaling_enabled = false
    vnet_subnet_id       = azurerm_subnet.example.id
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  oms_agent = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    collection_profile         = "basic"
    namespaceFilteringMode     = "Off"
  }

  tags = {
    Environment = "Development"
    Example     = "AKS Basic"
  }
}

module "monitor_data_collection_endpoint" {
  source = "../../../azurerm_monitor_data_collection_endpoint"

  name                = var.data_collection_endpoint_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Linux"

  public_network_access_enabled = true

  tags = {
    Environment = "Development"
    Example     = "AKS Basic"
  }
}

module "monitor_data_collection_rule" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_monitor_data_collection_rule?ref=DCRv1.0.0"

  name                = var.data_collection_rule_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Linux"

  data_collection_endpoint_id = module.monitor_data_collection_endpoint.id

  destinations = {
    log_analytics = [
      {
        name                  = "log-analytics"
        workspace_resource_id = azurerm_log_analytics_workspace.example.id
      }
    ]
  }

  data_sources = {
    extension = [
      {
        name           = "container-insights"
        extension_name = "ContainerInsights"
        streams        = local.container_insights_streams
        extension_json = file("${path.module}/data-collection-settings.json")
      }
    ]
  }

  data_flows = [
    {
      streams      = local.container_insights_streams
      destinations = ["log-analytics"]
    }
  ]

  associations = [
    {
      name               = "${var.cluster_name}-dcr-assoc"
      target_resource_id = module.kubernetes_cluster.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "AKS Basic"
  }
}
