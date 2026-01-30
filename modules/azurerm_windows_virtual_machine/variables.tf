# Core Windows Virtual Machine variables
variable "name" {
  description = "The name of the Windows Virtual Machine."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,62}[A-Za-z0-9])?$", var.name))
    error_message = "VM name must be 1-64 characters, alphanumeric or hyphen, and cannot start or end with a hyphen."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Windows Virtual Machine."
  type        = string
}

variable "location" {
  description = "The Azure region where the Windows Virtual Machine should exist."
  type        = string
}

variable "size" {
  description = "The size of the Windows Virtual Machine (SKU)."
  type        = string
}

# Networking
variable "network_interface_ids" {
  description = "A list of Network Interface IDs to attach to the VM. The first is used as primary."
  type        = list(string)

  validation {
    condition     = length(var.network_interface_ids) > 0
    error_message = "At least one network_interface_id must be provided."
  }
}

# Admin/authentication
variable "admin_username" {
  description = "The admin username for the Windows Virtual Machine."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_-]{0,19}$", var.admin_username))
    error_message = "admin_username must be 1-20 characters and contain only letters, numbers, hyphens, or underscores."
  }

  validation {
    condition     = !contains(["administrator", "admin", "root", "guest", "user", "user1", "test"], lower(var.admin_username))
    error_message = "admin_username uses a reserved value. Choose a different username."
  }
}

variable "admin_password" {
  description = "The admin password for the Windows Virtual Machine."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12 && length(var.admin_password) <= 123
    error_message = "admin_password must be between 12 and 123 characters."
  }

  validation {
    condition = (
      (can(regex("[A-Z]", var.admin_password)) ? 1 : 0) +
      (can(regex("[a-z]", var.admin_password)) ? 1 : 0) +
      (can(regex("[0-9]", var.admin_password)) ? 1 : 0) +
      (can(regex("[^A-Za-z0-9]", var.admin_password)) ? 1 : 0)
    ) >= 3
    error_message = "admin_password must include at least three of: uppercase, lowercase, number, and special character."
  }
}

# Windows profile
variable "windows_profile" {
  description = <<-EOT
    Windows profile settings.

    computer_name: Optional Windows computer name (1-15 chars, alphanumeric or hyphen).
    timezone: Windows time zone string (e.g., UTC, Pacific Standard Time).
    winrm_listeners: WinRM listeners (protocol Http/Https; Https requires certificate_url).
    additional_unattend_content: Unattend content blocks (AutoLogon or FirstLogonCommands).
  EOT
  type = object({
    computer_name = optional(string)
    timezone      = optional(string)
    winrm_listeners = optional(list(object({
      protocol        = string
      certificate_url = optional(string)
    })), [])
    additional_unattend_content = optional(list(object({
      setting = string
      content = string
    })), [])
  })
  default = {}

  validation {
    condition = (
      var.windows_profile.computer_name == null ||
      can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,13}[A-Za-z0-9])?$", var.windows_profile.computer_name))
    )
    error_message = "windows_profile.computer_name must be 1-15 characters, alphanumeric or hyphen, and cannot start or end with a hyphen."
  }

  validation {
    condition = alltrue([
      for listener in var.windows_profile.winrm_listeners :
      contains(["Http", "Https"], listener.protocol)
    ])
    error_message = "windows_profile.winrm_listeners.protocol must be Http or Https."
  }

  validation {
    condition = alltrue([
      for listener in var.windows_profile.winrm_listeners :
      listener.protocol != "Https" || (listener.certificate_url != null && listener.certificate_url != "")
    ])
    error_message = "windows_profile.winrm_listeners.certificate_url is required when protocol is Https."
  }

  validation {
    condition = alltrue([
      for entry in var.windows_profile.additional_unattend_content :
      contains(["AutoLogon", "FirstLogonCommands"], entry.setting)
    ])
    error_message = "windows_profile.additional_unattend_content.setting must be AutoLogon or FirstLogonCommands."
  }
}

# Image settings
variable "source_image_reference" {
  description = "The source image reference for the VM. Mutually exclusive with source_image_id."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null

  validation {
    condition     = (var.source_image_reference != null) != (var.source_image_id != null)
    error_message = "Exactly one of source_image_reference or source_image_id must be set."
  }
}

variable "source_image_id" {
  description = "The source image ID for the VM. Mutually exclusive with source_image_reference."
  type        = string
  default     = null
}

variable "plan" {
  description = "Purchase plan for marketplace images."
  type = object({
    publisher = string
    product   = string
    name      = string
  })
  default = null
}

# OS disk
variable "os_disk" {
  description = <<-EOT
    OS disk configuration.

    caching: None, ReadOnly, ReadWrite
    storage_account_type: Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, UltraSSD_LRS
  EOT
  type = object({
    name                         = optional(string)
    caching                      = string
    storage_account_type         = string
    disk_size_gb                 = optional(number)
    write_accelerator_enabled    = optional(bool, false)
    disk_encryption_set_id       = optional(string)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type     = optional(string)
    diff_disk_settings = optional(object({
      option    = string
      placement = optional(string)
    }))
  })

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk.caching)
    error_message = "os_disk.caching must be one of: None, ReadOnly, ReadWrite."
  }

  validation {
    condition = contains([
      "Standard_LRS",
      "StandardSSD_LRS",
      "StandardSSD_ZRS",
      "Premium_LRS",
      "PremiumV2_LRS",
      "Premium_ZRS",
      "UltraSSD_LRS",
    ], var.os_disk.storage_account_type)
    error_message = "os_disk.storage_account_type must be a valid managed disk SKU."
  }

  validation {
    condition     = var.os_disk.security_encryption_type == null || contains(["VMGuestStateOnly", "DiskWithVMGuestState"], var.os_disk.security_encryption_type)
    error_message = "os_disk.security_encryption_type must be VMGuestStateOnly or DiskWithVMGuestState."
  }

  validation {
    condition     = var.os_disk.diff_disk_settings == null || contains(["Local"], var.os_disk.diff_disk_settings.option)
    error_message = "os_disk.diff_disk_settings.option must be Local when specified."
  }

  validation {
    condition = var.os_disk.diff_disk_settings == null || var.os_disk.diff_disk_settings.placement == null || contains(["CacheDisk", "ResourceDisk", "NvmeDisk"], var.os_disk.diff_disk_settings.placement)
    error_message = "os_disk.diff_disk_settings.placement must be CacheDisk, ResourceDisk, or NvmeDisk when specified."
  }
}

# Data disks (managed disks + attachments)
variable "data_disks" {
  description = <<-EOT
    Data disks attached to the VM. Each entry must have a unique name and LUN.

    caching: None, ReadOnly, ReadWrite
    storage_account_type: Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, UltraSSD_LRS
  EOT
  type = list(object({
    name                      = string
    lun                       = number
    caching                   = string
    disk_size_gb              = number
    storage_account_type      = string
    write_accelerator_enabled = optional(bool, false)
    disk_encryption_set_id    = optional(string)
  }))
  default = []

  validation {
    condition     = length(distinct([for disk in var.data_disks : disk.name])) == length(var.data_disks)
    error_message = "Each data_disk must have a unique name."
  }

  validation {
    condition     = length(distinct([for disk in var.data_disks : disk.lun])) == length(var.data_disks)
    error_message = "Each data_disk must have a unique LUN."
  }

  validation {
    condition = alltrue([
      for disk in var.data_disks :
      contains(["None", "ReadOnly", "ReadWrite"], disk.caching)
    ])
    error_message = "data_disks.caching must be one of: None, ReadOnly, ReadWrite."
  }

  validation {
    condition = alltrue([
      for disk in var.data_disks :
      contains([
        "Standard_LRS",
        "StandardSSD_LRS",
        "StandardSSD_ZRS",
        "Premium_LRS",
        "PremiumV2_LRS",
        "Premium_ZRS",
        "UltraSSD_LRS",
      ], disk.storage_account_type)
    ])
    error_message = "data_disks.storage_account_type must be a valid managed disk SKU."
  }

  validation {
    condition = alltrue([
      for disk in var.data_disks :
      disk.write_accelerator_enabled == false || (disk.storage_account_type == "Premium_LRS" && disk.caching == "None")
    ])
    error_message = "data_disks.write_accelerator_enabled requires storage_account_type = Premium_LRS and caching = None."
  }

  validation {
    condition = alltrue([
      for disk in var.data_disks :
      disk.storage_account_type != "UltraSSD_LRS" || (var.additional_capabilities != null && var.additional_capabilities.ultra_ssd_enabled == true)
    ])
    error_message = "UltraSSD_LRS data disks require additional_capabilities.ultra_ssd_enabled = true."
  }
}

# Boot diagnostics
variable "boot_diagnostics" {
  description = "Boot diagnostics configuration. When enabled, storage_account_uri may be null to use managed storage."
  type = object({
    enabled             = optional(bool, true)
    storage_account_uri = optional(string)
  })
  default = null
}

# Identity
variable "identity" {
  description = "Managed identity configuration for the VM."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.identity == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned",
    ], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || length(var.identity.identity_ids) > 0
    error_message = "identity.identity_ids must be provided when identity.type includes UserAssigned."
  }
}

# Availability/host settings
variable "zone" {
  description = "The Availability Zone in which the VM should be created."
  type        = string
  default     = null
}

variable "availability_set_id" {
  description = "The ID of the Availability Set to place the VM in."
  type        = string
  default     = null

  validation {
    condition     = var.availability_set_id == null || var.zone == null
    error_message = "availability_set_id cannot be combined with zone."
  }
}

variable "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group to associate with the VM."
  type        = string
  default     = null
}

variable "dedicated_host_id" {
  description = "The ID of the Dedicated Host on which to provision the VM."
  type        = string
  default     = null

  validation {
    condition     = var.dedicated_host_id == null || var.dedicated_host_group_id == null
    error_message = "dedicated_host_id and dedicated_host_group_id are mutually exclusive."
  }
}

variable "dedicated_host_group_id" {
  description = "The ID of the Dedicated Host Group on which to provision the VM."
  type        = string
  default     = null
}

variable "capacity_reservation_group_id" {
  description = "The ID of the Capacity Reservation Group to use for the VM."
  type        = string
  default     = null
}

variable "platform_fault_domain" {
  description = "The platform fault domain in which the VM should be created."
  type        = number
  default     = null
}

variable "virtual_machine_scale_set_id" {
  description = "The ID of an orchestrated virtual machine scale set to place this VM in."
  type        = string
  default     = null
}

# Security profile
variable "security_profile" {
  description = "Security profile settings for the VM."
  type = object({
    secure_boot_enabled        = optional(bool)
    vtpm_enabled               = optional(bool)
    encryption_at_host_enabled = optional(bool)
  })
  default = null
}

# Spot/priority
variable "spot" {
  description = "Spot/priority configuration."
  type = object({
    priority        = optional(string, "Regular")
    eviction_policy = optional(string)
    max_bid_price   = optional(number)
  })
  default = {}

  validation {
    condition     = contains(["Regular", "Spot"], var.spot.priority)
    error_message = "spot.priority must be Regular or Spot."
  }

  validation {
    condition     = var.spot.eviction_policy == null || contains(["Deallocate", "Delete"], var.spot.eviction_policy)
    error_message = "spot.eviction_policy must be Deallocate or Delete."
  }
}

# Additional capabilities
variable "additional_capabilities" {
  description = "Additional capabilities for the VM."
  type = object({
    ultra_ssd_enabled   = optional(bool)
    hibernation_enabled = optional(bool)
  })
  default = null
}

# VM agent
variable "vm_agent" {
  description = "VM agent configuration."
  type = object({
    provision_vm_agent            = optional(bool, true)
    allow_extension_operations    = optional(bool, true)
    extensions_time_budget        = optional(string)
    vm_agent_platform_updates_enabled = optional(bool)
  })
  default = {}
}

# Guest patching
variable "patching" {
  description = "Guest patching configuration."
  type = object({
    patch_mode            = optional(string, "AutomaticByOS")
    patch_assessment_mode = optional(string, "ImageDefault")
    reboot_setting        = optional(string)
    hotpatching_enabled   = optional(bool)
    automatic_updates_enabled = optional(bool)
    enable_automatic_updates  = optional(bool)
    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool)
  })
  default = {}

  validation {
    condition     = contains(["Manual", "AutomaticByOS", "AutomaticByPlatform"], var.patching.patch_mode)
    error_message = "patching.patch_mode must be Manual, AutomaticByOS, or AutomaticByPlatform."
  }

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patching.patch_assessment_mode)
    error_message = "patching.patch_assessment_mode must be AutomaticByPlatform or ImageDefault."
  }

  validation {
    condition     = var.patching.reboot_setting == null || contains(["Always", "IfRequired", "Never"], var.patching.reboot_setting)
    error_message = "patching.reboot_setting must be Always, IfRequired, or Never."
  }

  validation {
    condition     = !(var.patching.automatic_updates_enabled != null && var.patching.enable_automatic_updates != null)
    error_message = "automatic_updates_enabled and enable_automatic_updates cannot both be set."
  }
}

# Additional VM configuration
variable "license_type" {
  description = "Specifies the type of on-premise license for the VM (Azure Hybrid Use Benefit)."
  type        = string
  default     = null

  validation {
    condition     = var.license_type == null || contains(["None", "Windows_Client", "Windows_Server"], var.license_type)
    error_message = "license_type must be one of: None, Windows_Client, Windows_Server."
  }
}

variable "edge_zone" {
  description = "The Edge Zone within the Azure Region where this VM should exist."
  type        = string
  default     = null
}

variable "disk_controller_type" {
  description = "Specifies the disk controller type for the VM."
  type        = string
  default     = null
}

variable "os_managed_disk_id" {
  description = "The ID of an existing managed OS disk to use for the VM."
  type        = string
  default     = null
}

variable "custom_data" {
  description = "Base64-encoded custom data for the VM."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_data" {
  description = "Base64-encoded user data for the VM."
  type        = string
  default     = null
}

variable "os_image_notification" {
  description = "OS image notification configuration."
  type = object({
    timeout = optional(string)
  })
  default = null
}

variable "termination_notification" {
  description = "Termination notification configuration."
  type = object({
    enabled = bool
    timeout = optional(string)
  })
  default = null
}

variable "gallery_applications" {
  description = "Gallery applications to install on the VM."
  type = list(object({
    version_id                               = string
    automatic_upgrade_enabled                 = optional(bool)
    configuration_blob_uri                   = optional(string)
    order                                    = optional(number)
    tag                                      = optional(string)
    treat_failure_as_deployment_failure_enabled = optional(bool)
  }))
  default = []
}

variable "secrets" {
  description = "Key Vault secrets (certificates) to inject into the VM."
  type = list(object({
    key_vault_id = string
    certificates = list(object({
      store = string
      url   = string
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for secret in var.secrets : length(secret.certificates) > 0
    ])
    error_message = "Each secret entry must include at least one certificate."
  }
}

# Extensions
variable "extensions" {
  description = "Virtual machine extensions to deploy."
  type = list(object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    settings                    = optional(any)
    protected_settings          = optional(any)
    auto_upgrade_minor_version  = optional(bool)
    automatic_upgrade_enabled   = optional(bool)
    failure_suppression_enabled = optional(bool)
    force_update_tag            = optional(string)
    provision_after_extensions  = optional(list(string), [])
    protected_settings_from_key_vault = optional(object({
      secret_url     = string
      source_vault_id = string
    }))
    tags = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length(distinct([for ext in var.extensions : ext.name])) == length(var.extensions)
    error_message = "Each extension must have a unique name."
  }
}

# Diagnostic settings
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings configuration for the VM.

    Provide explicit log_categories and/or metric_categories, or use areas to map to
    available diagnostic categories. Areas support: logs, metrics, all.
  EOT
  type = list(object({
    name                           = string
    areas                          = optional(list(string))
    log_categories                 = optional(list(string))
    log_category_groups            = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per VM resource."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic setting entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic setting must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.eventhub_authorization_rule_id == null || (ds.eventhub_name != null && ds.eventhub_name != "")
    ])
    error_message = "eventhub_name is required when eventhub_authorization_rule_id is set."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([for c in(ds.log_categories == null ? [] : ds.log_categories) : c != ""]) &&
      alltrue([for c in(ds.metric_categories == null ? [] : ds.metric_categories) : c != ""]) &&
      alltrue([for c in(ds.log_category_groups == null ? [] : ds.log_category_groups) : c != ""]) &&
      alltrue([for c in(ds.areas == null ? [] : ds.areas) : c != ""])
    ])
    error_message = "diagnostic_settings categories and areas must not contain empty strings."
  }
}

# Timeouts
variable "timeouts" {
  description = "Optional timeouts configuration for the VM."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
    read   = optional(string)
  })
  default = {}
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the VM."
  type        = map(string)
  default     = {}
}
