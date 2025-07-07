#!/bin/bash

# Update all example documentation with terraform-docs
# This script generates terraform-docs configs and updates README files for all examples

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to update a single example
update_example_docs() {
    local example_dir="$1"
    local example_name=$(basename "$example_dir")
    
    echo "Processing example: $example_name"
    
    # Generate terraform-docs config
    "$SCRIPT_DIR/generate-example-terraform-docs-config.sh" "$example_dir"
    
    # Update the documentation
    cd "$example_dir"
    terraform-docs markdown table . > /dev/null 2>&1 || true
    cd - > /dev/null
    
    echo "✅ Updated documentation for: $example_name"
}

# Find all storage account examples
STORAGE_EXAMPLES=$(find "$PROJECT_ROOT/modules/azurerm_storage_account/examples" -mindepth 1 -maxdepth 1 -type d | sort)

echo "Found $(echo "$STORAGE_EXAMPLES" | wc -l | xargs) examples to process"
echo ""

# Process each example
for example in $STORAGE_EXAMPLES; do
    update_example_docs "$example"
done

echo ""
echo "✅ All example documentation updated successfully!"