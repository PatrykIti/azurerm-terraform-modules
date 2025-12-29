#!/bin/bash
# Update module documentation safely
# This script replaces terraform-docs to ensure root README is never overwritten

set -euo pipefail

# Get module name from parameter or environment
MODULE_NAME="${1:-${MODULE_NAME:-}}"

if [ -z "$MODULE_NAME" ]; then
    echo "Error: MODULE_NAME not provided"
    echo "Usage: $0 <module_name>"
    exit 1
fi

# Determine paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODULE_DIR="${ROOT_DIR}/modules/${MODULE_NAME}"
ROOT_README="${ROOT_DIR}/README.md"

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

# Backup root README so we can detect or revert accidental writes
ROOT_README_BAK=""
if [ -f "$ROOT_README" ]; then
    ROOT_README_BAK="$(mktemp)"
    cp "$ROOT_README" "$ROOT_README_BAK"
fi

# Run terraform-docs from the module directory to ensure relative output paths
if pushd "$MODULE_DIR" > /dev/null && terraform-docs \
    --config ".terraform-docs.yml" \
    --output-file "README.md" \
    --output-mode inject \
    "." 2>/dev/null; then

    popd > /dev/null

    echo "✅ Successfully updated documentation for ${MODULE_NAME}"
    rm -f "${MODULE_README}.bak"

    # Verify root README was not touched
    if [ -n "$ROOT_README_BAK" ] && [ -f "$ROOT_README_BAK" ] && [ -f "$ROOT_README" ]; then
        if ! cmp -s "$ROOT_README_BAK" "$ROOT_README"; then
            echo "❌ ERROR: Root README was modified during terraform-docs!"
            echo "Restoring root README..."
            mv "$ROOT_README_BAK" "$ROOT_README"
            exit 1
        fi
    fi
    rm -f "$ROOT_README_BAK"
else
    popd > /dev/null || true
    echo "❌ Failed to update documentation for ${MODULE_NAME}"
    echo "Restoring backup..."
    mv "${MODULE_README}.bak" "$MODULE_README"
    if [ -n "$ROOT_README_BAK" ] && [ -f "$ROOT_README_BAK" ] && [ -f "$ROOT_README" ]; then
        mv "$ROOT_README_BAK" "$ROOT_README"
    fi
    exit 1
fi

echo "Documentation update completed successfully"
