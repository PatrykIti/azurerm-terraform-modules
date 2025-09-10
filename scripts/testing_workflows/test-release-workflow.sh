#!/bin/bash

# Test Release Workflow Locally
# This script uses 'act' to test GitHub Actions workflows locally

set -e

echo "🚀 Testing Release Workflow Locally"
echo "===================================="

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ 'act' is not installed. Please install it first:"
    echo "   brew install act"
    exit 1
fi

# Default values
MODULE="${1:-azurerm_storage_account}"
DRY_RUN="${2:-true}"

echo "📦 Testing release for module: $MODULE"
echo "🔧 Dry run mode: $DRY_RUN"
echo ""

# Create a temporary secrets file for act
SECRETS_FILE=$(mktemp)
trap "rm -f $SECRETS_FILE" EXIT

# You'll need to set these environment variables or update this script
cat > "$SECRETS_FILE" << EOF
GITHUB_TOKEN=${GITHUB_TOKEN:-your_github_token_here}
NPM_TOKEN=${NPM_TOKEN:-not_needed_for_terraform}
APP_ID=${APP_ID:-your_app_id}
APP_PRIVATE_KEY=${APP_PRIVATE_KEY:-your_private_key}
EOF

# Option 1: Test with the full Docker image (recommended for accuracy)
echo "Option 1: Full test with Docker image (most accurate)"
echo "------------------------------------------------------"
echo "Running: act workflow_dispatch -W .github/workflows/module-release.yml \\"
echo "  --input module=$MODULE \\"
echo "  --input dry_run=$DRY_RUN \\"
echo "  --secret-file $SECRETS_FILE \\"
echo "  --platform ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest"
echo ""
echo "Press Enter to run this test, or Ctrl+C to cancel"
read -r

act workflow_dispatch \
  -W .github/workflows/module-release.yml \
  --input module="$MODULE" \
  --input dry_run="$DRY_RUN" \
  --secret-file "$SECRETS_FILE" \
  --platform ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest \
  --verbose

echo ""
echo "✅ Workflow test completed!"