#!/bin/bash

# Check if terraform-docs content is up to date in README.md
# Usage: ./check-terraform-docs.sh <module-path>

set -e

MODULE_PATH="${1:-.}"
README_PATH="$MODULE_PATH/README.md"

# Check if README exists
if [[ ! -f "$README_PATH" ]]; then
    echo "❌ README.md not found in $MODULE_PATH"
    exit 1
fi

# Check if terraform-docs markers exist
if ! grep -q "<!-- BEGIN_TF_DOCS -->" "$README_PATH" || ! grep -q "<!-- END_TF_DOCS -->" "$README_PATH"; then
    echo "❌ terraform-docs markers not found in $README_PATH"
    exit 1
fi

# Extract current terraform-docs content from README
TEMP_CURRENT=$(mktemp)
awk '/<!-- BEGIN_TF_DOCS -->/{flag=1; next} /<!-- END_TF_DOCS -->/{flag=0} flag' "$README_PATH" > "$TEMP_CURRENT"

# Generate new terraform-docs content
TEMP_NEW=$(mktemp)
TEMP_FULL=$(mktemp)

# Generate full file with terraform-docs
if ! terraform-docs markdown table --output-file "$TEMP_FULL" "$MODULE_PATH" 2>/dev/null; then
    echo "❌ terraform-docs failed for $MODULE_PATH"
    rm -f "$TEMP_CURRENT" "$TEMP_NEW" "$TEMP_FULL"
    exit 1
fi

# Extract just the content between markers from generated file
awk '/<!-- BEGIN_TF_DOCS -->/{flag=1; next} /<!-- END_TF_DOCS -->/{flag=0} flag' "$TEMP_FULL" > "$TEMP_NEW"

# Compare the terraform-docs sections
if diff -q "$TEMP_CURRENT" "$TEMP_NEW" > /dev/null 2>&1; then
    echo "✅ terraform-docs is up to date in $MODULE_PATH"
    rm -f "$TEMP_CURRENT" "$TEMP_NEW" "$TEMP_FULL"
    exit 0
else
    echo "❌ terraform-docs is outdated in $MODULE_PATH"
    echo "   Run: terraform-docs markdown table --output-file README.md $MODULE_PATH"
    rm -f "$TEMP_CURRENT" "$TEMP_NEW" "$TEMP_FULL"
    exit 1
fi