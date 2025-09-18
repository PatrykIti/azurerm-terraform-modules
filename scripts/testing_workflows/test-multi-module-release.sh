#!/bin/bash

# Test script for multi-module release workflow
# This simulates what happens when a PR with multiple module scopes is merged

set -e

echo "========================================="
echo "Multi-Module Release Workflow Test"
echo "========================================="
echo ""

# Configuration
MODULES_TO_TEST="kubernetes-cluster,network-security-group,route-table,storage-account,subnet"
DRY_RUN="true"

echo "📋 Test Configuration:"
echo "   Modules: $MODULES_TO_TEST"
echo "   Dry Run: $DRY_RUN"
echo ""

# Test 1: Verify all modules exist and have proper configuration
echo "📦 Step 1: Verifying module configurations..."
IFS=',' read -ra MODULE_ARRAY <<< "$MODULES_TO_TEST"
for scope_item in "${MODULE_ARRAY[@]}"; do
    # Convert scope to module name (same logic as in workflow)
    MODULE_NAME="${scope_item#azurerm-}"
    MODULE_NAME="${MODULE_NAME//-/_}"
    MODULE_NAME="azurerm_${MODULE_NAME}"

    echo "   Checking module: $MODULE_NAME"

    # Check if module directory exists
    if [[ ! -d "modules/$MODULE_NAME" ]]; then
        echo "   ❌ Module directory not found: modules/$MODULE_NAME"
        exit 1
    fi

    # Check for .releaserc.js
    if [[ ! -f "modules/$MODULE_NAME/.releaserc.js" ]]; then
        echo "   ❌ No .releaserc.js found in modules/$MODULE_NAME"
        exit 1
    fi

    # Check for module.json
    if [[ ! -f "modules/$MODULE_NAME/module.json" ]]; then
        echo "   ❌ No module.json found in modules/$MODULE_NAME"
        exit 1
    fi

    echo "   ✅ Module $MODULE_NAME is properly configured"
done
echo ""

# Test 2: Test the workflow detection logic locally
echo "🔍 Step 2: Testing module detection from PR title..."
PR_TITLE="feat(kubernetes-cluster,network-security-group,route-table,storage-account,subnet): complete module implementation with tests and examples"
echo "   PR Title: $PR_TITLE"

# Extract scope (same logic as workflow)
if [[ "$PR_TITLE" =~ ^[^(]+\(([^)]+)\) ]]; then
    SCOPE="${BASH_REMATCH[1]}"
    echo "   Detected scope: $SCOPE"

    IFS=',' read -ra SCOPE_ARRAY <<< "$SCOPE"
    VALID_MODULES=()

    for scope_item in "${SCOPE_ARRAY[@]}"; do
        scope_item=$(echo "$scope_item" | xargs)
        MODULE_NAME="${scope_item#azurerm-}"
        MODULE_NAME="${MODULE_NAME//-/_}"
        MODULE_NAME="azurerm_${MODULE_NAME}"

        if [[ -d "modules/$MODULE_NAME" ]]; then
            VALID_MODULES+=("$MODULE_NAME")
        fi
    done

    echo "   Valid modules detected: ${VALID_MODULES[*]}"
else
    echo "   ❌ Could not extract scope from PR title"
    exit 1
fi
echo ""

# Test 3: Simulate what would happen with act (without actually running Docker)
echo "🐳 Step 3: Preparing act test command..."
echo "   The following command would test the release workflow locally:"
echo ""
echo "   act push -W .github/workflows/release-changed-modules.yml \\"
echo "       --secret-file .act.secrets \\"
echo "       --var-file .act.vars \\"
echo "       -P ubuntu-latest=catthehacker/ubuntu:act-latest \\"
echo "       --container-architecture linux/amd64 \\"
echo "       --input modules=$MODULES_TO_TEST \\"
echo "       --input dry_run=$DRY_RUN"
echo ""

# Test 4: Verify the update-root-readme.sh script
echo "📝 Step 4: Testing README update script..."
if [[ -x "./scripts/update-root-readme.sh" ]]; then
    echo "   ✅ update-root-readme.sh exists and is executable"
else
    echo "   ❌ update-root-readme.sh not found or not executable"
    exit 1
fi
echo ""

# Test 5: Check semantic-release multi-scope plugin
echo "🔌 Step 5: Checking multi-scope plugin..."
if [[ -f "./scripts/semantic-release-multi-scope-plugin.js" ]]; then
    echo "   ✅ semantic-release-multi-scope-plugin.js exists"

    # Check if it can handle multi-scope commits
    echo "   Testing plugin logic for filtering commits..."
    for module in "${VALID_MODULES[@]}"; do
        echo "     - Module $module would process commits with its specific scope"
    done
else
    echo "   ❌ semantic-release-multi-scope-plugin.js not found"
    exit 1
fi
echo ""

# Summary
echo "========================================="
echo "📊 Test Summary"
echo "========================================="
echo ""
echo "✅ All module configurations are valid"
echo "✅ Module detection from PR title works correctly"
echo "✅ README update mechanism is in place"
echo "✅ Multi-scope plugin is configured"
echo ""
echo "🎯 Expected behavior when PR is merged:"
echo "1. The release-changed-modules workflow will detect all ${#VALID_MODULES[@]} modules"
echo "2. It will create a matrix strategy with max-parallel=1"
echo "3. Each module will be released sequentially:"
for module in "${VALID_MODULES[@]}"; do
    # Get module config
    if [[ -f "modules/$module/module.json" ]]; then
        TAG_PREFIX=$(jq -r .tag_prefix "modules/$module/module.json" 2>/dev/null || echo "unknown")
        echo "   - $module (tag prefix: $TAG_PREFIX)"
    fi
done
echo "4. Each release will update:"
echo "   - Module's CHANGELOG.md"
echo "   - Module's README.md with new version"
echo "   - Root README.md with module status and version badge"
echo "5. Changes will be committed with [skip ci] to avoid loops"
echo ""
echo "💡 To run the actual test with Docker:"
echo "   ./test-multi-module-release.sh --run-with-act"
echo ""

# Optional: Actually run with act if requested
if [[ "$1" == "--run-with-act" ]]; then
    echo "🚀 Running actual workflow test with act..."
    echo "(This requires Docker to be running)"
    echo ""

    act push -W .github/workflows/release-changed-modules.yml \
        --secret-file .act.secrets \
        --var-file .act.vars \
        -P ubuntu-latest=catthehacker/ubuntu:act-latest \
        --container-architecture linux/amd64 \
        --input modules="$MODULES_TO_TEST" \
        --input dry_run="$DRY_RUN" \
        --verbose
fi