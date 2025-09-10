#!/bin/bash

# Test Semantic Release Locally
# This script simulates the semantic-release process locally without act

set -e

echo "🧪 Testing Semantic Release Locally"
echo "===================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install it first"
    exit 1
fi

# Check if npx is available
if ! command -v npx &> /dev/null; then
    echo "❌ npx is not available. Please install npm first"
    exit 1
fi

MODULE="${1:-azurerm_storage_account}"
MODULE_PATH="modules/$MODULE"

if [ ! -d "$MODULE_PATH" ]; then
    echo "❌ Module directory not found: $MODULE_PATH"
    exit 1
fi

echo "📦 Testing semantic-release for module: $MODULE"
echo "📂 Module path: $MODULE_PATH"
echo ""

# Change to module directory
cd "$MODULE_PATH"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "⚠️  No package.json found. Creating one..."
    cat > package.json << 'EOF'
{
  "name": "terraform-module",
  "version": "0.0.0-development",
  "private": true,
  "description": "Terraform module for testing",
  "scripts": {
    "semantic-release": "semantic-release"
  },
  "devDependencies": {
    "@semantic-release/changelog": "^6.0.3",
    "@semantic-release/git": "^10.0.1",
    "@semantic-release/github": "^10.0.0",
    "semantic-release": "^24.0.0"
  }
}
EOF
fi

# Check if .releaserc.json exists
if [ ! -f ".releaserc.json" ]; then
    echo "⚠️  No .releaserc.json found. Using repository config..."
fi

echo "📥 Installing dependencies..."
npm install --save-dev semantic-release @semantic-release/changelog @semantic-release/git @semantic-release/github

echo ""
echo "🔍 Analyzing commits..."
echo "------------------------"

# Set environment variables for dry run
export CI=true
export GITHUB_TOKEN=${GITHUB_TOKEN:-dummy_token_for_dry_run}
export DRY_RUN=true

echo "🚀 Running semantic-release in dry-run mode..."
echo ""

# Run semantic-release in dry-run mode
npx semantic-release --dry-run --no-ci --debug

echo ""
echo "✅ Semantic release test completed!"
echo ""
echo "📋 Summary:"
echo "- Module: $MODULE"
echo "- Path: $MODULE_PATH"
echo "- Mode: Dry run (no actual release created)"
echo ""
echo "💡 To test with act (GitHub Actions emulator):"
echo "   ./test-release-workflow.sh $MODULE true"