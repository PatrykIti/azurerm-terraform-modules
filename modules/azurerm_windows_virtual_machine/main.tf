locals {
  patch_mode            = var.patching.patch_mode
  patch_assessment_mode = var.patching.patch_assessment_mode
  reboot_setting        = var.patching.reboot_setting
  winrm_listeners       = try(var.windows_profile.winrm_listeners, [])
  unattend_content      = try(var.windows_profile.additional_unattend_content, [])
}

resource "azurerm_windows_virtual_machine" "windows_virtual_machine" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = var.network_interface_ids

  computer_name = try(var.windows_profile.computer_name, null)
  timezone      = try(var.windows_profile.timezone, null)
  custom_data   = var.custom_data
  user_data     = var.user_data

  source_image_id = var.source_image_id

  dynamic "source_image_reference" {
    for_each = var.source_image_reference != null ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      publisher = plan.value.publisher
      product   = plan.value.product
      name      = plan.value.name
    }
  }

  os_disk {
    name                         = var.os_disk.name
    caching                      = var.os_disk.caching
    storage_account_type         = var.os_disk.storage_account_type
    disk_size_gb                 = var.os_disk.disk_size_gb
    write_accelerator_enabled    = var.os_disk.write_accelerator_enabled
    disk_encryption_set_id       = var.os_disk.disk_encryption_set_id
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type     = var.os_disk.security_encryption_type

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

  availability_set_id          = var.availability_set_id
  zone                         = var.zone
  proximity_placement_group_id = var.proximity_placement_group_id
  dedicated_host_id            = var.dedicated_host_id
  dedicated_host_group_id      = var.dedicated_host_group_id
  capacity_reservation_group_id = var.capacity_reservation_group_id
  platform_fault_domain        = var.platform_fault_domain
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id

  secure_boot_enabled        = try(var.security_profile.secure_boot_enabled, null)
  vtpm_enabled               = try(var.security_profile.vtpm_enabled, null)
  encryption_at_host_enabled = try(var.security_profile.encryption_at_host_enabled, null)

  priority       = var.spot.priority
  eviction_policy = var.spot.eviction_policy
  max_bid_price  = var.spot.max_bid_price

  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities != null ? [var.additional_capabilities] : []
    content {
      ultra_ssd_enabled   = additional_capabilities.value.ultra_ssd_enabled
      hibernation_enabled = additional_capabilities.value.hibernation_enabled
    }
  }

  provision_vm_agent             = var.vm_agent.provision_vm_agent
  allow_extension_operations     = var.vm_agent.allow_extension_operations
  extensions_time_budget         = var.vm_agent.extensions_time_budget
  vm_agent_platform_updates_enabled = var.vm_agent.vm_agent_platform_updates_enabled

  patch_mode            = local.patch_mode
  patch_assessment_mode = local.patch_assessment_mode
  reboot_setting        = local.reboot_setting
  hotpatching_enabled   = var.patching.hotpatching_enabled
  automatic_updates_enabled = var.patching.automatic_updates_enabled
  enable_automatic_updates   = var.patching.enable_automatic_updates
  bypass_platform_safety_checks_on_user_schedule_enabled = var.patching.bypass_platform_safety_checks_on_user_schedule_enabled

  license_type        = var.license_type
  edge_zone           = var.edge_zone
  disk_controller_type = var.disk_controller_type
  os_managed_disk_id  = var.os_managed_disk_id

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
    for_each = local.winrm_listeners
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }

  dynamic "additional_unattend_content" {
    for_each = local.unattend_content
    content {
      setting = additional_unattend_content.value.setting
      content = additional_unattend_content.value.content
    }
  }

  dynamic "gallery_application" {
    for_each = var.gallery_applications
    content {
      version_id                                = gallery_application.value.version_id
      automatic_upgrade_enabled                 = gallery_application.value.automatic_upgrade_enabled
      configuration_blob_uri                    = gallery_application.value.configuration_blob_uri
      order                                     = gallery_application.value.order
      tag                                       = gallery_application.value.tag
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

  lifecycle {
    precondition {
      condition     = var.admin_password != null && var.admin_password != ""
      error_message = "admin_password must be provided for Windows Virtual Machines."
    }

    precondition {
      condition     = (var.source_image_reference != null) != (var.source_image_id != null)
      error_message = "Exactly one of source_image_reference or source_image_id must be set."
    }

    precondition {
      condition     = var.availability_set_id == null || var.zone == null
      error_message = "availability_set_id cannot be combined with zone."
    }

    precondition {
      condition     = var.dedicated_host_id == null || var.dedicated_host_group_id == null
      error_message = "dedicated_host_id and dedicated_host_group_id are mutually exclusive."
    }

    precondition {
      condition     = var.spot.priority != "Spot" || var.spot.eviction_policy != null
      error_message = "spot.eviction_policy is required when spot.priority is Spot."
    }

    precondition {
      condition     = var.spot.priority == "Spot" || (var.spot.eviction_policy == null && var.spot.max_bid_price == null)
      error_message = "spot.eviction_policy and max_bid_price can only be set when spot.priority is Spot."
    }

    precondition {
      condition     = local.patch_mode != "AutomaticByPlatform" || var.vm_agent.provision_vm_agent
      error_message = "patching.patch_mode = AutomaticByPlatform requires vm_agent.provision_vm_agent = true."
    }

    precondition {
      condition     = local.patch_assessment_mode != "AutomaticByPlatform" || var.vm_agent.provision_vm_agent
      error_message = "patching.patch_assessment_mode = AutomaticByPlatform requires vm_agent.provision_vm_agent = true."
    }

    precondition {
      condition     = local.reboot_setting == null || local.patch_mode == "AutomaticByPlatform"
      error_message = "patching.reboot_setting can only be set when patching.patch_mode is AutomaticByPlatform."
    }

    precondition {
      condition     = var.vm_agent.provision_vm_agent || var.vm_agent.allow_extension_operations == false
      error_message = "allow_extension_operations must be false when provision_vm_agent is false."
    }

    precondition {
      condition     = var.os_disk.write_accelerator_enabled == false || (var.os_disk.storage_account_type == "Premium_LRS" && var.os_disk.caching == "None")
      error_message = "os_disk.write_accelerator_enabled requires storage_account_type = Premium_LRS and caching = None."
    }

    precondition {
      condition     = var.os_disk.security_encryption_type == null || try(var.security_profile.vtpm_enabled, false) == true
      error_message = "os_disk.security_encryption_type requires security_profile.vtpm_enabled = true."
    }

    precondition {
      condition = (
        (var.os_disk.disk_encryption_set_id == null && var.os_disk.secure_vm_disk_encryption_set_id == null) ||
        (var.identity != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type))
      )
      error_message = "Disk encryption set IDs require identity.type to include UserAssigned."
    }

    precondition {
      condition     = var.patching.hotpatching_enabled != true || (local.patch_mode == "AutomaticByPlatform" && var.vm_agent.provision_vm_agent)
      error_message = "hotpatching_enabled requires patching.patch_mode = AutomaticByPlatform and vm_agent.provision_vm_agent = true."
    }

    precondition {
      condition     = !(var.patching.automatic_updates_enabled != null && var.patching.enable_automatic_updates != null)
      error_message = "automatic_updates_enabled and enable_automatic_updates cannot both be set."
    }
  }
}
