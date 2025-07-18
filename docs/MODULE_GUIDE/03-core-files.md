# 3. Core Module Files

The core files of a Terraform module define its logic, inputs, and outputs. This section provides templates and best practices for `versions.tf`, `variables.tf`, `main.tf`, and `outputs.tf`.

## `versions.tf`

This file locks the required versions for Terraform and providers, ensuring stability. It should be present in every module.

**Template:**
```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0" # Pin to a specific minor version for consistency
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
```

---

## `variables.tf`

This file defines the inputs for the module. All variables must have a description and a type. Use validation blocks to enforce constraints.

**Best Practices:**
- **Descriptions**: Every variable MUST have a clear description.
- **Complex Objects**: Use `object()` types for complex, structured inputs (e.g., `network_profile`). This improves clarity over generic `map(any)`.
- **Validation**: Use `validation` blocks to enforce rules on inputs (e.g., length, regex patterns, allowed values). This provides fast feedback to the user.
- **Defaults**: Provide sensible, secure-by-default values where possible.

**Template:**
```hcl
# -----------------------------------------------------------------------------
# Core Module Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the resource. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.name))
    error_message = "The name must be between 1 and 63 characters long, start and end with a letter or number, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the resource should exist."
  type        = string
}

variable "location" {
  description = "The Azure region where the resource should be created."
  type        = string
}

# -----------------------------------------------------------------------------
# Complex Object Variable
# -----------------------------------------------------------------------------

variable "network_profile" {
  description = "Network profile configuration for the cluster."
  type = object({
    network_plugin    = optional(string, "azure")
    network_policy    = optional(string)
    load_balancer_sku = optional(string, "standard")
    # ... other network settings
  })
  default = {}

  validation {
    condition     = contains(["azure", "kubenet"], var.network_profile.network_plugin)
    error_message = "The network_plugin must be either 'azure' or 'kubenet'."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
```

---

## `main.tf`

This is where the primary resources are defined.

**Best Practices:**
- **Locals**: Use a `locals` block to compute values, merge tags, or define complex objects that are used multiple times.
- **Resource Naming**: Use a consistent naming convention for resources within the module, e.g., `azurerm_resource_group.this`.
- **Lifecycle Preconditions**: Use `lifecycle` blocks with `precondition` checks to validate complex inter-variable dependencies that cannot be handled in `variables.tf`.
- **Dynamic Blocks**: Use `dynamic` blocks to conditionally create nested configuration blocks (e.g., for optional features).

**Template:**
```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # ... other required arguments

  # Example of using a dynamic block for an optional feature
  dynamic "oms_agent" {
    for_each = var.oms_agent != null ? [var.oms_agent] : []
    content {
      log_analytics_workspace_id = oms_agent.value.log_analytics_workspace_id
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.private_cluster_enabled == false || var.private_dns_zone_id != null
      error_message = "When private_cluster_enabled is true, private_dns_zone_id must be specified."
    }
  }
}
```

---

## `outputs.tf`

This file defines the outputs of the module. All outputs MUST have a `description`.

**Best Practices:**
- **Clarity**: Output names should be clear and predictable.
- **Descriptions**: Every output MUST have a `description`.
- **Sensitive Data**: Mark outputs containing sensitive information (like keys, passwords, or raw kubeconfigs) with `sensitive = true`.
- **Error Handling**: Use `try()` to prevent errors if an output depends on a resource that might not be created.

**Template:**
```hcl
output "id" {
  description = "The ID of the created Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.this.id, null)
}

output "name" {
  description = "The name of the Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.this.name, null)
}

output "identity" {
  description = "The managed identity of the cluster."
  value = try({
    type         = azurerm_kubernetes_cluster.this.identity[0].type
    principal_id = azurerm_kubernetes_cluster.this.identity[0].principal_id
  }, null)
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to be used by kubectl. This is sensitive!"
  value       = try(azurerm_kubernetes_cluster.this.kube_config_raw, null)
  sensitive   = true
}
```
