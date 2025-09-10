#!/bin/bash

# Test Full Release Workflow Locally
# This script simulates the complete release workflow:
# 1. Detects changed modules from commit scope
# 2. Creates a matrix of modules
# 3. Runs semantic-release for each module

set -e

echo "🚀 Testing Full Release Workflow"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Parse arguments
DRY_RUN="${1:-true}"
MODULES="${2:-}"  # Comma-separated list of modules or empty for auto-detect

echo "Configuration:"
echo "  Dry Run: $DRY_RUN"
echo "  Modules: ${MODULES:-auto-detect from last commit}"
echo ""

# Step 1: Detect modules to release
print_info "Step 1: Detecting modules to release..."
echo "----------------------------------------"

if [[ -n "$MODULES" ]]; then
    # Manual module list provided
    print_info "Using manually provided modules: $MODULES"
    IFS=',' read -ra MODULE_ARRAY <<< "$MODULES"
else
    # Auto-detect from last commit
    COMMIT_MESSAGE=$(git log -1 --pretty=%s)
    print_info "Last commit message: $COMMIT_MESSAGE"
    
    # Extract scope from conventional commit format
    if [[ "$COMMIT_MESSAGE" =~ ^[^(]+\(([^)]+)\) ]]; then
        SCOPE="${BASH_REMATCH[1]}"
        print_info "Detected scope: $SCOPE"
        
        # Split scope by comma and process each module
        IFS=',' read -ra SCOPE_ARRAY <<< "$SCOPE"
        MODULE_ARRAY=()
        
        for scope_item in "${SCOPE_ARRAY[@]}"; do
            # Trim whitespace
            scope_item=$(echo "$scope_item" | xargs)
            
            # Convert scope to module name
            MODULE_NAME="$scope_item"
            
            # Remove azurerm- prefix if present
            MODULE_NAME="${MODULE_NAME#azurerm-}"
            # Replace dashes with underscores
            MODULE_NAME="${MODULE_NAME//-/_}"
            # Add azurerm_ prefix
            MODULE_NAME="azurerm_${MODULE_NAME}"
            
            # Check if this module exists
            if [[ -d "modules/$MODULE_NAME" ]]; then
                print_success "Found module: $MODULE_NAME"
                MODULE_ARRAY+=("$MODULE_NAME")
            else
                print_warning "Module $MODULE_NAME not found in modules/ directory"
            fi
        done
    else
        print_warning "Commit message doesn't contain a scope in conventional commit format"
        print_info "Expected format: type(scope): description"
        print_info "Example: feat(storage-account): add encryption support"
        MODULE_ARRAY=()
    fi
fi

if [ ${#MODULE_ARRAY[@]} -eq 0 ]; then
    print_warning "No modules to release!"
    exit 0
fi

echo ""
print_success "Modules to release: ${MODULE_ARRAY[*]}"
echo ""

# Step 2: Test with act (if available)
if command -v act &> /dev/null; then
    print_info "Step 2: Testing with act (GitHub Actions emulator)..."
    echo "------------------------------------------------------"
    
    # Create modules string for act
    MODULES_STRING=$(IFS=','; echo "${MODULE_ARRAY[*]}")
    
    print_info "Running: act workflow_dispatch -W .github/workflows/release-changed-modules.yml"
    print_info "  --input modules=$MODULES_STRING"
    print_info "  --input dry_run=$DRY_RUN"
    echo ""
    
    read -p "Press Enter to run with act, or 's' to skip: " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        # Create a minimal secrets file
        SECRETS_FILE=$(mktemp)
        trap "rm -f $SECRETS_FILE" EXIT
        
        cat > "$SECRETS_FILE" << EOF
GITHUB_TOKEN=${GITHUB_TOKEN:-dummy_token}
PAT=${PAT:-dummy_pat}
APP_ID=${APP_ID:-dummy_app_id}
APP_PRIVATE_KEY=${APP_PRIVATE_KEY:-dummy_private_key}
EOF
        
        act workflow_dispatch \
            -W .github/workflows/release-changed-modules.yml \
            --input modules="$MODULES_STRING" \
            --input dry_run="$DRY_RUN" \
            --secret-file "$SECRETS_FILE" \
            --platform ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest \
            -j detect-changes || print_warning "act simulation completed (errors are expected without real tokens)"
    fi
else
    print_warning "act is not installed. Skipping GitHub Actions simulation."
    print_info "Install with: brew install act"
fi

echo ""

# Step 3: Test semantic-release locally for each module
print_info "Step 3: Testing semantic-release locally for each module..."
echo "-----------------------------------------------------------"

for MODULE in "${MODULE_ARRAY[@]}"; do
    echo ""
    print_info "Testing module: $MODULE"
    MODULE_PATH="modules/$MODULE"
    
    if [ ! -d "$MODULE_PATH" ]; then
        print_error "Module directory not found: $MODULE_PATH"
        continue
    fi
    
    # Check for release config
    if [ -f "$MODULE_PATH/.releaserc.json" ]; then
        print_success "Found .releaserc.json in $MODULE_PATH"
    else
        print_warning "No .releaserc.json found in $MODULE_PATH"
        print_info "Will use root .releaserc.json if available"
    fi
    
    # Simulate semantic-release
    (
        cd "$MODULE_PATH"
        
        # Check if package.json exists
        if [ ! -f "package.json" ]; then
            print_warning "No package.json found. Creating temporary one..."
            cat > package.json << 'EOF'
{
  "name": "terraform-module",
  "version": "0.0.0-development",
  "private": true
}
EOF
        fi
        
        # Run semantic-release analysis (dry-run)
        print_info "Analyzing commits for $MODULE..."
        
        # Set environment for dry-run
        export CI=true
        export DRY_RUN=true
        export GITHUB_TOKEN=${GITHUB_TOKEN:-dummy_token}
        
        # Check what would be released
        npx semantic-release --dry-run --no-ci 2>&1 | grep -E "(The next release version|There are no relevant changes|Analysis of)" || true
    )
    
    print_success "Completed test for $MODULE"
done

echo ""
echo "========================================"
print_success "Full workflow test completed!"
echo ""
echo "📋 Summary:"
echo "  • Modules tested: ${MODULE_ARRAY[*]}"
echo "  • Mode: ${DRY_RUN:+Dry run}${DRY_RUN:-Live}"
echo ""
echo "💡 Tips:"
echo "  • To test with real GitHub Actions: Use 'act' with proper secrets"
echo "  • To test a specific module: ./test-full-release-workflow.sh true 'storage-account'"
echo "  • To test multiple modules: ./test-full-release-workflow.sh true 'storage-account,virtual-network'"
echo ""