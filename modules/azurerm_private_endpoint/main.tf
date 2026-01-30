locals {
  private_service_connections = {
    for conn in var.private_service_connections : conn.name => conn
  }

  ip_configurations = {
    for cfg in var.ip_configurations : cfg.name => cfg
  }

  private_dns_zone_groups = {
    for group in var.private_dns_zone_groups : group.name => group
  }
}

resource "azurerm_private_endpoint" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id

  custom_network_interface_name = var.custom_network_interface_name

  dynamic "private_service_connection" {
    for_each = local.private_service_connections

    content {
      name                              = private_service_connection.value.name
      is_manual_connection              = private_service_connection.value.is_manual_connection
      private_connection_resource_id    = try(private_service_connection.value.private_connection_resource_id, null)
      private_connection_resource_alias = try(private_service_connection.value.private_connection_resource_alias, null)
      subresource_names                 = try(private_service_connection.value.subresource_names, null)
      request_message                   = try(private_service_connection.value.request_message, null)
    }
  }

  dynamic "ip_configuration" {
    for_each = local.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, null)
      member_name        = try(ip_configuration.value.member_name, null)
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zone_groups

    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = alltrue([
        for conn in var.private_service_connections :
        (try(conn.private_connection_resource_id, null) != null) != (try(conn.private_connection_resource_alias, null) != null)
      ])
      error_message = "Each private_service_connection must set exactly one of private_connection_resource_id or private_connection_resource_alias."
    }

    precondition {
      condition = alltrue([
        for conn in var.private_service_connections :
        conn.is_manual_connection == false || (try(conn.request_message, null) != null && length(trim(conn.request_message)) > 0)
      ])
      error_message = "request_message is required when is_manual_connection is true."
    }
  }
}
