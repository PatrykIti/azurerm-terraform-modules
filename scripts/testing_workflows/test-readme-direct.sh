#!/bin/bash

# Direct test of README.md updates without running the full script
# This simulates what semantic-release will do

set -e

echo "========================================="
echo "Direct README.md Update Test"
echo "========================================="
echo ""

# Create a working copy
cp README.md README.test.md

echo "📋 Initial module status in README:"
echo ""
echo "Kubernetes Cluster line:"
grep "Kubernetes Cluster" README.test.md | grep "modules/azurerm_kubernetes_cluster" || true
echo ""
echo "Storage Account line:"
grep "Storage Account" README.test.md | grep "modules/azurerm_storage_account" || true
echo ""

# Simulate updates for each module
MODULES=(
    "azurerm_kubernetes_cluster|Kubernetes Cluster|AKSv|1.1.0"
    "azurerm_storage_account|Storage Account|SAv|1.2.0"
)

echo "🔄 Simulating version updates..."
echo ""

for module_info in "${MODULES[@]}"; do
    IFS='|' read -r MODULE_NAME MODULE_DISPLAY_NAME TAG_PREFIX VERSION <<< "$module_info"

    echo "Processing $MODULE_DISPLAY_NAME -> ${TAG_PREFIX}${VERSION}"

    # Update the version in the table (handling current format)
    # Current format: | [Module Name](./modules/module_name/) | ✅ Completed | v1.0.0 | Description |
    # Or: | [Module Name](./modules/module_name/) | ✅ Completed | [SAv1.0.0](link) | Description |

    # First, handle simple version format (v1.0.0)
    # Need to escape the pipe characters properly
    OLD_PATTERN="\\[${MODULE_DISPLAY_NAME}\\](./modules/${MODULE_NAME}/) | ✅ Completed | v[0-9.]*"
    NEW_TEXT="[${MODULE_DISPLAY_NAME}](./modules/${MODULE_NAME}/) | ✅ Completed | [${TAG_PREFIX}${VERSION}](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/${TAG_PREFIX}${VERSION})"

    # Use perl for more reliable regex handling
    perl -i -pe "s|\Q[${MODULE_DISPLAY_NAME}](./modules/${MODULE_NAME}/)\E \| ✅ Completed \| v[0-9.]+|${NEW_TEXT}|g" README.test.md

    # Then, handle already linked version format [SAv1.0.0](link)
    perl -i -pe "s|\Q[${MODULE_DISPLAY_NAME}](./modules/${MODULE_NAME}/)\E \| ✅ Completed \| \[${TAG_PREFIX}[^\]]+\]\([^)]+\)|${NEW_TEXT}|g" README.test.md
done

echo ""
echo "📝 Module badges update..."
echo ""

# Check current badges
echo "Current badges section:"
sed -n '/<!-- MODULE BADGES START -->/,/<!-- MODULE BADGES END -->/p' README.test.md
echo ""

# Add new badges if not exists
for module_info in "${MODULES[@]}"; do
    IFS='|' read -r MODULE_NAME MODULE_DISPLAY_NAME TAG_PREFIX VERSION <<< "$module_info"

    # Remove old badge if exists
    sed -i.bak "/\\[${MODULE_DISPLAY_NAME}\\].*img.shields.io.*${TAG_PREFIX}/d" README.test.md

    # Add new badge
    URL_ENCODED_NAME=$(echo "$MODULE_DISPLAY_NAME" | sed 's/ /%20/g')
    sed -i.bak "/<!-- MODULE BADGES START -->/a\\
[![${MODULE_DISPLAY_NAME}](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter=${TAG_PREFIX}*&label=${URL_ENCODED_NAME}&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=${TAG_PREFIX})" README.test.md
done

echo "========================================="
echo "📊 Results"
echo "========================================="
echo ""

echo "Updated module lines:"
echo ""
echo "Kubernetes Cluster:"
grep "Kubernetes Cluster" README.test.md | grep "modules/azurerm_kubernetes_cluster" || true
echo ""
echo "Storage Account:"
grep "Storage Account" README.test.md | grep "modules/azurerm_storage_account" || true
echo ""

echo "Updated badges section:"
sed -n '/<!-- MODULE BADGES START -->/,/<!-- MODULE BADGES END -->/p' README.test.md
echo ""

echo "========================================="
echo "📝 Full diff of changes:"
echo "========================================="
diff -u README.md README.test.md || true

# Cleanup
rm -f README.test.md README.test.md.bak

echo ""
echo "✅ Test completed!"