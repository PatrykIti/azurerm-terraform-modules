# 3. Core Module Files

The core files of a Terraform module define its logic, inputs, and outputs. This section provides templates and best practices for `versions.tf`, `variables.tf`, `main.tf`, and `outputs.tf`.

## `versions.tf`

This file locks the required versions for Terraform and providers, ensuring stability. It should be present in every module.

**Template:**
```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0" # Pin to the repo standard (AKS)
    }
  }
}
```
Add other providers only when the module uses them directly (avoid adding providers for examples or tests).
For Azure DevOps modules, use the repo standard `microsoft/azuredevops` provider version (currently `1.12.2`).

---

## `variables.tf`

This file defines the inputs for the module. All variables must have a description and a type. Use validation blocks to enforce constraints.

**Best Practices:**
- **Descriptions**: Every variable MUST have a clear description.
- **Complex Objects**: Use `object()` types for complex, structured inputs (e.g., `network_profile`). This improves clarity over generic `map(any)`.
- **Validation**: Use `validation` blocks to enforce rules on inputs (e.g., length, regex patterns, allowed values). This provides fast feedback to the user.
- **Defaults**: Provide sensible, secure-by-default values where possible.
- **Avoid double-defaulting**: If a nested object should always be present, use `default = {}` with `nullable = false` so callers can omit it without `try()`/`coalesce()` in locals.

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
- **Resource Naming**: Use descriptive, consistent names aligned with AKS, e.g., `azurerm_kubernetes_cluster.kubernetes_cluster` or `azurerm_resource_group.resource_group`.
- **Lifecycle Preconditions**: Use `lifecycle` blocks with `precondition` checks to validate complex inter-variable dependencies that cannot be handled in `variables.tf`.
- **Dynamic Blocks**: Use `dynamic` blocks to conditionally create nested configuration blocks within a single resource (e.g., for optional features).
- **Provider-required blocks**: If the provider requires a nested block, keep it always present and drive behavior via defaults + validations (do not use a dynamic block).
- **Explicit dependencies**: Add `depends_on` only when a provider has implicit dependency gaps (for example, child resources that must wait for the main resource).
- **Sub-Resource Creation**: For creating multiple instances of a sub-resource (e.g., storage containers, extra node pools), use a `list(object)` variable and iterate over it with a `for_each` meta-argument on the resource block. This is the standard pattern for managing zero-to-many child resources.
- **Single optional resources**: Use `count` for 0/1 resources; use `for_each` for lists. If list items need stable identities, enforce unique `name` keys in `variables.tf`.

**Main Resource Template (`main.tf`):**
```hcl
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
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

**Sub-Resource Template (`main.tf`):**
```hcl
# In variables.tf
variable "containers" {
  description = "List of storage containers to create."
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
}

# In main.tf
resource "azurerm_storage_container" "storage_container" {
  # Create a map from the list for for_each, using the name as the key
  for_each = { for container in var.containers : container.name => container }

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.storage_account.name # Reference to the main resource
  container_access_type = each.value.container_access_type
}
```

**Flattening nested lists for `for_each`:**
```hcl
# In variables.tf: list(object({ name = string, policies = list(object({ name = string, ... })) }))

locals {
  policy_by_name = {
    for item in flatten([
      for parent in var.parents : [
        for policy in parent.policies : {
          parent = parent
          policy = policy
        }
      ]
    ]) : item.policy.name => item
  }
}

resource "example_policy" "policy" {
  for_each = local.policy_by_name

  # Use each.value.parent + each.value.policy
}
```
Use this only when list policies can repeat per parent; otherwise prefer a simple map keyed by `parent.name`.

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
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.id, null)
}

output "name" {
  description = "The name of the Kubernetes Cluster."
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.name, null)
}

output "identity" {
  description = "The managed identity of the cluster."
  value = try({
    type         = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type
    principal_id = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
  }, null)
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to be used by kubectl. This is sensitive!"
  value       = try(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw, null)
  sensitive   = true
}
```
---

## Variable Grouping Strategy: Flat Variables vs. Complex Objects

A key design decision in a module is how to structure its input variables. Our repository uses two primary patterns, each suited for different levels of module complexity.

### Approach 1: Grouped Objects (Default, AKS Pattern)

This pattern, exemplified by the `azurerm_kubernetes_cluster` module, groups a large number of related variables into nested `object()` structures.

- **When to use it**:
  - By default, to keep module APIs consistent with the AKS gold standard.
  - When there are distinct, logical groups of configuration (e.g., `default_node_pool`, `network_profile`, `identity`).
  - When you need to manage multiple, complex sub-configurations or repeated blocks (`list(object)`).

- **Advantages**:
  - **Organized**: Keeps the `variables.tf` file clean and structured.
  - **Scalable**: Easier to add new sub-options without cluttering the top-level namespace.

- **Disadvantages**:
  - **Complexity**: Can be harder for users to discover options without good documentation.
  - **Boilerplate**: Requires object construction even for small changes (mitigate with `optional()` and defaults).

### Approach 2: Flat Variables (Only for Small Modules)

This pattern, exemplified by the `azurerm_storage_account` module, defines most variables as top-level, primitive types (`string`, `bool`, `number`).

- **When to use it**:
  - Only when the module is very small and grouped objects would be overkill.
  - When arguments are few, independent, and unlikely to grow.

- **Advantages**:
  - **Simplicity**: Very easy for users to understand and provide values.
  - **Discoverability**: All options are clearly visible as individual variables.
  - **Ease of Use**: Users only need to specify the variables they want to change from the defaults.

**Example (flat variables):**
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

### The Hybrid Approach (Optional)

The `azurerm_storage_account` module also demonstrates a smart hybrid approach. While most variables are flat, a few tightly-coupled settings are grouped into small, simple objects.

- **`security_settings`**: Groups a few boolean flags related to security.
- **`blob_properties`**: Groups settings specific to the blob service.

This can be useful in very small modules, but prefer the AKS pattern unless the module is trivial.

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

| Criteria | Use Grouped Objects (AKS Pattern) | Use Flat Variables (Exception) |
| :--- | :--- | :--- |
| **Module Complexity** | **Medium to High** (default) | **Low** (very small modules only) |
| **Resource Type** | Multiple interrelated resources or repeated blocks | Single resource with few independent inputs |
| **Configuration Style** | Variables are heavily grouped into logical, nested objects. | Variables are mostly flat, with small objects for tight-knit groups. |
| **User Experience** | Consistent API surface across modules, easier long-term maintenance. | Simpler for tiny modules, but less consistent across the repo. |
| **Best For** | Default choice; aligns with AKS and repo standards. | Rare exceptions only. |

**Recommendation**: **Default to the AKS grouped-object pattern** and `list(object)` for repeated blocks. Use flat variables only when the module is trivially small.
