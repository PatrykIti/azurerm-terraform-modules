# 6. Module Examples

Examples are one of the most important parts of a module. They provide users with a practical, runnable starting point for various use cases. Each module MUST include a set of standard examples.

## Philosophy of Examples

- **Practical**: Examples should represent real-world use cases.
- **Self-Contained**: Each example should be runnable without requiring complex external setup. AzureRM examples should create their own resource group and dependencies where feasible. Azure DevOps examples may require an existing project ID and should keep dependencies minimal and explicit.
- **Documented**: Every example MUST have its own `README.md` explaining its purpose, architecture, and how to run it.
- **Minimal**: Examples should only contain the code necessary to demonstrate their specific use case.

## Standard Example Scenarios

Each module should, at a minimum, include the following examples. Add other use-case-specific examples as needed (e.g., `diagnostic-settings`, `multi-node-pool`, `workload-identity`). The AKS module is the baseline, but examples may differ when a resource has a different feature set.

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
- **`variables.tf`**: Defines any variables needed for the example. Often, this is just for a `location` and fixed resource names.
- **`outputs.tf`**: Outputs any useful information from the created resources.
- **`README.md`**: A dedicated documentation file for the example.
- **`.terraform-docs.yml`**: Example-level terraform-docs configuration (AKS pattern).

## Resource Naming Conventions for Examples

All examples MUST follow the naming patterns from `azurerm_kubernetes_cluster`, which is the gold standard for this repository.

### Azure DevOps Modules

Azure DevOps examples should use fixed, deterministic names (no random suffixes) and keep them short.
Use a consistent prefix like:
- `ado-<resource>-basic`
- `ado-<resource>-complete`
- `ado-<resource>-secure`

If a name must be unique in the org, allow overrides via variables but keep the defaults stable.

### Standard Naming Pattern

Resources in examples should use fixed names with this pattern:
- **Format**: `{prefix}-{module-or-resource}-{example-type}-example`
- **Fixed names only** (no random suffixes in examples).
- If a resource requires global uniqueness, use a fixed, compliant name and allow overrides via variables.

### Resource Prefix Standards (AKS-aligned examples)

| Resource Type | Prefix | Example |
|--------------|--------|---------|
| Resource Group | `rg-` | `rg-aks-basic-example` |
| Virtual Network | `vnet-` | `vnet-aks-complete-example` |
| Subnet | `snet-` | `snet-aks-nodes-example` |
| Network Security Group | `nsg-` | `nsg-aks-nodes-example` |
| Log Analytics Workspace | `law-` | `law-aks-complete-example` |
| User Assigned Identity | `uai-` | `uai-aks-complete-example` |
| AKS Cluster | `aks-` | `aks-basic-example` |

### Example-Specific Guidelines

#### Basic Examples
- Use **fixed names** with variables and defaults.
- Pattern: `{prefix}-{module}-basic-example`.

#### Complete Examples
- Use **fixed names** (no random suffixes).
- Pattern: `{prefix}-{module}-complete-example`.
- Focus on feature coverage (networking, identity, monitoring).

#### Secure Examples
- Use **fixed names** (no random suffixes).
- Pattern: `{prefix}-{module}-secure-example`.
- Emphasize security-hardening features.

### Important Notes

1. **Resource naming constraints**: Some Azure resources (e.g., storage accounts) have stricter naming rules (lowercase, no hyphens). Use fixed, compliant names in examples.
2. **Special Azure requirements**: Some resources have mandatory names (e.g., `AzureFirewallSubnet`). Follow the provider requirements exactly.
3. **Tests vs examples**: Dynamic/random names are used only in Go-based E2E tests under `tests/`.

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
