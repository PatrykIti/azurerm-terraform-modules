#!/bin/bash

# Test script to simulate README.md updates for multiple modules
# This shows exactly what will happen to README.md when modules are released

set -e

echo "========================================="
echo "README.md Update Simulation"
echo "========================================="
echo ""

# Create a backup of current README
cp README.md README.md.backup

echo "📋 Current README.md module status:"
echo ""
grep -E "(Kubernetes Cluster|Network Security Group|Route Table|Storage Account|Subnet).*\|.*Development" README.md || true
echo ""

# Test modules to simulate release
MODULES=(
    "azurerm_kubernetes_cluster:Kubernetes Cluster:AKSv:1.0.0"
    "azurerm_network_security_group:Network Security Group:NSGv:1.0.0"
    "azurerm_route_table:Route Table:RTv:1.0.0"
    "azurerm_storage_account:Storage Account:SAv:1.2.0"
    "azurerm_subnet:Subnet:SNv:1.0.0"
)

echo "🚀 Simulating release for ${#MODULES[@]} modules..."
echo ""

# Process each module
for module_info in "${MODULES[@]}"; do
    IFS=':' read -r MODULE_NAME MODULE_DISPLAY_NAME TAG_PREFIX VERSION <<< "$module_info"

    echo "📦 Processing $MODULE_DISPLAY_NAME ($MODULE_NAME)..."
    echo "   Tag: ${TAG_PREFIX}${VERSION}"

    # Run the actual update script
    ./scripts/update-root-readme.sh "$MODULE_NAME" "$MODULE_DISPLAY_NAME" "$TAG_PREFIX" "$VERSION" "PatrykIti" "azurerm-terraform-modules"

    echo "   ✅ Updated"
    echo ""
done

echo "========================================="
echo "📊 Changes Made to README.md"
echo "========================================="
echo ""

# Show the diff
echo "📝 Diff of changes:"
diff -u README.md.backup README.md || true

echo ""
echo "========================================="
echo "✅ New Module Status in README.md"
echo "========================================="
echo ""

# Show the updated module table
echo "Module table after updates:"
grep -A 10 "Production Ready" README.md | head -20

echo ""
echo "Module badges section:"
grep -A 10 "MODULE BADGES START" README.md | head -15

# Restore the original README
echo ""
echo "⏪ Restoring original README.md..."
mv README.md.backup README.md

echo ""
echo "✅ Test completed successfully!"
echo ""
echo "💡 Summary:"
echo "   - All modules would be updated from 'Development' to 'Completed' status"
echo "   - Version badges would be added for each module"
echo "   - Version links would point to GitHub releases"
echo "   - Each module update happens sequentially (max-parallel=1)"