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
---

## Variable Grouping Strategy: Flat Variables vs. Complex Objects

A key design decision in a module is how to structure its input variables. Our repository uses two primary patterns, each suited for different levels of module complexity.

### Approach 1: Complex Objects (for High-Complexity Modules)

This pattern, exemplified by the `azurerm_kubernetes_cluster` module, groups a large number of related variables into nested `object()` structures.

- **When to use it**:
  - For complex resources with hundreds of potential arguments (like AKS, Application Gateway).
  - When there are distinct, logical groups of configuration (e.g., `default_node_pool`, `network_profile`, `identity`).
  - When you need to manage multiple, complex sub-configurations.

- **Advantages**:
  - **Organized**: Keeps the `variables.tf` file clean and structured.
  - **Scalable**: Easier to add new sub-options without cluttering the top-level namespace.

- **Disadvantages**:
  - **Complexity**: Can be harder for users to understand and construct the required object structures.
  - **Boilerplate**: Requires users to define the entire object structure even to change a single value.

### Approach 2: Flat Variables (for Standard-Complexity Modules)

This pattern, exemplified by the `azurerm_storage_account` module, defines most variables as top-level, primitive types (`string`, `bool`, `number`).

- **When to use it**:
  - For modules managing a single primary resource with a manageable number of arguments (e.g., Storage Account, Key Vault, Virtual Network).
  - When most arguments are independent of each other.

- **Advantages**:
  - **Simplicity**: Very easy for users to understand and provide values.
  - **Discoverability**: All options are clearly visible as individual variables.
  - **Ease of Use**: Users only need to specify the variables they want to change from the defaults.

**Example (`azurerm_storage_account` `variables.tf`):**
```hcl
variable "account_tier" {
  description = "Defines the Tier to use for this storage account."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
  default     = "ZRS"
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This is required for Data Lake Storage Gen 2."
  type        = bool
  default     = null
}
```

### The Hybrid Approach

The `azurerm_storage_account` module also demonstrates a smart hybrid approach. While most variables are flat, a few tightly-coupled settings are grouped into small, simple objects.

- **`security_settings`**: Groups a few boolean flags related to security.
- **`blob_properties`**: Groups settings specific to the blob service.

This is an excellent pattern that combines the simplicity of flat variables with the organization of small, logical object groupings.

**Example (`azurerm_storage_account` `variables.tf`):**
```hcl
variable "security_settings" {
  description = "Security configuration for the storage account."
  type = object({
    https_traffic_only_enabled        = optional(bool, true)
    min_tls_version                   = optional(string, "TLS1_2")
    shared_access_key_enabled         = optional(bool, false)
    // ...
  })
  default = {}
}
```

### Summary and Recommendations

| Criteria | Use Complex Objects (AKS Pattern) | Use Flat Variables (Storage Account Pattern) |
| :--- | :--- | :--- |
| **Module Complexity** | **High** (e.g., >50-75 inputs) | **Low to Medium** (e.g., <50 inputs) |
| **Resource Type** | Manages multiple complex, interrelated resources (AKS + Node Pools + Addons) | Manages one primary resource and its direct sub-resources |
| **Configuration Style** | Variables are heavily grouped into logical, nested objects. | Variables are mostly flat, with small objects for tight-knit groups. |
| **User Experience** | More structured but requires more effort from the user. | Simpler and more direct for the user. |
| **Best For** | Orchestration modules, resources with massive APIs. | Typical resource modules. |

**Recommendation**: **Default to the flat/hybrid variable pattern** seen in `azurerm_storage_account`. Only adopt the complex object pattern when the number and complexity of variables make the flat structure unwieldy.
