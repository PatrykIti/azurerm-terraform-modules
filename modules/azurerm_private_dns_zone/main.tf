resource "azurerm_private_dns_zone" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "soa_record" {
    for_each = var.soa_record == null ? [] : [var.soa_record]
    content {
      email        = soa_record.value.email
      expire_time  = try(soa_record.value.expire_time, null)
      minimum_ttl  = try(soa_record.value.minimum_ttl, null)
      refresh_time = try(soa_record.value.refresh_time, null)
      retry_time   = try(soa_record.value.retry_time, null)
      ttl          = try(soa_record.value.ttl, null)
      tags         = try(soa_record.value.tags, null)
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
}
