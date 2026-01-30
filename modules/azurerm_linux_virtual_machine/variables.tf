# Core Linux Virtual Machine variables
variable "name" {
  description = "The name of the Linux Virtual Machine."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,62}[A-Za-z0-9])?$", var.name))
    error_message = "VM name must be 1-64 characters, alphanumeric or hyphen, and cannot start or end with a hyphen."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Linux Virtual Machine."
  type        = string
}

variable "location" {
  description = "The Azure region where the Linux Virtual Machine should exist."
  type        = string
}

variable "size" {
  description = "The size of the Linux Virtual Machine (SKU)."
  type        = string
}

# Networking
variable "network_interface_ids" {
  description = "A list of Network Interface IDs to attach to the VM. The first is used as primary unless primary_network_interface_id is specified."
  type        = list(string)

  validation {
    condition     = length(var.network_interface_ids) > 0
    error_message = "At least one network_interface_id must be provided."
  }
}

variable "primary_network_interface_id" {
  description = "The ID of the primary Network Interface. Must be one of network_interface_ids."
  type        = string
  default     = null

  validation {
    condition     = var.primary_network_interface_id == null || contains(var.network_interface_ids, var.primary_network_interface_id)
    error_message = "primary_network_interface_id must be one of network_interface_ids."
  }
}

# Admin/authentication
variable "admin_username" {
  description = "The admin username for the Linux Virtual Machine."
  type        = string
}

variable "disable_password_authentication" {
  description = "Whether password authentication should be disabled. If true, at least one admin_ssh_key is required."
  type        = bool
  default     = true

  validation {
    condition     = var.disable_password_authentication ? length(var.admin_ssh_keys) > 0 : (var.admin_password != null && var.admin_password != "")
    error_message = "When disable_password_authentication is true, at least one admin_ssh_key is required. When false, admin_password must be provided."
  }
}

variable "admin_password" {
  description = "The admin password for the Linux Virtual Machine (required when disable_password_authentication = false)."
  type        = string
  default     = null
  sensitive   = true
}

variable "admin_ssh_keys" {
  description = "SSH public keys to configure on the VM. Required when disable_password_authentication = true."
  type = list(object({
    username   = string
    public_key = string
  }))
  default = []

  validation {
    condition = alltrue([
      for key in var.admin_ssh_keys :
      key.username != "" && key.public_key != ""
    ])
    error_message = "Each admin_ssh_key must include a non-empty username and public_key."
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
    name                      = optional(string)
    caching                   = string
    storage_account_type      = string
    disk_size_gb              = optional(number)
    write_accelerator_enabled = optional(bool, false)
    disk_encryption_set_id    = optional(string)
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
    condition     = var.os_disk.diff_disk_settings == null || contains(["Local"], var.os_disk.diff_disk_settings.option)
    error_message = "os_disk.diff_disk_settings.option must be Local when specified."
  }

  validation {
    condition     = var.os_disk.diff_disk_settings == null || var.os_disk.diff_disk_settings.placement == null || contains(["CacheDisk", "ResourceDisk", "NvmeDisk"], var.os_disk.diff_disk_settings.placement)
    error_message = "os_disk.diff_disk_settings.placement must be CacheDisk, ResourceDisk, or NvmeDisk when specified."
  }
}

# Data disks
variable "data_disks" {
  description = <<-EOT
    Data disks attached to the VM. Each entry must have a unique name and LUN.

    caching: None, ReadOnly, ReadWrite
    storage_account_type: Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, UltraSSD_LRS
    create_option: Empty or FromImage
  EOT
  type = list(object({
    name                           = string
    lun                            = number
    caching                        = string
    disk_size_gb                   = number
    storage_account_type           = string
    create_option                  = optional(string, "Empty")
    write_accelerator_enabled      = optional(bool, false)
    disk_encryption_set_id         = optional(string)
    ultra_ssd_disk_iops_read_write = optional(number)
    ultra_ssd_disk_mbps_read_write = optional(number)
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
      contains(["Empty", "FromImage"], disk.create_option)
    ])
    error_message = "data_disks.create_option must be Empty or FromImage."
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
      (disk.ultra_ssd_disk_iops_read_write == null && disk.ultra_ssd_disk_mbps_read_write == null) ||
      contains(["PremiumV2_LRS", "UltraSSD_LRS"], disk.storage_account_type)
    ])
    error_message = "Ultra SSD performance settings are only valid for PremiumV2_LRS or UltraSSD_LRS disks."
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
    condition     = var.identity == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || length(var.identity.identity_ids) > 0
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

  validation {
    condition     = var.spot.priority != "Spot" || var.spot.eviction_policy != null
    error_message = "spot.eviction_policy is required when spot.priority is Spot."
  }

  validation {
    condition     = var.spot.priority == "Spot" || (var.spot.eviction_policy == null && var.spot.max_bid_price == null)
    error_message = "spot.eviction_policy and max_bid_price can only be set when spot.priority is Spot."
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

# VM agent + patching
variable "vm_agent" {
  description = "VM agent configuration."
  type = object({
    provision_vm_agent         = optional(bool, true)
    allow_extension_operations = optional(bool, true)
    extensions_time_budget     = optional(string)
  })
  default = {}

  validation {
    condition     = var.vm_agent.provision_vm_agent || var.vm_agent.allow_extension_operations == false
    error_message = "allow_extension_operations must be false when provision_vm_agent is false."
  }
}

variable "patching" {
  description = "Guest patching configuration."
  type = object({
    patch_mode            = optional(string, "ImageDefault")
    patch_assessment_mode = optional(string, "ImageDefault")
    reboot_setting        = optional(string)
  })
  default = {}

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patching.patch_mode)
    error_message = "patching.patch_mode must be AutomaticByPlatform or ImageDefault."
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
    condition     = var.patching.patch_mode != "AutomaticByPlatform" || var.vm_agent.provision_vm_agent
    error_message = "patching.patch_mode = AutomaticByPlatform requires vm_agent.provision_vm_agent = true."
  }

  validation {
    condition     = var.patching.patch_assessment_mode != "AutomaticByPlatform" || var.vm_agent.provision_vm_agent
    error_message = "patching.patch_assessment_mode = AutomaticByPlatform requires vm_agent.provision_vm_agent = true."
  }

  validation {
    condition     = var.patching.reboot_setting == null || var.patching.patch_mode == "AutomaticByPlatform"
    error_message = "patching.reboot_setting can only be set when patching.patch_mode is AutomaticByPlatform."
  }
}

# Additional VM configuration
variable "computer_name" {
  description = "Optional computer name for the VM."
  type        = string
  default     = null

  validation {
    condition     = var.computer_name == null || can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,62}[A-Za-z0-9])?$", var.computer_name))
    error_message = "computer_name must be 1-64 characters, alphanumeric or hyphen, and cannot start or end with a hyphen."
  }
}

variable "custom_data" {
  description = "Base64-encoded custom data (cloud-init) for the VM."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64-encoded user data for the VM."
  type        = string
  default     = null
}

variable "gallery_applications" {
  description = "Gallery applications to install on the VM."
  type = list(object({
    version_id                = string
    automatic_upgrade_enabled = optional(bool)
    configuration_blob_uri    = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = "Key Vault secrets (certificates) to inject into the VM."
  type = list(object({
    key_vault_id = string
    certificates = list(object({
      url = string
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
      secret_url      = string
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
    metric_categories              = optional(list(string))
    log_category_groups            = optional(list(string))
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
