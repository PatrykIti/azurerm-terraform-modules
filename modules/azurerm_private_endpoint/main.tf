resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id

  custom_network_interface_name = var.custom_network_interface_name

  dynamic "private_service_connection" {
    for_each = { for private_service_connection in var.private_service_connections : private_service_connection.name => private_service_connection }

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
    for_each = { for ip_configuration in var.ip_configurations : ip_configuration.name => ip_configuration }

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, null)
      member_name        = try(ip_configuration.value.member_name, null)
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = { for private_dns_zone_group in var.private_dns_zone_groups : private_dns_zone_group.name => private_dns_zone_group }

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
}
