#!/bin/bash

# Generate documentation for the module using the repository wrapper.

set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="$(basename "$MODULE_DIR")"

echo "Generating documentation for ${MODULE_NAME} module..."

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "Error: terraform-docs is not installed. Please install it first."
    echo "Visit: https://terraform-docs.io/user-guide/installation/"
    exit 1
fi

# Update examples list if the helper exists
if [ -x "$MODULE_DIR/../../scripts/update-examples-list.sh" ]; then
    echo "Updating examples list..."
    "$MODULE_DIR/../../scripts/update-examples-list.sh" "$MODULE_DIR"
fi

# Regenerate module README using the safe wrapper
if [ -x "$MODULE_DIR/../../scripts/update-module-docs.sh" ]; then
    "$MODULE_DIR/../../scripts/update-module-docs.sh" "$MODULE_NAME"
else
    echo "Error: update-module-docs.sh not found or not executable."
    exit 1
fi

echo "✅ Documentation generated successfully!"
