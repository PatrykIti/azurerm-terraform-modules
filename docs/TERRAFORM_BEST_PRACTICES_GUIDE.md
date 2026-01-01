# Terraform Azure Modules - Contributor's Guide

This guide outlines the best practices and standards for contributing to this open-source Terraform Azure modules repository. Following these guidelines ensures consistency, security, and maintainability across all modules.

The `modules/azurerm_kubernetes_cluster` module is the **gold standard** for structure, naming, testing, and documentation. Use it as the baseline, but document and justify any deviations when a specific Azure resource (or Azure DevOps service) requires different patterns or features. Not every resource supports the same feature set, so examples and docs may differ.

## Table of Contents

1. [Core Principles](#core-principles)
2. [Module Structure](#module-structure)
3. [Naming Conventions](#naming-conventions)
4. [Variable Design](#variable-design)
5. [Resource Implementation](#resource-implementation)
6. [Security Best Practices](#security-best-practices)
7. [Testing Requirements](#testing-requirements)
8. [Documentation Standards](#documentation-standards)
9. [Contribution Process](#contribution-process)

## Core Principles

### 1. Simplicity First
- Modules should be the simplest possible abstraction layer
- NO `create_*` variables - if someone needs the resource, they use the module
- NO conditional creation unless absolutely necessary for resource logic
- Complex logic only when required for different configuration scenarios

### 2. Security by Default
- All security settings must be enabled by default
- Use secure defaults for all configurations
- Never store secrets in plain text
- Always use the most restrictive settings as defaults

### 3. Flat Module Structure
- No nested modules - keep the structure flat
- Each module should do one thing well
- Avoid over-abstraction

## Module Structure

### Standard Directory Layout (AKS Baseline)

```
modules/
└── <provider>_<resource_name>/
    ├── docs/
    │   └── IMPORT.md
    ├── examples/
    │   ├── basic/
    │   │   ├── .terraform-docs.yml
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── outputs.tf
    │   │   └── README.md
    │   ├── complete/
    │   │   └── ...
    │   ├── secure/
    │   │   └── ...
    │   └── <feature-specific>/ (optional)
    │       └── ...
    ├── tests/
    │   ├── fixtures/
    │   │   ├── basic/
    │   │   ├── complete/
    │   │   ├── secure/
    │   │   ├── network/
    │   │   ├── negative/
    │   │   └── <feature-specific>/ (optional)
    │   ├── unit/
    │   │   ├── defaults.tftest.hcl
    │   │   ├── naming.tftest.hcl
    │   │   ├── validation.tftest.hcl
    │   │   └── outputs.tftest.hcl
    │   ├── .gitignore
    │   ├── go.mod
    │   ├── go.sum
    │   ├── <module>_test.go
    │   ├── integration_test.go
    │   ├── performance_test.go
    │   ├── test_helpers.go
    │   ├── test_config.yaml
    │   ├── test_env.sh
    │   ├── run_tests_parallel.sh
    │   ├── run_tests_sequential.sh
    │   ├── test_outputs/
    │   └── Makefile
    ├── .releaserc.js
    ├── .terraform-docs.yml
    ├── CHANGELOG.md
    ├── README.md
    ├── SECURITY.md
    ├── VERSIONING.md
    ├── CONTRIBUTING.md
    ├── module.json
    ├── generate-docs.sh
    ├── Makefile
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```
Use `azurerm_` for AzureRM modules and `azuredevops_` for Azure DevOps modules.

## Naming Conventions

### Resource Naming Rules

**CRITICAL**: For any provider resource (`azurerm_*` or `azuredevops_*`), the local name should match the resource type without the provider prefix:

```hcl
# ❌ WRONG - Never do this
resource "azurerm_kubernetes_cluster" "azurerm_kubernetes_cluster" {
  # ...
}

resource "azurerm_kubernetes_cluster" "this" {
  # ...
}

resource "azurerm_kubernetes_cluster" "custom_name" {
  # ...
}

# ✅ CORRECT - Always do this
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  # ...
}

resource "azurerm_virtual_network" "virtual_network" {
  # ...
}

resource "azurerm_key_vault" "key_vault" {
  # ...
}
```
This rule also applies to `azuredevops_*` resources.

### Iteration Variable Naming

Always use descriptive variable names in loops to improve code readability:

```hcl
# ❌ WRONG - Avoid shortcuts
for c in var.containers : c.name => c

# ✅ CORRECT - Use full descriptive names
for container in var.containers : container.name => container

# ✅ CORRECT - Clear and readable
for file_share in var.file_shares : file_share.name => file_share

# ✅ CORRECT - Self-documenting
for subnet in var.subnets : subnet.name => subnet
```

## Variable Design

### 1. Group Related Configurations

Use objects to group related settings together:

```hcl
variable "security_settings" {
  description = <<-EOT
    Security configuration for the resource:
    - enable_https_traffic_only: Force HTTPS traffic only
    - min_tls_version: Minimum TLS version (TLS1_2 recommended)
    - shared_access_key_enabled: Enable shared access keys
  EOT
  
  type = object({
    enable_https_traffic_only = optional(bool, true)
    min_tls_version          = optional(string, "TLS1_2")
    shared_access_key_enabled = optional(bool, false)
  })
  
  default = {}
}
```

### 2. Use Lists of Objects for Collections

Lists are more readable than maps in Terraform:

```hcl
variable "node_pools" {
  description = "List of node pools to create"
  
  type = list(object({
    name    = string
    vm_size = string
  }))
  
  default = []
  
  validation {
    condition = alltrue([
      for node_pool in var.node_pools :
        can(regex("^[a-z0-9]{1,12}$", node_pool.name))
    ])
    error_message = "Node pool names must be 1-12 lowercase alphanumeric characters."
  }
}
```

### 3. Comprehensive Validation

Always include validation with helpful error messages:

```hcl
variable "name" {
  description = "Name of the primary resource (lowercase, hyphenated)."
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.name))
    error_message = "The name must be 1-63 chars, lowercase, and may include hyphens."
  }
}
```

## Resource Implementation

### 1. Use Dynamic Blocks for Optional Features

```hcl
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Required settings (resource-specific)

  # Optional monitoring block
  dynamic "oms_agent" {
    for_each = var.monitoring != null ? [var.monitoring] : []
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

### 2. Resource Creation with Iteration

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each = {
    for node_pool in var.node_pools : node_pool.name => node_pool
  }

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  vm_size               = each.value.vm_size
}
```

### 3. Optional Resources with count

When a resource is driven by an optional object input, `count` can guard the
entire resource. Terraform does not evaluate resource arguments when `count = 0`,
so it is safe to reference `var.optional_object.*` inside the resource even if
the object is null. Outputs and other references still need guards.

```hcl
variable "monitoring" {
  description = "Optional monitoring settings."
  type = object({
    name               = string
    target_resource_id = string
  })
  default = null
}

resource "azurerm_monitor_diagnostic_setting" "monitoring" {
  count = var.monitoring == null ? 0 : 1

  name               = var.monitoring.name
  target_resource_id = var.monitoring.target_resource_id
}

output "monitoring_id" {
  value = var.monitoring == null ? null : azurerm_monitor_diagnostic_setting.monitoring[0].id
}
```

## Security Best Practices

### 1. Secure Defaults

Always set the most secure configuration as default:

```hcl
variable "security_profile" {
  type = object({
    private_cluster_enabled = optional(bool, true)
    local_accounts_disabled = optional(bool, true)
    authorized_ip_ranges    = optional(list(string), [])
  })
  
  default = {}
}
```
Fields vary by resource; use this pattern to group security-related settings and keep defaults secure.

### 2. Secret Management

Never store secrets in variables. Generate them or retrieve from Key Vault:

```hcl
# Generate password securely
resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# Store in Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.name}-admin-password"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id
  
  lifecycle {
    ignore_changes = [value]
  }
}
```

## Testing Requirements

### 1. Basic Example Test

Every module must include a basic example that demonstrates minimal usage:

```hcl
# examples/basic/main.tf
module "example" {
  source = "../../"
  
  name                = "example-basic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add required module-specific inputs here
  
  tags = {
    Environment = "Test"
    ManagedBy   = "Terraform"
  }
}
```
For Azure DevOps modules, replace `resource_group_name`/`location` with organization and project inputs.

### 2. Complete Example

Include a complete example showing all features:

```hcl
# examples/complete/main.tf
module "example" {
  source = "../../"
  
  name                = "example-complete"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Resource-specific configuration blocks go here
  # Example: network_profile, identity, monitoring, security, etc.
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```
Use a separate `secure` example to demonstrate hardened defaults (private access, encryption, policy/defender, etc.).

## Documentation Standards

### 1. README Structure

Every module must have a comprehensive README:

```markdown
# terraform-azurerm-<resource-name>

## Overview
Brief description of what this module creates and its purpose.

## Features
- Feature 1
- Feature 2
- Feature 3

## Usage

\```hcl
module "example" {
  source = "path/to/module"
  
  # Required variables
  name                = "myresource"
  resource_group_name = "myrg"
  location            = "northeurope"
}
\```

## Examples
- [Basic Example](examples/basic)
- [Complete Example](examples/complete)
- [Secure Example](examples/secure)

<!-- BEGIN_TF_DOCS -->
<!-- Automatically generated documentation -->
<!-- END_TF_DOCS -->

## Requirements
- Terraform >= 1.12.2
- AzureRM Provider = 4.57.0 (or Azure DevOps provider where applicable)

## Contributing
Please see our [contribution guidelines](../../CONTRIBUTING.md).

## License
MIT
```

### 2. Variable Descriptions

Use clear, multi-line descriptions for complex variables:

```hcl
variable "network_configuration" {
  description = <<-EOT
    Network configuration for the resource:
      • subnet_id - ID of the subnet to deploy into
      • private_endpoint_enabled - Enable private endpoint
      • allowed_ip_ranges - List of allowed IP ranges (CIDR format)
      • dns_servers - Custom DNS servers (optional)
    
    Set to null to use default networking.
  EOT
  
  type = object({
    subnet_id                = string
    private_endpoint_enabled = optional(bool, true)
    allowed_ip_ranges       = optional(list(string), [])
    dns_servers             = optional(list(string), [])
  })
  
  default = null
}
```

## Contribution Process

### 1. Pre-Contribution Checklist

Before submitting a PR, ensure:

- [ ] Module follows the naming conventions
- [ ] All variables have validation and descriptions
- [ ] Security defaults are properly set
- [ ] Examples (basic, complete, secure) are included
- [ ] Tests pass successfully
- [ ] Documentation is generated with terraform-docs
- [ ] `docs/IMPORT.md` is present and updated
- [ ] CHANGELOG is updated

### 2. PR Guidelines

1. **Branch Naming**: `feature/module-<resource-name>` or `fix/module-<resource-name>-issue`
2. **Commit Messages**: Use conventional commits
   - `feat(aks): add support for workload identity`
   - `fix(aks): correct validation for node pool names`
   - `docs(aks): update examples with new features`

3. **Testing**: All PRs must include:
   - Working examples
   - Updated tests
   - Successful CI/CD pipeline run

### 3. Code Review Criteria

Reviewers will check for:

1. **Compliance with naming conventions**
2. **Security-first approach**
3. **Proper validation implementation**
4. **Clear documentation**
5. **Working examples**
6. **No hardcoded values**
7. **Proper use of dynamic blocks**
8. **Descriptive variable names in iterations**

## Common Pitfalls to Avoid

### ❌ Don't Do This:

```hcl
# No validation
variable "location" {
  type = string
}

# Insecure defaults
variable "enable_public_access" {
  type    = bool
  default = true  # Bad default!
}

# Unclear iteration variables
for s in var.subnets : s.name => s

# Conditional resource creation
variable "create_resource" {
  type = bool
}
```

### ✅ Do This Instead:

```hcl
# With validation
variable "location" {
  description = "Azure region for resources"
  type        = string
  
  validation {
    condition     = can(regex("^(northeurope|westeurope|eastus|westus)$", var.location))
    error_message = "Location must be a valid Azure region."
  }
}

# Secure defaults
variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false  # Secure by default
}

# Clear iteration variables
for subnet in var.subnets : subnet.name => subnet

# Simple module usage (no create flags)
# If they don't want the resource, they don't use the module
```

## Summary

This repository maintains high standards for Terraform modules to ensure:

1. **Consistency** - All modules follow the same patterns
2. **Security** - Secure by default configurations
3. **Simplicity** - Easy to use and understand
4. **Maintainability** - Clear code with good documentation
5. **Reliability** - Comprehensive validation and testing

Remember: The best modules are simple to use, secure by default, and flexible when needed.

---

For questions or suggestions, please open an issue or join our discussions.
