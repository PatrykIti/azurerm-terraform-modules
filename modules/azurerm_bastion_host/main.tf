locals {
  sku_supports_standard_features = contains(["Standard", "Premium"], var.sku)
  sku_is_premium                 = var.sku == "Premium"
  sku_is_developer               = var.sku == "Developer"
}

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

  lifecycle {
    precondition {
      condition     = local.sku_is_developer ? length(var.ip_configuration) == 0 : length(var.ip_configuration) == 1
      error_message = "ip_configuration must be set to exactly one entry for Basic/Standard/Premium SKUs and must be omitted for Developer."
    }

    precondition {
      condition     = !local.sku_is_developer || (var.virtual_network_id != null && var.virtual_network_id != "")
      error_message = "virtual_network_id is required when sku is Developer."
    }

    precondition {
      condition     = local.sku_is_developer || var.virtual_network_id == null || var.virtual_network_id == ""
      error_message = "virtual_network_id is only supported with the Developer SKU."
    }

    precondition {
      condition = local.sku_supports_standard_features || (
        !var.file_copy_enabled &&
        !var.ip_connect_enabled &&
        !var.kerberos_enabled &&
        !var.shareable_link_enabled &&
        !var.tunneling_enabled
      )
      error_message = "file_copy_enabled, ip_connect_enabled, kerberos_enabled, shareable_link_enabled, and tunneling_enabled require Standard or Premium SKU."
    }

    precondition {
      condition     = !var.session_recording_enabled || local.sku_is_premium
      error_message = "session_recording_enabled requires the Premium SKU."
    }

    precondition {
      condition     = var.scale_units == null || local.sku_supports_standard_features
      error_message = "scale_units can only be set when sku is Standard or Premium."
    }
  }
}
