# 6. Module Examples

Examples are one of the most important parts of a module. They provide users with a practical, runnable starting point for various use cases. Each module MUST include a set of standard examples.

## Philosophy of Examples

- **Practical**: Examples should represent real-world use cases.
- **Self-Contained**: Each example should be runnable without requiring complex external setup. It should create its own resource group and other dependencies where feasible.
- **Documented**: Every example MUST have its own `README.md` explaining its purpose, architecture, and how to run it.
- **Minimal**: Examples should only contain the code necessary to demonstrate their specific use case.

## Standard Example Scenarios

Each module should, at a minimum, include the following examples. Add other use-case-specific examples as needed (e.g., `private-endpoint`).

### 1. `basic`

A minimal configuration that demonstrates the simplest way to get the module up and running.
- It should use as many secure defaults from the module as possible.
- It serves as the primary usage example embedded in the main `README.md`.

### 2. `complete`

A comprehensive configuration that showcases most or all of the module's features.
- This is for advanced users who want to understand the full capabilities of the module.
- It often includes more complex networking, identity, and monitoring setups.

### 3. `secure`

A configuration that is hardened for production or security-sensitive environments.
- It should enable all security-related features (e.g., private endpoints, disabled public access, advanced threat protection).
- The `SECURITY.md` file in the module root should reference this example.

## Example Structure

Each example is a self-contained Terraform configuration and MUST have the following files:

- **`main.tf`**: The main configuration file for the example. It should call the module and set up any necessary dependencies (like a resource group or virtual network).
- **`variables.tf`**: Defines any variables needed for the example. Often, this is just for a `location` or a random suffix for resource naming.
- **`outputs.tf`**: Outputs any useful information from the created resources.
- **`README.md`**: A dedicated documentation file for the example.

## Resource Naming Conventions for Examples

All examples MUST follow the established resource naming patterns from the `azurerm_storage_account` and `azurerm_virtual_network` modules, which were the first modules created and set the standard for this repository.

### Standard Naming Pattern

Resources in examples should use the following naming pattern:
- **Format**: `{prefix}-{resource-type}-{example-type}-example`
- **No random suffixes in basic examples** (use fixed names for simplicity)
- **Random suffixes only where needed** (complete/secure examples for uniqueness)

### Resource Prefix Standards

| Resource Type | Prefix | Example |
|--------------|--------|---------|
| Resource Group | `rg-` | `rg-storage-basic-example` |
| Virtual Network | `vnet-` | `vnet-storage-complete-example` |
| Subnet | `snet-` or `subnet-` | `snet-private-endpoints` |
| Storage Account | `st` | `stexamplebasic001` (no hyphens) |
| Network Security Group | `nsg-` | `nsg-storage-secure-example` |
| Log Analytics Workspace | `law-` | `law-storage-example-${random_suffix}` |
| Key Vault | `kv-` | `kv-storage-${random_suffix}` |
| User Assigned Identity | `id-` | `id-storage-cmk-${random_suffix}` |
| Route Table | `rt-` | `rt-network-basic-example` |
| DDoS Protection Plan | `ddos-` | `ddos-vnet-secure-example` |
| Network Watcher | `nw-` | `nw-vnet-example-${location}` |
| Private Endpoint | `pe-` | `pe-storage-blob` |

### Example-Specific Guidelines

#### Basic Examples
- Use **fixed names** with variables and defaults
- Pattern: `{prefix}-{resource-type}-basic-example`
- Example: `var.resource_group_name` with default `"rg-storage-basic-example"`

#### Complete Examples
- Use **fixed base names** with optional random suffixes for globally unique resources
- Pattern: `{prefix}-{resource-type}-complete-example[-${random_suffix}]`
- Example: `"rg-storage-complete-example"` (no suffix for RG)
- Example: `"stcomplete${random_string.suffix.result}"` (suffix for storage account)

#### Secure Examples
- Similar to complete examples but emphasize security features
- Pattern: `{prefix}-{resource-type}-secure-example[-${random_suffix}]`
- Use random suffixes for resources requiring uniqueness

### Random Suffix Implementation

When random suffixes are needed:
```hcl
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
```

### Important Notes

1. **Storage Account Names**: Due to Azure limitations, storage account names cannot contain hyphens and must be lowercase. Use patterns like `stexamplebasic001` or `stcomplete${random_suffix}`.

2. **Fixed vs Random Names**: Basic examples should prefer fixed names for simplicity. Complete and secure examples should use random suffixes where global uniqueness is required.

3. **Special Azure Requirements**: Some resources have specific naming requirements (e.g., `AzureFirewallSubnet` must be named exactly as shown).

4. **Test Fixtures**: Note that test fixtures (in `/tests/` directories) follow a different pattern described in the Testing Guide.

### Example `README.md` Template

The `README.md` within each example directory is crucial for context.

**Template (`examples/basic/README.md`):**
```markdown
# Basic <MODULE_TITLE> Example

This example demonstrates a basic deployment of the <MODULE_TITLE> module with secure defaults.

## Features

- Creates a <resource_name> with a standard configuration.
- Demonstrates the minimal required variables to get the module running.

## Architecture

(Optional) A simple diagram or description of the resources being created.

```
Resource Group
└── <Resource Name>
```

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->
```
