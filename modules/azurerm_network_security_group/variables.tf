# Core Network Security Group Variables
variable "name" {
  description = "The name of the Network Security Group. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition = alltrue([
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name)),
      length(var.name) >= 1,
      length(var.name) <= 80
    ])
    error_message = "Network Security Group name must be 1-80 characters long, start with alphanumeric, and contain only letters, numbers, hyphens, periods, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Network Security Group."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Network Security Group should exist. Changing this forces a new resource to be created."
  type        = string
}

# Security Rules Configuration
variable "security_rules" {
  description = <<-EOT
    List of security rule objects to create. The `name` attribute is used as the unique identifier.
    
    Important notes:
    - Priority must be unique within the NSG (100-4096)
    - Use either singular (e.g., source_address_prefix) or plural (e.g., source_address_prefixes) attributes, not both
    - Service tags like 'Internet', 'VirtualNetwork', 'AzureLoadBalancer' can be used in address prefixes
    - Application Security Groups can be referenced using their IDs
    
    Example:
    ```
    security_rules = [
      {
        name                       = "allow_ssh"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.0.0/8"
        destination_address_prefix = "*"
        description                = "Allow SSH from internal network"
      },
      {
        name                         = "allow_https_multiple"
        priority                     = 110
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_ranges           = ["443", "8443"]
        destination_port_range       = "*"
        source_address_prefixes      = ["10.0.0.0/8", "172.16.0.0/12"]
        destination_address_prefix   = "VirtualNetwork"
      }
    ]
    ```
  EOT

  type = list(object({
    name                                       = string
    description                                = optional(string)
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))

  default = []

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "Security rule direction must be either 'Inbound' or 'Outbound'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "Security rule access must be either 'Allow' or 'Deny'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol)
    ])
    error_message = "Security rule protocol must be one of: 'Tcp', 'Udp', 'Icmp', 'Esp', 'Ah', or '*'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Security rule priority must be between 100 and 4096."
  }

  # Validate no duplicate priorities
  validation {
    condition     = length(distinct([for rule in var.security_rules : rule.priority])) == length(var.security_rules)
    error_message = "Security rules must have unique priorities."
  }

  # Port validation: singular vs plural
  validation {
    condition = alltrue([
      for rule in var.security_rules : (rule.source_port_range == null || rule.source_port_ranges == null)
    ])
    error_message = "In 'security_rules', a rule can have 'source_port_range' or 'source_port_ranges', but not both."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : (rule.destination_port_range == null || rule.destination_port_ranges == null)
    ])
    error_message = "In 'security_rules', a rule can have 'destination_port_range' or 'destination_port_ranges', but not both."
  }

  # Source address validation: prefix vs prefixes vs ASG IDs
  validation {
    condition = alltrue([
      for rule in var.security_rules :
      ((rule.source_address_prefix != null ? 1 : 0) +
        (rule.source_address_prefixes != null ? 1 : 0) +
      (rule.source_application_security_group_ids != null ? 1 : 0)) <= 1
    ])
    error_message = "In 'security_rules', a rule can only have one of 'source_address_prefix', 'source_address_prefixes', or 'source_application_security_group_ids' defined."
  }

  # Destination address validation: prefix vs prefixes vs ASG IDs
  validation {
    condition = alltrue([
      for rule in var.security_rules :
      ((rule.destination_address_prefix != null ? 1 : 0) +
        (rule.destination_address_prefixes != null ? 1 : 0) +
      (rule.destination_application_security_group_ids != null ? 1 : 0)) <= 1
    ])
    error_message = "In 'security_rules', a rule can only have one of 'destination_address_prefix', 'destination_address_prefixes', or 'destination_application_security_group_ids' defined."
  }
}

# Observability: Diagnostic Settings
variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings for NSG logs and metrics.

    Each item creates a separate azurerm_monitor_diagnostic_setting for the NSG.
    Use areas to group categories (event, rule_counter, logs, metrics) or provide explicit
    log_categories / metric_categories. At least one destination is required.
  EOT

  type = list(object({
    name                           = string
    areas                          = optional(list(string))
    log_categories                 = optional(list(string))
    metric_categories              = optional(list(string))
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
  }))

  default = []

  validation {
    condition     = length(var.diagnostic_settings) <= 5
    error_message = "Azure allows a maximum of 5 diagnostic settings per NSG resource."
  }

  validation {
    condition     = length(distinct([for ds in var.diagnostic_settings : ds.name])) == length(var.diagnostic_settings)
    error_message = "Each diagnostic_settings entry must have a unique name."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic_settings entry must specify at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
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
    error_message = "log_analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }

  validation {
    condition = alltrue([
      for ds in var.diagnostic_settings :
      alltrue([
        for area in(ds.areas != null ? ds.areas : ["all"]) :
        contains([
          "all",
          "event",
          "rule_counter",
          "logs",
          "metrics"
        ], area)
      ])
    ])
    error_message = "areas may contain only: all, event, rule_counter, logs, metrics."
  }
}

# Observability: Flow Logs (Network Watcher)
variable "flow_log" {
  description = <<-EOT
    Network Watcher flow log configuration for the NSG.

    Set to null to disable. When enabled, requires an existing Network Watcher.
  EOT

  type = object({
    name                                = optional(string)
    enabled                             = optional(bool, true)
    storage_account_id                  = string
    network_watcher_name                = string
    network_watcher_resource_group_name = string
    version                             = optional(number, 2)
    retention_policy = optional(object({
      enabled = optional(bool, false)
      days    = optional(number, 0)
    }))
    traffic_analytics = optional(object({
      enabled               = optional(bool, true)
      workspace_id          = string
      workspace_region      = string
      workspace_resource_id = string
      interval_in_minutes   = optional(number, 10)
    }))
  })

  default = null

  validation {
    condition = var.flow_log == null ? true : (
      var.flow_log.storage_account_id != "" &&
      var.flow_log.network_watcher_name != "" &&
      var.flow_log.network_watcher_resource_group_name != ""
    )
    error_message = "flow_log requires storage_account_id, network_watcher_name, and network_watcher_resource_group_name."
  }

  validation {
    condition     = var.flow_log == null ? true : (var.flow_log.name == null || var.flow_log.name != "")
    error_message = "flow_log.name cannot be an empty string."
  }

  validation {
    condition     = var.flow_log == null ? true : (var.flow_log.version == null || contains([1, 2], var.flow_log.version))
    error_message = "flow_log.version must be 1 or 2."
  }

  validation {
    condition = var.flow_log == null ? true : (var.flow_log.retention_policy == null || (
      var.flow_log.retention_policy.days >= 0 &&
      (var.flow_log.retention_policy.enabled == false || var.flow_log.retention_policy.days > 0)
    ))
    error_message = "flow_log.retention_policy.days must be >= 0; if retention is enabled, days must be > 0."
  }

  validation {
    condition = var.flow_log == null ? true : (var.flow_log.traffic_analytics == null || (
      var.flow_log.traffic_analytics.workspace_id != "" &&
      var.flow_log.traffic_analytics.workspace_region != "" &&
      var.flow_log.traffic_analytics.workspace_resource_id != "" &&
      contains([10, 60], var.flow_log.traffic_analytics.interval_in_minutes)
    ))
    error_message = "flow_log.traffic_analytics requires workspace_id, workspace_region, workspace_resource_id, and interval_in_minutes of 10 or 60."
  }
}



# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
