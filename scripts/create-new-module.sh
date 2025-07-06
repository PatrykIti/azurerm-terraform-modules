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
mkdir -p "$MODULE_DIR/examples/simple"
mkdir -p "$MODULE_DIR/examples/complete"
mkdir -p "$MODULE_DIR/examples/secure"
mkdir -p "$MODULE_DIR/docs"
mkdir -p "$MODULE_DIR/tests"

print_info "Created directory structure"

# Function to replace placeholders in a file
replace_placeholders() {
    local file="$1"
    local date=$(date +%Y-%m-%d)
    
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
        -e "s/MODULE_SUBRESOURCE_PLACEHOLDER/default/g" \
        "$file"
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
cp "$TEMPLATES_DIR/.terraform-docs.yml" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/.releaserc.js" "$MODULE_DIR/"
cp "$TEMPLATES_DIR/module-config.yml" "$MODULE_DIR/.github/"

# Replace placeholders in all copied files
print_info "Customizing templates..."
find "$MODULE_DIR" -type f -name "*.tf" -o -name "*.md" -o -name "*.yml" -o -name "*.js" | while read -r file; do
    replace_placeholders "$file"
done

# Create example files
print_info "Creating examples..."

# Simple example
cat > "$MODULE_DIR/examples/simple/main.tf" << EOF
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${MODULE_TYPE}-simple-example"
  location = "West Europe"
}

module "$MODULE_TYPE" {
  source = "../../"

  name                = "${MODULE_TYPE//_/}example001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Simple"
  }
}
EOF

cat > "$MODULE_DIR/examples/simple/outputs.tf" << EOF
output "${MODULE_TYPE}_id" {
  description = "The ID of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.id
}

output "${MODULE_TYPE}_name" {
  description = "The name of the created $DISPLAY_NAME"
  value       = module.${MODULE_TYPE}.name
}
EOF

cat > "$MODULE_DIR/examples/simple/README.md" << EOF
# Simple $DISPLAY_NAME Example

This example shows basic usage of the $DISPLAY_NAME module with minimal configuration.

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
EOF

# Create a basic test file
cat > "$MODULE_DIR/tests/module_test.go" << EOF
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestModule(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Add assertions here
	outputID := terraform.Output(t, terraformOptions, "${MODULE_TYPE}_id")
	assert.NotEmpty(t, outputID)
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
print_info "4. Run terraform-docs to generate initial README content:"
print_info "   cd $MODULE_DIR && terraform-docs markdown table --output-file README.md --output-mode inject ."
print_info "5. Create complete and secure examples"
print_info "6. Write tests for the module"
print_info "7. Update the module category in .github/module-config.yml"
print_info "8. Commit with: git commit -m \"feat($SCOPE): initial $MODULE_TYPE module scaffold\""

echo ""
print_info "Module location: $MODULE_DIR"