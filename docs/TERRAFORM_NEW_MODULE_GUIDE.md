# Terraform Azure Modules - New Module Creation Guide

This comprehensive guide walks you through the process of creating a new Terraform module in this repository, from initial setup to production-ready implementation.

## Table of Contents

1. [Overview](#overview)
2. [Module Planning](#module-planning)
3. [Module Structure](#module-structure)
4. [Step-by-Step Creation Process](#step-by-step-creation-process)
5. [Development Workflow](#development-workflow)
6. [Testing Strategy](#testing-strategy)
7. [Documentation Requirements](#documentation-requirements)
8. [CI/CD Integration](#cicd-integration)
9. [Module Publishing](#module-publishing)
10. [Checklist](#checklist)

## Overview

Creating a new Terraform module in this repository involves several steps to ensure consistency, quality, and maintainability. Each module should follow our established patterns and meet our quality standards.

### Module Naming Convention

Module names follow the pattern: `azurerm_<resource_type>` 

Examples:
- `azurerm_storage_account`
- `azurerm_virtual_network`
- `azurerm_key_vault`

## Module Planning

Before creating a module, consider:

### 1. Resource Scope
- Single resource or resource composition?
- Dependencies and relationships
- Common use cases and configurations

### 2. Security Requirements
- Default security settings
- Compliance requirements (SOC 2, ISO 27001, GDPR, PCI DSS)
- Network isolation options
- Identity and access management

### 3. Feature Coverage
- Basic configuration (minimum viable)
- Complete configuration (all features)
- Security-focused configuration
- Enterprise patterns

## Module Structure

```
modules/azurerm_<resource_name>/
├── examples/
│   ├── basic/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── complete/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── secure/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   └── private-endpoint/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
├── tests/
│   ├── fixtures/
│   │   ├── basic/
│   │   ├── complete/
│   │   ├── secure/
│   │   └── negative/
│   ├── unit/
│   │   ├── defaults.tftest.hcl
│   │   ├── naming.tftest.hcl
│   │   ├── outputs.tftest.hcl
│   │   └── validation.tftest.hcl
│   ├── go.mod
│   ├── go.sum
│   ├── Makefile
│   ├── test_helpers.go
│   ├── <module>_test.go
│   ├── integration_test.go
│   └── performance_test.go
├── .terraform-docs.yml
├── CHANGELOG.md
├── LICENSE
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── versions.tf
└── README.md
```

## Step-by-Step Creation Process

### Step 1: Create Module Directory

```bash
# Set module name
MODULE_NAME="azurerm_application_gateway"

# Create module structure
mkdir -p modules/${MODULE_NAME}/{examples/{basic,complete,secure,private-endpoint},tests/{fixtures/{basic,complete,secure,negative},unit}}

# Navigate to module directory
cd modules/${MODULE_NAME}
```

### Step 2: Create Core Module Files

#### versions.tf
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.36.0"
    }
  }
}
```

#### variables.tf
```hcl
# Resource naming
variable "name" {
  description = "Name of the Application Gateway. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition = alltrue([
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name)),
      length(var.name) >= 1,
      length(var.name) <= 80
    ])
    error_message = "Name must be 1-80 characters long, start with alphanumeric, and contain only letters, numbers, hyphens, periods, and underscores."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the Application Gateway will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Application Gateway will be created."
  type        = string
}

# Security variables with secure defaults
variable "enable_http2" {
  description = "Enable HTTP2 for the Application Gateway."
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for the Application Gateway."
  type        = string
  default     = "1.2"
  
  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be one of: 1.0, 1.1, 1.2, 1.3."
  }
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
```

#### main.tf
```hcl
# Local values for resource configuration
locals {
  # Merge default tags with user-provided tags
  tags = merge(
    {
      Module    = "azurerm_application_gateway"
      ManagedBy = "Terraform"
    },
    var.tags
  )

  # Security defaults
  ssl_policy = {
    policy_type          = "Predefined"
    policy_name          = "AppGwSslPolicy20220101"
    min_protocol_version = var.minimum_tls_version
  }
}

# Main resource
resource "azurerm_application_gateway" "application_gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU configuration
  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  # SSL Policy with secure defaults
  ssl_policy {
    policy_type          = local.ssl_policy.policy_type
    policy_name          = local.ssl_policy.policy_name
    min_protocol_version = local.ssl_policy.min_protocol_version
  }

  enable_http2 = var.enable_http2

  tags = local.tags

  # Lifecycle rules
  lifecycle {
    create_before_destroy = true
    
    # Prevent accidental changes to critical settings
    prevent_destroy = var.enable_deletion_protection
  }
}
```

#### outputs.tf
```hcl
output "id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.application_gateway.id
}

output "name" {
  description = "The name of the Application Gateway."
  value       = azurerm_application_gateway.application_gateway.name
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway."
  value       = azurerm_application_gateway.application_gateway.public_ip_address
}

output "backend_address_pools" {
  description = "The backend address pools of the Application Gateway."
  value       = azurerm_application_gateway.application_gateway.backend_address_pool
}
```

### Step 3: Create Examples

#### examples/basic/main.tf
```hcl
# Basic example with minimal configuration
module "application_gateway" {
  source = "../../"

  name                = "appgw-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Basic SKU configuration
  sku_name     = "Standard_v2"
  sku_tier     = "Standard_v2"
  sku_capacity = 2

  # Basic gateway configuration
  gateway_ip_configuration = {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.gateway.id
  }

  # Frontend configuration
  frontend_port = {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration = {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  # Backend configuration
  backend_address_pool = {
    name = "backend-pool"
  }

  backend_http_settings = {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  # Routing rules
  http_listener = {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule = {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
```

### Step 4: Create Test Structure

#### tests/go.mod
```go
module github.com/PatrykIti/azurerm-terraform-modules/modules/azurerm_application_gateway/tests

go 1.21

require (
    github.com/Azure/azure-sdk-for-go/sdk/azcore v1.12.0
    github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.6.0
    github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v5 v5.2.0
    github.com/gruntwork-io/terratest v0.46.7
    github.com/stretchr/testify v1.9.0
)
```

#### tests/application_gateway_test.go
```go
package test

import (
    "fmt"
    "testing"

    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
    "github.com/stretchr/testify/assert"
)

// TestApplicationGatewayModule runs all Application Gateway module tests
func TestApplicationGatewayModule(t *testing.T) {
    t.Parallel()

    // Run subtests
    t.Run("Basic", TestApplicationGatewayBasic)
    t.Run("Complete", TestApplicationGatewayComplete)
    t.Run("Secure", TestApplicationGatewaySecure)
    t.Run("WAF", TestApplicationGatewayWAF)
}

func TestApplicationGatewayBasic(t *testing.T) {
    t.Parallel()

    // Copy fixture to temp folder
    fixtureFolder := "azurerm_application_gateway/tests/fixtures/basic"
    tempFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", fixtureFolder)

    // Generate random suffix
    randomSuffix := random.UniqueId()

    terraformOptions := &terraform.Options{
        TerraformDir: tempFolder,
        Vars: map[string]interface{}{
            "random_suffix": randomSuffix,
        },
        NoColor: true,
    }

    // Save options for cleanup
    test_structure.SaveTerraformOptions(t, tempFolder, terraformOptions)

    // Cleanup
    defer test_structure.RunTestStage(t, "cleanup", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
        terraform.Destroy(t, terraformOptions)
    })

    // Deploy
    test_structure.RunTestStage(t, "deploy", func() {
        terraform.InitAndApply(t, terraformOptions)
    })

    // Validate
    test_structure.RunTestStage(t, "validate", func() {
        terraformOptions := test_structure.LoadTerraformOptions(t, tempFolder)
        validateBasicApplicationGateway(t, terraformOptions)
    })
}

func validateBasicApplicationGateway(t *testing.T, terraformOptions *terraform.Options) {
    // Get outputs
    appGwID := terraform.Output(t, terraformOptions, "id")
    appGwName := terraform.Output(t, terraformOptions, "name")
    publicIP := terraform.Output(t, terraformOptions, "public_ip_address")

    // Assertions
    assert.NotEmpty(t, appGwID)
    assert.Contains(t, appGwName, "appgw-")
    assert.NotEmpty(t, publicIP)
}
```

#### tests/Makefile
```makefile
# Makefile for Terratest execution

# Variables
TIMEOUT ?= 30m
TEST_FILTER ?= Test
PARALLEL ?= 8
AZURE_LOCATION ?= northeurope

# Environment check
check-env:
	@echo "Checking required environment variables..."
	@test -n "$(AZURE_SUBSCRIPTION_ID)" || (echo "AZURE_SUBSCRIPTION_ID is not set" && exit 1)
	@test -n "$(AZURE_TENANT_ID)" || (echo "AZURE_TENANT_ID is not set" && exit 1)
	@test -n "$(AZURE_CLIENT_ID)" || (echo "AZURE_CLIENT_ID is not set" && exit 1)
	@test -n "$(AZURE_CLIENT_SECRET)" || (echo "AZURE_CLIENT_SECRET is not set" && exit 1)
	@echo "All required environment variables are set."

# Install dependencies
deps:
	@echo "Installing Go dependencies..."
	go mod download
	go mod tidy

# Run all tests
test: check-env deps
	@echo "Running all tests..."
	go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...

# Run basic tests only
test-basic: check-env deps
	@echo "Running basic tests..."
	go test -v -timeout 15m -run TestApplicationGatewayBasic ./...

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	rm -f coverage.out coverage.html test-results.xml
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +

.PHONY: check-env deps test test-basic clean
```

### Step 5: Create Native Terraform Tests

#### tests/unit/defaults.tftest.hcl
```hcl
# Test default security settings
mock_provider "azurerm" {
  mock_resource "azurerm_application_gateway" {
    defaults = {
      id                 = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Network/applicationGateways/mock-appgw"
      public_ip_address  = "1.2.3.4"
    }
  }
}

variables {
  name                = "test-appgw"
  resource_group_name = "test-rg"
  location            = "northeurope"
  
  # Minimal required configuration for mock
  sku_name     = "Standard_v2"
  sku_tier     = "Standard_v2"
  sku_capacity = 2
}

# Test default security settings
run "verify_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_application_gateway.application_gateway.enable_http2 == true
    error_message = "HTTP2 should be enabled by default"
  }

  assert {
    condition     = azurerm_application_gateway.application_gateway.ssl_policy[0].min_protocol_version == "1.2"
    error_message = "Default TLS version should be 1.2"
  }
}
```

### Step 6: Configure Documentation

#### .terraform-docs.yml
```yaml
formatter: "markdown table"

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules

sections:
  hide: []
  show: []

content: |-
  {{ .Header }}

  ## Usage

  ```hcl
  {{ include "examples/basic/main.tf" }}
  ```

  ## Examples

  - [Basic](examples/basic) - Basic Application Gateway configuration
  - [Complete](examples/complete) - Complete configuration with all features
  - [Secure](examples/secure) - Security-hardened configuration
  - [WAF](examples/waf) - Web Application Firewall enabled configuration

  {{ .Requirements }}

  {{ .Providers }}

  {{ .Modules }}

  {{ .Resources }}

  {{ .Inputs }}

  {{ .Outputs }}

  ## Security Considerations

  This module implements several security best practices:
  - TLS 1.2 minimum by default
  - HTTP2 enabled by default
  - Secure SSL policy configured
  - Support for Web Application Firewall (WAF)
  - Network isolation options

  ## Compliance

  This module supports the following compliance standards:
  - SOC 2 Type II
  - ISO 27001:2022
  - PCI DSS v4.0
  - GDPR

  {{ .Footer }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

## Development Workflow

### 1. Initial Development

```bash
# Create branch
git checkout -b feature/add-application-gateway-module

# Initialize module
cd modules/azurerm_application_gateway
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Generate documentation
terraform-docs .
```

### 2. Local Testing

```bash
# Run unit tests
cd tests/unit
terraform test

# Run integration tests
cd ..
go test -v -run TestApplicationGatewayBasic -timeout 30m
```

### 3. Security Scanning

```bash
# Run tfsec
tfsec . --minimum-severity HIGH

# Run checkov
checkov -d . --framework terraform

# Run tflint
tflint --init
tflint
```

## Testing Strategy

### Unit Tests (Fast)
- Variable validation
- Default values
- Output formatting
- Conditional logic

### Integration Tests (Real Resources)
- Basic deployment
- Complete configuration
- Security features
- Network connectivity
- Performance benchmarks

### Negative Tests
- Invalid inputs
- Resource conflicts
- Quota limits
- Permission issues

## Documentation Requirements

### README.md Structure

1. **Module Overview**
   - Purpose and use cases
   - Features supported
   - Architecture diagram (if complex)

2. **Usage Examples**
   - Basic example
   - Complete example
   - Links to more examples

3. **Requirements**
   - Terraform version
   - Provider version
   - Azure permissions needed

4. **Inputs/Outputs**
   - Auto-generated by terraform-docs
   - Include descriptions and defaults

5. **Security Considerations**
   - Default security settings
   - Best practices
   - Compliance information

### Example Documentation

Each example must include:
- `README.md` - Example description and usage
- `main.tf` - Example configuration
- `variables.tf` - Required variables
- `outputs.tf` - Example outputs
- `terraform.tfvars.example` - Sample values

## CI/CD Integration

### 1. Add Module to CI Matrix

Update `.github/workflows/module-ci.yml`:

```yaml
strategy:
  matrix:
    module:
      - storage_account
      - virtual_network
      - application_gateway  # Add new module
```

### 2. Configure Composite Action

Create `.github/actions/module-application_gateway/action.yml`:

```yaml
name: 'Test Application Gateway Module'
description: 'Run tests for Application Gateway module'

runs:
  using: "composite"
  steps:
    - name: Run Unit Tests
      shell: bash
      run: |
        cd modules/azurerm_application_gateway
        terraform init
        terraform test

    - name: Run Integration Tests
      shell: bash
      run: |
        cd modules/azurerm_application_gateway/tests
        go test -v -timeout 30m ./...
```

### 3. Add to Release Configuration

Create `.releaserc.js` in module directory:

```javascript
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    ['@semantic-release/git', {
      assets: ['CHANGELOG.md'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }],
    '@semantic-release/github'
  ]
};
```

## Module Publishing

### Pre-release Checklist

- [ ] All tests passing
- [ ] Documentation complete
- [ ] Examples working
- [ ] Security scan clean
- [ ] Peer review completed

### Release Process

1. **Create PR**
   ```bash
   git add .
   git commit -m "feat: add application gateway module"
   git push origin feature/add-application-gateway-module
   ```

2. **PR Description Template**
   ```markdown
   ## New Module: azurerm_application_gateway

   ### Overview
   Adds support for Azure Application Gateway with security-first defaults.

   ### Features
   - [x] Basic configuration
   - [x] WAF support
   - [x] SSL/TLS configuration
   - [x] Health probes
   - [x] Multi-site hosting

   ### Testing
   - [x] Unit tests
   - [x] Integration tests
   - [x] Security scanning
   - [x] Documentation

   ### Checklist
   - [x] Follows module structure
   - [x] Includes all examples
   - [x] Documentation complete
   - [x] CI/CD configured
   ```

3. **Post-merge**
   - Semantic release creates version tag
   - CHANGELOG.md updated automatically
   - GitHub release created

## Checklist

### Module Structure
- [ ] Created all required directories
- [ ] Implemented main.tf with security defaults
- [ ] Created comprehensive variables.tf with validation
- [ ] Defined useful outputs.tf
- [ ] Added versions.tf with constraints
- [ ] Created locals.tf for computed values

### Examples
- [ ] Basic example (minimal configuration)
- [ ] Complete example (all features)
- [ ] Secure example (hardened configuration)
- [ ] Network isolated example (if applicable)
- [ ] Each example has README.md

### Testing
- [ ] Unit tests with Terraform native tests
- [ ] Integration tests with Terratest
- [ ] Performance tests
- [ ] Negative test cases
- [ ] Test fixtures for each example
- [ ] Makefile for test execution

### Documentation
- [ ] README.md with terraform-docs
- [ ] Security considerations documented
- [ ] Compliance information included
- [ ] Architecture diagram (if complex)
- [ ] Migration guide (if replacing existing module)

### Security
- [ ] Secure defaults implemented
- [ ] No hardcoded secrets
- [ ] Encryption enabled by default
- [ ] Network isolation supported
- [ ] RBAC considerations documented

### CI/CD
- [ ] Added to test matrix
- [ ] Composite action created
- [ ] Release configuration added
- [ ] All workflows passing

### Code Quality
- [ ] Code formatted with `terraform fmt`
- [ ] No linting errors
- [ ] Security scan passing
- [ ] Variable validation comprehensive
- [ ] Error messages helpful

### Review
- [ ] Self-review completed
- [ ] Peer review requested
- [ ] Feedback addressed
- [ ] Ready for production use

## Next Steps

After creating your module:

1. **Get Feedback Early**
   - Share draft PR for architecture review
   - Test with real use cases
   - Gather security team input

2. **Iterate Based on Usage**
   - Monitor issues and questions
   - Add features based on demand
   - Improve documentation continuously

3. **Maintain Actively**
   - Keep provider version updated
   - Add new Azure features
   - Address security advisories
   - Respond to community feedback

## Support

For questions or issues:
- Open an issue in the repository
- Check existing modules for patterns
- Review the [contribution guide](../CONTRIBUTING.md)
- Join our community discussions

Remember: Quality over quantity. It's better to have a well-tested, documented, and secure module than to rush implementation.