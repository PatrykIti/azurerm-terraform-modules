locals {
  network_interface_ids_effective = var.network.primary_network_interface_id == null ? var.network.network_interface_ids : concat(
    [var.network.primary_network_interface_id],
    [for id in var.network.network_interface_ids : id if id != var.network.primary_network_interface_id]
  )

  data_disks_by_name = { for disk in var.data_disks : disk.name => disk }
}

resource "azurerm_windows_virtual_machine" "windows_virtual_machine" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size

  admin_username = var.admin.username
  admin_password = var.admin.password

  network_interface_ids = local.network_interface_ids_effective

  computer_name = try(var.windows_profile.computer_name, null)
  timezone      = try(var.windows_profile.timezone, null)
  custom_data   = var.custom_data
  user_data     = var.user_data

  source_image_id = var.image.source_image_id

  dynamic "source_image_reference" {
    for_each = var.image.source_image_reference != null ? [var.image.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  dynamic "plan" {
    for_each = var.image.plan != null ? [var.image.plan] : []
    content {
      publisher = plan.value.publisher
      product   = plan.value.product
      name      = plan.value.name
    }
  }

  os_disk {
    name                             = var.os_disk.name
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_size_gb                     = var.os_disk.disk_size_gb
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings != null ? [var.os_disk.diff_disk_settings] : []
      content {
        option    = diff_disk_settings.value.option
        placement = diff_disk_settings.value.placement
      }
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null && var.boot_diagnostics.enabled ? [var.boot_diagnostics] : []
    content {
      storage_account_uri = boot_diagnostics.value.storage_account_uri
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  availability_set_id           = var.placement.availability_set_id
  zone                          = var.placement.zone
  proximity_placement_group_id  = var.placement.proximity_placement_group_id
  dedicated_host_id             = var.placement.dedicated_host_id
  dedicated_host_group_id       = var.placement.dedicated_host_group_id
  capacity_reservation_group_id = var.placement.capacity_reservation_group_id
  platform_fault_domain         = var.placement.platform_fault_domain
  virtual_machine_scale_set_id  = var.placement.virtual_machine_scale_set_id

  secure_boot_enabled        = try(var.security_profile.secure_boot_enabled, null)
  vtpm_enabled               = try(var.security_profile.vtpm_enabled, null)
  encryption_at_host_enabled = try(var.security_profile.encryption_at_host_enabled, null)

  priority        = var.spot.priority
  eviction_policy = var.spot.eviction_policy
  max_bid_price   = var.spot.max_bid_price

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities != null ? [var.additional_capabilities] : []
    content {
      ultra_ssd_enabled   = additional_capabilities.value.ultra_ssd_enabled
      hibernation_enabled = additional_capabilities.value.hibernation_enabled
    }
  }

  provision_vm_agent         = var.vm_agent.provision_vm_agent
  allow_extension_operations = var.vm_agent.allow_extension_operations
  extensions_time_budget     = var.vm_agent.extensions_time_budget

  patch_mode                                             = var.patching.patch_mode
  patch_assessment_mode                                  = var.patching.patch_assessment_mode
  reboot_setting                                         = var.patching.reboot_setting
  hotpatching_enabled                                    = var.patching.hotpatching_enabled
  automatic_updates_enabled                              = var.patching.automatic_updates_enabled
  bypass_platform_safety_checks_on_user_schedule_enabled = var.patching.bypass_platform_safety_checks_on_user_schedule_enabled

  license_type         = var.license_type
  edge_zone            = var.edge_zone
  disk_controller_type = var.disk_controller_type
  os_managed_disk_id   = var.os_managed_disk_id

  dynamic "os_image_notification" {
    for_each = var.os_image_notification != null ? [var.os_image_notification] : []
    content {
      timeout = os_image_notification.value.timeout
    }
  }

  dynamic "termination_notification" {
    for_each = var.termination_notification != null ? [var.termination_notification] : []
    content {
      enabled = termination_notification.value.enabled
      timeout = termination_notification.value.timeout
    }
  }

  dynamic "winrm_listener" {
    for_each = try(var.windows_profile.winrm_listeners, [])
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }

  dynamic "additional_unattend_content" {
    for_each = try(var.windows_profile.additional_unattend_content, [])
    content {
      setting = additional_unattend_content.value.setting
      content = additional_unattend_content.value.content
    }
  }

  dynamic "gallery_application" {
    for_each = var.gallery_applications
    content {
      version_id                                  = gallery_application.value.version_id
      automatic_upgrade_enabled                   = gallery_application.value.automatic_upgrade_enabled
      configuration_blob_uri                      = gallery_application.value.configuration_blob_uri
      order                                       = gallery_application.value.order
      tag                                         = gallery_application.value.tag
      treat_failure_as_deployment_failure_enabled = gallery_application.value.treat_failure_as_deployment_failure_enabled
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      key_vault_id = secret.value.key_vault_id

      dynamic "certificate" {
        for_each = secret.value.certificates
        content {
          store = certificate.value.store
          url   = certificate.value.url
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = length([for v in [var.timeouts.create, var.timeouts.update, var.timeouts.delete, var.timeouts.read] : v if v != null]) > 0 ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }

  tags = var.tags
}

resource "azurerm_managed_disk" "managed_disk" {
  for_each = local.data_disks_by_name

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  create_option          = "Empty"
  storage_account_type   = each.value.storage_account_type
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = each.value.disk_encryption_set_id
  zone                   = var.placement.zone

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_data_disk_attachment" {
  for_each = local.data_disks_by_name

  managed_disk_id           = azurerm_managed_disk.managed_disk[each.key].id
  virtual_machine_id        = azurerm_windows_virtual_machine.windows_virtual_machine.id
  lun                       = each.value.lun
  caching                   = each.value.caching
  write_accelerator_enabled = each.value.write_accelerator_enabled
}

resource "azurerm_virtual_machine_extension" "virtual_machine_extension" {
  for_each = { for extension in var.extensions : extension.name => extension }

  name                 = each.value.name
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_virtual_machine.id
  publisher            = each.value.publisher
  type                 = each.value.type
  type_handler_version = each.value.type_handler_version

  auto_upgrade_minor_version  = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled   = each.value.automatic_upgrade_enabled
  failure_suppression_enabled = each.value.failure_suppression_enabled
  provision_after_extensions  = each.value.provision_after_extensions

  settings           = each.value.settings != null ? jsonencode(each.value.settings) : null
  protected_settings = each.value.protected_settings != null ? jsonencode(each.value.protected_settings) : null

  dynamic "protected_settings_from_key_vault" {
    for_each = each.value.protected_settings_from_key_vault != null ? [each.value.protected_settings_from_key_vault] : []
    content {
      secret_url      = protected_settings_from_key_vault.value.secret_url
      source_vault_id = protected_settings_from_key_vault.value.source_vault_id
    }
  }

  tags = try(each.value.tags, null)
}

