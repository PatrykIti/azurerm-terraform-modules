# Terraform Azure Modules - Contributor's Guide

This guide outlines the best practices and standards for contributing to this open-source Terraform Azure modules repository. Following these guidelines ensures consistency, security, and maintainability across all modules.

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

### Standard Directory Layout

```
modules/
└── azurerm_<resource_name>/
    ├── examples/
    │   ├── basic/
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── outputs.tf
    │   │   └── README.md
    │   └── complete/
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       └── README.md
    ├── tests/
    │   └── terraform_test.go
    ├── .terraform-docs.yml
    ├── CHANGELOG.md
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

## Naming Conventions

### Resource Naming Rules

**CRITICAL**: For any `azurerm_*` resource, the local name should match the resource type without the provider prefix:

```hcl
# ❌ WRONG - Never do this
resource "azurerm_storage_account" "azurerm_storage_account" {
  # ...
}

resource "azurerm_storage_account" "this" {
  # ...
}

resource "azurerm_storage_account" "custom_name" {
  # ...
}

# ✅ CORRECT - Always do this
resource "azurerm_storage_account" "storage_account" {
  # ...
}

resource "azurerm_virtual_network" "virtual_network" {
  # ...
}

resource "azurerm_key_vault" "key_vault" {
  # ...
}
```

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
variable "containers" {
  description = "List of storage containers to create"
  
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  
  default = []
  
  validation {
    condition = alltrue([
      for container in var.containers : 
        contains(["private", "blob", "container"], container.container_access_type)
    ])
    error_message = "Container access type must be 'private', 'blob', or 'container'."
  }
}
```

### 3. Comprehensive Validation

Always include validation with helpful error messages:

```hcl
variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters."
  }
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name can only contain lowercase letters and numbers."
  }
}
```

## Resource Implementation

### 1. Use Dynamic Blocks for Optional Features

```hcl
resource "azurerm_storage_account" "storage_account" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Required settings with secure defaults
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version          = var.security_settings.min_tls_version
  enable_https_traffic_only = var.security_settings.enable_https_traffic_only
  
  # Optional network rules
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    
    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.subnet_ids
      bypass                     = network_rules.value.bypass
    }
  }
  
  # Optional blob properties
  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? [var.blob_properties] : []
    
    content {
      versioning_enabled = try(blob_properties.value.versioning_enabled, false)
      
      dynamic "delete_retention_policy" {
        for_each = try(blob_properties.value.delete_retention_days, null) != null ? [1] : []
        
        content {
          days = blob_properties.value.delete_retention_days
        }
      }
    }
  }
}
```

### 2. Resource Creation with Iteration

```hcl
resource "azurerm_storage_container" "containers" {
  for_each = {
    for container in var.containers : container.name => container
  }
  
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = each.value.container_access_type
}
```

## Security Best Practices

### 1. Secure Defaults

Always set the most secure configuration as default:

```hcl
variable "security_settings" {
  type = object({
    enable_https_traffic_only       = optional(bool, true)
    min_tls_version                = optional(string, "TLS1_2")
    shared_access_key_enabled      = optional(bool, false)
    public_network_access_enabled  = optional(bool, false)
    infrastructure_encryption_enabled = optional(bool, true)
  })
  
  default = {}
}
```

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
module "storage" {
  source = "../../"
  
  name                = "stgexamplebasic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  tags = {
    Environment = "Test"
    ManagedBy   = "Terraform"
  }
}
```

### 2. Complete Example

Include a complete example showing all features:

```hcl
# examples/complete/main.tf
module "storage" {
  source = "../../"
  
  name                = "stgexamplecomplete"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind            = "BlockBlobStorage"
  
  security_settings = {
    enable_https_traffic_only = true
    min_tls_version          = "TLS1_2"
    shared_access_key_enabled = false
  }
  
  network_rules = {
    default_action = "Deny"
    ip_rules      = ["203.0.113.0/24"]
    subnet_ids    = [azurerm_subnet.example.id]
    bypass        = ["AzureServices"]
  }
  
  containers = [
    {
      name                  = "data"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

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

<!-- BEGIN_TF_DOCS -->
<!-- Automatically generated documentation -->
<!-- END_TF_DOCS -->

## Requirements
- Terraform >= 1.5.0
- AzureRM Provider >= 3.0

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
- [ ] Examples (basic and complete) are included
- [ ] Tests pass successfully
- [ ] Documentation is generated with terraform-docs
- [ ] CHANGELOG is updated

### 2. PR Guidelines

1. **Branch Naming**: `feature/module-<resource-name>` or `fix/module-<resource-name>-issue`
2. **Commit Messages**: Use conventional commits
   - `feat(storage): add support for encryption scopes`
   - `fix(storage): correct validation for container names`
   - `docs(storage): update examples with new features`

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