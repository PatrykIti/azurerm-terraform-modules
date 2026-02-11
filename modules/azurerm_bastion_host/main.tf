resource "azurerm_bastion_host" "bastion_host" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                       = var.sku
  scale_units               = var.scale_units
  copy_paste_enabled        = var.copy_paste_enabled
  file_copy_enabled         = var.file_copy_enabled
  ip_connect_enabled        = var.ip_connect_enabled
  kerberos_enabled          = var.kerberos_enabled
  shareable_link_enabled    = var.shareable_link_enabled
  tunneling_enabled         = var.tunneling_enabled
  session_recording_enabled = var.session_recording_enabled
  virtual_network_id        = var.virtual_network_id
  zones                     = var.zones

  dynamic "ip_configuration" {
    for_each = var.ip_configuration
    content {
      name                 = ip_configuration.value.name
      subnet_id            = ip_configuration.value.subnet_id
      public_ip_address_id = ip_configuration.value.public_ip_address_id
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
