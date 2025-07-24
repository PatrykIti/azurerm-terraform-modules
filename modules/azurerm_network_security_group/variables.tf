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
    condition = length(distinct([for rule in var.security_rules : rule.priority])) == length(var.security_rules)
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

# Flow Log Configuration
variable "flow_log_enabled" {
  description = "Enable NSG Flow Logs. Requires network_watcher_name to be set."
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "The name of the Network Watcher. Required if flow_log_enabled is true."
  type        = string
  default     = null
}

variable "flow_log_storage_account_id" {
  description = "The ID of the Storage Account where flow logs will be stored. Required if flow_log_enabled is true."
  type        = string
  default     = null
}

variable "flow_log_retention_in_days" {
  description = "The number of days to retain flow log records. 0 means unlimited retention."
  type        = number
  default     = 7

  validation {
    condition     = var.flow_log_retention_in_days >= 0 && var.flow_log_retention_in_days <= 365
    error_message = "Flow log retention must be between 0 and 365 days."
  }
}

variable "flow_log_version" {
  description = "The version of the flow log to use. Valid values are 1 and 2."
  type        = number
  default     = 2

  validation {
    condition     = contains([1, 2], var.flow_log_version)
    error_message = "Flow log version must be either 1 or 2."
  }
}

# Traffic Analytics Configuration
variable "traffic_analytics_enabled" {
  description = "Enable Traffic Analytics for the NSG Flow Logs."
  type        = bool
  default     = false
}

variable "traffic_analytics_workspace_id" {
  description = "The workspace GUID ID of the Log Analytics workspace for Traffic Analytics. Required if traffic_analytics_enabled is true."
  type        = string
  default     = null
}

variable "traffic_analytics_workspace_resource_id" {
  description = "The full resource ID of the Log Analytics workspace for Traffic Analytics. Required if traffic_analytics_enabled is true."
  type        = string
  default     = null
}

variable "traffic_analytics_workspace_region" {
  description = "The region of the Log Analytics workspace for Traffic Analytics. Required if traffic_analytics_enabled is true."
  type        = string
  default     = null
}

variable "traffic_analytics_interval_in_minutes" {
  description = "The interval in minutes which Traffic Analytics will process logs. Valid values are 10 and 60."
  type        = number
  default     = 10

  validation {
    condition     = contains([10, 60], var.traffic_analytics_interval_in_minutes)
    error_message = "Traffic analytics interval must be either 10 or 60 minutes."
  }
}

# Diagnostic Settings Configuration
variable "diagnostic_settings" {
  description = <<-EOT
    Configuration for Azure Monitor Diagnostic Settings for the NSG.
    
    Properties:
    - name: Name of the diagnostic setting
    - log_analytics_workspace_id: ID of the Log Analytics workspace to send logs to
    - storage_account_id: ID of the Storage Account to send logs to (optional)
    - eventhub_name: Name of the Event Hub to send logs to (optional)
    - eventhub_authorization_rule_id: ID of the Event Hub authorization rule (optional)
    - log_categories: List of log categories to enable. Valid values: "NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"
    - metric_categories: List of metric categories to enable. Valid values: "AllMetrics"
    
    Example:
    ```
    diagnostic_settings = {
      name                       = "nsg-diagnostics"
      log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"
      log_categories             = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
      metric_categories          = ["AllMetrics"]
    }
    ```
  EOT
  type = object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_categories                 = optional(list(string), ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"])
    metric_categories              = optional(list(string), ["AllMetrics"])
  })
  default = null
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}