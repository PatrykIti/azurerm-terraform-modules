#!/bin/bash
# Update module documentation safely
# This script replaces terraform-docs to ensure root README is never overwritten

set -e

# Get module name from parameter or environment
MODULE_NAME="${1:-$MODULE_NAME}"

if [ -z "$MODULE_NAME" ]; then
    echo "Error: MODULE_NAME not provided"
    echo "Usage: $0 <module_name>"
    exit 1
fi

# Determine paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODULE_DIR="${ROOT_DIR}/modules/${MODULE_NAME}"

# Check if module exists
if [ ! -d "$MODULE_DIR" ]; then
    echo "Error: Module directory not found: $MODULE_DIR"
    exit 1
fi

# Check if terraform-docs is installed
if ! command -v terraform-docs > /dev/null 2>&1; then
    echo "Warning: terraform-docs is not installed, skipping documentation update"
    exit 0
fi

echo "Updating documentation for module: ${MODULE_NAME}"

# CRITICAL: Only update the MODULE's README, never touch root README
MODULE_README="${MODULE_DIR}/README.md"

# Check if module README exists
if [ ! -f "$MODULE_README" ]; then
    echo "Warning: Module README not found: $MODULE_README"
    exit 0
fi

# Check for terraform-docs markers
if ! grep -q "BEGIN_TF_DOCS" "$MODULE_README"; then
    echo "Warning: terraform-docs markers not found in $MODULE_README"
    echo "Skipping documentation update for safety"
    exit 0
fi

# Create a backup just in case
cp "$MODULE_README" "${MODULE_README}.bak"

# Run terraform-docs with explicit paths and inject mode
# IMPORTANT: We use absolute paths and explicitly specify the output file
if terraform-docs \
    --config "${MODULE_DIR}/.terraform-docs.yml" \
    --output-file "${MODULE_README}" \
    --output-mode inject \
    "${MODULE_DIR}" 2>/dev/null; then

    echo "✅ Successfully updated documentation for ${MODULE_NAME}"
    rm -f "${MODULE_README}.bak"

    # Verify root README was not touched
    if [ -f "${ROOT_DIR}/README.md" ]; then
        if grep -q "^# terraform-docs" "${ROOT_DIR}/README.md" 2>/dev/null; then
            echo "❌ ERROR: Root README appears to have been overwritten!"
            echo "This should not happen. Please check the terraform-docs configuration."
            exit 1
        fi
    fi
else
    echo "❌ Failed to update documentation for ${MODULE_NAME}"
    echo "Restoring backup..."
    mv "${MODULE_README}.bak" "$MODULE_README"
    exit 1
fi

echo "Documentation update completed successfully"