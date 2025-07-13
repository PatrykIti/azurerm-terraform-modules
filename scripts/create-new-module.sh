#!/bin/bash
set -euo pipefail

# Script to create a new Terraform module from templates
# Usage: ./scripts/create-new-module.sh <module_name> <display_name> <prefix> <scope> <description>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
MODULES_DIR="$REPO_ROOT/modules"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 <module_name> <display_name> <prefix> <scope> <description>

Arguments:
  module_name    - Technical name (e.g., azurerm_virtual_network)
  display_name   - Human-readable name (e.g., "Virtual Network")
  prefix         - Version prefix (e.g., VN for Virtual Network)
  scope          - Commit scope (e.g., virtual-network)
  description    - Brief module description

Example:
  $0 azurerm_virtual_network "Virtual Network" VN virtual-network "Manages Azure Virtual Networks with subnets and peering"

EOF
    exit 1
}

# Check arguments
if [ $# -ne 5 ]; then
    print_error "Invalid number of arguments"
    usage
fi

MODULE_NAME="$1"
DISPLAY_NAME="$2"
PREFIX="$3"
SCOPE="$4"
DESCRIPTION="$5"

# Derive module type from name (remove azurerm_ prefix)
MODULE_TYPE="${MODULE_NAME#azurerm_}"

# Validate module doesn't already exist
if [ -d "$MODULES_DIR/$MODULE_NAME" ]; then
    print_error "Module $MODULE_NAME already exists!"
    exit 1
fi

print_info "Creating new module: $MODULE_NAME"
print_info "Display name: $DISPLAY_NAME"
print_info "Version prefix: ${PREFIX}v"
print_info "Commit scope: $SCOPE"

# Create module directory structure
MODULE_DIR="$MODULES_DIR/$MODULE_NAME"
mkdir -p "$MODULE_DIR"
mkdir -p "$MODULE_DIR/.github"
mkdir -p "$MODULE_DIR/examples/basic"
mkdir -p "$MODULE_DIR/examples/complete"
mkdir -p "$MODULE_DIR/examples/secure"
mkdir -p "$MODULE_DIR/examples/private-endpoint"
mkdir -p "$MODULE_DIR/docs"
mkdir -p "$MODULE_DIR/tests"
mkdir -p "$MODULE_DIR/tests/fixtures/basic"
mkdir -p "$MODULE_DIR/tests/fixtures/complete"
mkdir -p "$MODULE_DIR/tests/fixtures/secure"
mkdir -p "$MODULE_DIR/tests/fixtures/private_endpoint"
mkdir -p "$MODULE_DIR/tests/fixtures/network"
mkdir -p "$MODULE_DIR/tests/fixtures/negative"

print_info "Created directory structure"

# Function to replace placeholders in a file
replace_placeholders() {
    local file="$1"
    local date=$(date +%Y-%m-%d)
    
    # Detect OS and use appropriate sed syntax
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' \
            -e "s/MODULE_NAME_PLACEHOLDER/$MODULE_NAME/g" \
            -e "s/MODULE_DISPLAY_NAME_PLACEHOLDER/$DISPLAY_NAME/g" \
            -e "s/MODULE_TYPE_PLACEHOLDER/$MODULE_TYPE/g" \
            -e "s/MODULE_DESCRIPTION_PLACEHOLDER/$DESCRIPTION/g" \
            -e "s/PREFIX_PLACEHOLDER/$PREFIX/g" \
            -e "s/SCOPE_PLACEHOLDER/$SCOPE/g" \
            -e "s/DATE_PLACEHOLDER/$date/g" \
            -e "s/CATEGORY_PLACEHOLDER/uncategorized/g" \
            -e "s/SERVICE_PLACEHOLDER/$DISPLAY_NAME/g" \
            -e "s/MAINTAINER_PLACEHOLDER/Team/g" \
            -e "s/MODULE_SUBRESOURCE_PLACEHOLDER/${MODULE_TYPE}/g" \
            "$file"
    else
        # Linux and other Unix-like systems
        sed -i \
            -e "s/MODULE_NAME_PLACEHOLDER/$MODULE_NAME/g" \
            -e "s/MODULE_DISPLAY_NAME_PLACEHOLDER/$DISPLAY_NAME/g" \
            -e "s/MODULE_TYPE_PLACEHOLDER/$MODULE_TYPE/g" \
            -e "s/MODULE_DESCRIPTION_PLACEHOLDER/$DESCRIPTION/g" \
            -e "s/PREFIX_PLACEHOLDER/$PREFIX/g" \
            -e "s/SCOPE_PLACEHOLDER/$SCOPE/g" \
            -e "s/DATE_PLACEHOLDER/$date/g" \
            -e "s/CATEGORY_PLACEHOLDER/uncategorized/g" \
            -e "s/SERVICE_PLACEHOLDER/$DISPLAY_NAME/g" \
            -e "s/MAINTAINER_PLACEHOLDER/Team/g" \
            -e "s/MODULE_SUBRESOURCE_PLACEHOLDER/${MODULE_TYPE}/g" \
            "$file"
    fi
}

# Copy and process templates
print_info "Copying templates..."

# Core Terraform files
cp "$TEMPLATES_DIR/main.tf" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/variables.tf" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/outputs.tf" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/versions.tf" "$MODULE_DIR/"

# Documentation files
cp "$TEMPLATES_DIR/README.md" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/CHANGELOG.md" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/CONTRIBUTING.md" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/VERSIONING.md" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/SECURITY.md" "$MODULE_DIR/"

# Configuration files
cp "$TEMPLATES_DIR/.releaserc.js" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/module-config.yml" "$MODULE_DIR/.github/"

# Scripts
cp "$TEMPLATES_DIR/generate-docs.sh" "$MODULE_DIR/"
chmod +x "$MODULE_DIR/generate-docs.sh"

# Makefile
cp "$TEMPLATES_DIR/Makefile" "$MODULE_DIR/"

# Test files
cp "$TEMPLATES_DIR/go.mod" "$MODULE_DIR/tests/"
cp "$TEMPLATES_DIR/module_test.go" "$MODULE_DIR/tests/"
cp "$TEMPLATES_DIR/test_helpers.go" "$MODULE_DIR/tests/"
cp "$TEMPLATES_DIR/test_config.yaml" "$MODULE_DIR/tests/"
cp "$TEMPLATES_DIR/tests_README.md" "$MODULE_DIR/tests/README.md"

# Replace placeholders in all copied files
print_info "Customizing templates..."
find "$MODULE_DIR" -type f -name "*.tf" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.js" -o -name "*.go" -o -name "*.mod" -o -name "*.sh" | while read -r file; do
    replace_placeholders "$file"
done

# Create example files
print_info "Creating examples..."

# Create function for generating example READMEs
generate_example_readme() {
    local example_type="$1"
    local example_dir="$2"
    local module_type="$3"
    local display_name="$4"
    
    case "$example_type" in
        basic)
            cat > "$example_dir/README.md" << EOF
# Basic $display_name Example

This example demonstrates a basic $display_name configuration using secure defaults and minimal setup.

## Features

- Creates a basic $module_type with standard configuration
- Uses secure defaults following Azure best practices
- Creates a dedicated resource group
- Demonstrates basic module usage patterns
- Uses variables for configuration flexibility

## Key Configuration

This example uses secure defaults and demonstrates:
- Basic resource creation with minimal configuration
- Using variables for easy configuration customization
- Following security best practices by default

## Usage

\`\`\`bash
terraform init
terraform plan
terraform apply
\`\`\`

## Cleanup

\`\`\`bash
terraform destroy
\`\`\`

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
EOF
            ;;
        complete)
            cat > "$example_dir/README.md" << EOF
# Complete $display_name Example

This example demonstrates a comprehensive deployment of $display_name with all available features and configurations.

## Features

- Full $module_type configuration with all features enabled
- Advanced networking configuration
- Diagnostic settings for monitoring and auditing
- Complete lifecycle management
- Advanced security settings
- High availability configuration

## Key Configuration

This comprehensive example showcases all available features of the $module_type module, demonstrating enterprise-grade capabilities suitable for production environments.

## Usage

\`\`\`bash
terraform init
terraform plan
terraform apply
\`\`\`

## Cleanup

\`\`\`bash
terraform destroy
\`\`\`

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
EOF
            ;;
        secure)
            cat > "$example_dir/README.md" << EOF
# Secure $display_name Example

This example demonstrates a maximum-security $display_name configuration suitable for highly sensitive data and regulated environments.

## Features

- Maximum security configuration with all security features enabled
- Network isolation and private endpoints
- Advanced threat protection
- Comprehensive audit logging and monitoring
- Encryption at rest and in transit
- Compliance-ready configuration

## Key Configuration

This example implements defense-in-depth security principles with multiple layers of protection suitable for highly regulated industries and sensitive workloads.

## Security Considerations

- All public access is disabled by default
- Network access is restricted to specific IP ranges
- All data is encrypted at rest and in transit
- Audit logging captures all access and modifications

## Usage

\`\`\`bash
terraform init
terraform plan
terraform apply
\`\`\`

## Cleanup

\`\`\`bash
terraform destroy
\`\`\`

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
EOF
            ;;
        private-endpoint)
            cat > "$example_dir/README.md" << EOF
# Private Endpoint $display_name Example

This example demonstrates a $display_name configuration with private endpoint connectivity for enhanced security and network isolation.

## Features

- Creates a $module_type with private endpoint access
- Disables public network access for maximum security
- Configures virtual network and subnet for private connectivity
- Demonstrates private DNS integration
- Network isolation and secure connectivity patterns
- Enterprise-grade security configuration

## Key Configuration

This example showcases private endpoint implementation with complete network isolation, suitable for enterprise environments requiring secure connectivity without public internet exposure.

## Network Architecture

- Virtual Network with dedicated subnet for private endpoints
- Private endpoint connection to the $module_type
- DNS resolution for private connectivity
- Network security group rules (if applicable)

## Usage

\`\`\`bash
terraform init
terraform plan
terraform apply
\`\`\`

## Cleanup

\`\`\`bash
terraform destroy
\`\`\`

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
EOF
            ;;
    esac
}

# Basic example
cat > "$MODULE_DIR/examples/basic/main.tf" << EOF
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${MODULE_TYPE}-basic-example"
  location = "West Europe"
}

module "$MODULE_TYPE" {
  source = "../../"

  name                = "${MODULE_TYPE//_/}example001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
EOF

cat > "$MODULE_DIR/examples/basic/variables.tf" << EOF
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}
EOF

cat > "$MODULE_DIR/examples/basic/outputs.tf" << EOF
output "${MODULE_TYPE}_id" {
  description = "The ID of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.id
}

output "${MODULE_TYPE}_name" {
  description = "The name of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.name
}
EOF

# Generate README for basic example
generate_example_readme "basic" "$MODULE_DIR/examples/basic" "$MODULE_TYPE" "$DISPLAY_NAME"

# Create complete example files
cat > "$MODULE_DIR/examples/complete/main.tf" << EOF
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${MODULE_TYPE}-complete-example"
  location = "West Europe"
}

module "$MODULE_TYPE" {
  source = "../../"

  name                = "${MODULE_TYPE//_/}example002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
EOF

cat > "$MODULE_DIR/examples/complete/variables.tf" << EOF
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}
EOF

cat > "$MODULE_DIR/examples/complete/outputs.tf" << EOF
output "${MODULE_TYPE}_id" {
  description = "The ID of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.id
}

output "${MODULE_TYPE}_name" {
  description = "The name of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.name
}
EOF

# Generate README for complete example
generate_example_readme "complete" "$MODULE_DIR/examples/complete" "$MODULE_TYPE" "$DISPLAY_NAME"

# Create secure example files
cat > "$MODULE_DIR/examples/secure/main.tf" << EOF
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${MODULE_TYPE}-secure-example"
  location = "West Europe"
}

module "$MODULE_TYPE" {
  source = "../../"

  name                = "${MODULE_TYPE//_/}example003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
EOF

cat > "$MODULE_DIR/examples/secure/variables.tf" << EOF
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}
EOF

cat > "$MODULE_DIR/examples/secure/outputs.tf" << EOF
output "${MODULE_TYPE}_id" {
  description = "The ID of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.id
}

output "${MODULE_TYPE}_name" {
  description = "The name of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.name
}
EOF

# Generate README for secure example
generate_example_readme "secure" "$MODULE_DIR/examples/secure" "$MODULE_TYPE" "$DISPLAY_NAME"

# Create private-endpoint example files
cat > "$MODULE_DIR/examples/private-endpoint/main.tf" << EOF
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${MODULE_TYPE}-private-endpoint-example"
  location = "West Europe"
}

# Virtual Network for private endpoint
resource "azurerm_virtual_network" "example" {
  name                = "vnet-${MODULE_TYPE}-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = "subnet-private-endpoint"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "$MODULE_TYPE" {
  source = "../../"

  name                = "${MODULE_TYPE//_/}example004"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable public access for private endpoint scenario
  security_settings = {
    public_network_access_enabled = false
  }

  # Configure private endpoint
  private_endpoints = [
    {
      name      = "pe-${MODULE_TYPE}-example"
      subnet_id = azurerm_subnet.private_endpoint.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Private-Endpoint"
  }
}
EOF

cat > "$MODULE_DIR/examples/private-endpoint/variables.tf" << EOF
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}
EOF

cat > "$MODULE_DIR/examples/private-endpoint/outputs.tf" << EOF
output "${MODULE_TYPE}_id" {
  description = "The ID of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.id
}

output "${MODULE_TYPE}_name" {
  description = "The name of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.name
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.${MODULE_TYPE}.private_endpoints
}
EOF

# Generate README for private-endpoint example
generate_example_readme "private-endpoint" "$MODULE_DIR/examples/private-endpoint" "$MODULE_TYPE" "$DISPLAY_NAME"

# Create test fixtures by copying examples
print_info "Creating test fixtures..."

# Copy examples to test fixtures
cp -r "$MODULE_DIR/examples/basic/"* "$MODULE_DIR/tests/fixtures/basic/"
cp -r "$MODULE_DIR/examples/complete/"* "$MODULE_DIR/tests/fixtures/complete/"
cp -r "$MODULE_DIR/examples/secure/"* "$MODULE_DIR/tests/fixtures/secure/"
cp -r "$MODULE_DIR/examples/private-endpoint/"* "$MODULE_DIR/tests/fixtures/private_endpoint/"

# Create additional test fixtures
cat > "$MODULE_DIR/tests/fixtures/network/main.tf" << EOF
# Network integration test fixture
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-${MODULE_TYPE}-network-test"
  location = "West Europe"
}

# Test with network rules
module "$MODULE_TYPE" {
  source = "../../../"

  name                = "${MODULE_TYPE//_/}networktest"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
    bypass         = ["AzureServices"]
  }

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
EOF

cat > "$MODULE_DIR/tests/fixtures/negative/main.tf" << EOF
# Negative test cases - should fail validation
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-${MODULE_TYPE}-negative-test"
  location = "West Europe"
}

# This should fail due to invalid name
module "$MODULE_TYPE" {
  source = "../../../"

  name                = "INVALID-NAME-WITH-UPPERCASE"  # Should fail validation
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
EOF

# Create docs README
cat > "$MODULE_DIR/docs/README.md" << EOF
# $DISPLAY_NAME Module Documentation

## Overview

This directory contains additional documentation for the $DISPLAY_NAME module.

## Contents

- Architecture diagrams (coming soon)
- Best practices guide (coming soon)
- Troubleshooting guide (coming soon)
- Migration guides (coming soon)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
EOF

# Copy static terraform-docs configuration for main module
print_info "Copying terraform-docs configuration..."
if [[ -f "$TEMPLATES_DIR/module-terraform-docs.yml" ]]; then
    cp "$TEMPLATES_DIR/module-terraform-docs.yml" "$MODULE_DIR/.terraform-docs.yml"
else
    print_warning "module-terraform-docs.yml template not found - module will need manual configuration"
fi

# Generate terraform-docs configuration for all examples
print_info "Generating terraform-docs configuration for examples..."
if [[ -f "$TEMPLATES_DIR/example-terraform-docs.yml" ]]; then
    for example_dir in "$MODULE_DIR/examples"/*; do
        if [[ -d "$example_dir" ]]; then
            example_name=$(basename "$example_dir")
            print_info "  - Creating terraform-docs config for example: $example_name"
            cp "$TEMPLATES_DIR/example-terraform-docs.yml" "$example_dir/.terraform-docs.yml"
        fi
    done
else
    print_warning "example-terraform-docs.yml template not found - examples will need manual configuration"
fi

# Add to workflow choices
print_info "Updating workflow configurations..."

# This would need to be done manually or via a more complex script
print_warning "Remember to manually add '$MODULE_NAME' to:"
print_warning "  - .github/workflows/module-ci.yml (workflow_dispatch choices)"
print_warning "  - .github/workflows/module-release.yml (workflow_dispatch choices)"
print_warning "  - .github/workflows/pr-validation.yml (if needed)"

print_info "Module scaffold created successfully!"
print_info ""
print_info "Next steps:"
print_info "1. Implement the main resource in main.tf"
print_info "2. Update variables.tf with module-specific variables"
print_info "3. Update outputs.tf with actual outputs"
print_info "4. Generate documentation:"
print_info "   cd $MODULE_DIR"
print_info "   terraform-docs markdown table --output-file README.md --output-mode inject ."
print_info "   ./scripts/update-examples-list.sh ."
print_info "5. Create complete, secure, and private-endpoint examples"
print_info "6. Write tests for the module"
print_info "7. Update the module category in .github/module-config.yml"
print_info "8. Commit with: git commit -m \"feat($SCOPE): initial $MODULE_TYPE module scaffold\""

echo ""
print_info "Module location: $MODULE_DIR"