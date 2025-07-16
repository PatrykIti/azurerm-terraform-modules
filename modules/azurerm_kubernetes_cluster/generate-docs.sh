#!/bin/bash

# Generate documentation for azurerm_kubernetes_cluster module
# This script generates README.md using terraform-docs

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Generating documentation for azurerm_kubernetes_cluster module..."

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "Error: terraform-docs is not installed. Please install it first."
    echo "Visit: https://terraform-docs.io/user-guide/installation/"
    exit 1
fi

# Generate terraform-docs config if needed
if [[ -x "$MODULE_DIR/../../scripts/generate-terraform-docs-config.sh" ]]; then
    echo "Regenerating .terraform-docs.yml with current examples..."
    "$MODULE_DIR/../../scripts/generate-terraform-docs-config.sh" "$MODULE_DIR"
fi

# Generate documentation
echo "Generating README.md..."
terraform-docs markdown table --output-file README.md --output-mode inject "$MODULE_DIR"

echo "✅ Documentation generated successfully!"
echo ""
echo "Files updated:"
echo "  - README.md"
echo "  - .terraform-docs.yml (if examples changed)"