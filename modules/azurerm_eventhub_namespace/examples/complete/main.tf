# Complete Event Hub Namespace Example

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

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ehns-complete"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "eventhub" {
  name                 = "snet-ehns"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.EventHub"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ehns-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "eventhub_namespace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub_namespace?ref=EHNSv1.0.0"

  name                = var.namespace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku                           = var.sku
  capacity                      = 2
  auto_inflate_enabled          = true
  maximum_throughput_units      = 4
  public_network_access_enabled = true
  local_authentication_enabled  = true
  minimum_tls_version           = "1.2"

  network_rule_set = {
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true
    ip_rules = [
      {
        ip_mask = "203.0.113.0/24"
      }
    ]
    vnet_rules = [
      {
        subnet_id = azurerm_subnet.eventhub.id
      }
    ]
  }

  namespace_authorization_rules = [
    {
      name = "send-only"
      send = true
    },
    {
      name   = "listen-only"
      listen = true
    },
    {
      name   = "manage-all"
      manage = true
      listen = true
      send   = true
    }
  ]

  schema_groups = [
    {
      name                 = "schemas-default"
      schema_type          = "Avro"
      schema_compatibility = "Backward"
    }
  ]

  diagnostic_settings = [
    {
      name                       = "diag-logs"
      log_categories             = ["OperationalLogs"]
      metric_categories          = ["AllMetrics"]
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
