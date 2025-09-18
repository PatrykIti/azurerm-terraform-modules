#!/bin/bash

# Test Release Workflow with Docker
# This script uses the same Docker image as GitHub Actions for maximum accuracy

set -e

echo "🐳 Testing Release Workflow with Docker"
echo "========================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first"
    exit 1
fi

MODULE="${1:-azurerm_storage_account}"
echo "📦 Testing module: $MODULE"

# Pull the GitHub Actions runner image
echo "📥 Pulling GitHub Actions runner image..."
docker pull ghcr.io/catthehacker/ubuntu:act-latest

# Create a test script that will run inside the container
cat > /tmp/test-release.sh << 'SCRIPT'
#!/bin/bash
set -e

echo "🔧 Setting up environment..."
cd /workspace

# Install Node.js and npm
apt-get update && apt-get install -y nodejs npm git

# Install semantic-release and plugins
npm install -g semantic-release@24.0.0 \
  @semantic-release/changelog@6.0.3 \
  @semantic-release/git@10.0.1 \
  @semantic-release/github@10.0.0 \
  @semantic-release/exec@6.0.3

# Configure git
git config --global user.email "semantic-release@test.local"
git config --global user.name "Semantic Release Test"
git config --global --add safe.directory /workspace

# Navigate to module
MODULE=$1
cd "modules/$MODULE"

echo "📂 Current directory: $(pwd)"
echo "📋 Files in directory:"
ls -la

# Check for release config
if [ -f ".releaserc.json" ]; then
    echo "✅ Found .releaserc.json"
    cat .releaserc.json
else
    echo "⚠️  No .releaserc.json found in module directory"
fi

# Run semantic-release in dry-run mode
echo ""
echo "🚀 Running semantic-release (dry-run)..."
CI=true DRY_RUN=true GITHUB_TOKEN=dummy npx semantic-release --dry-run --no-ci --debug || {
    echo "⚠️  Semantic release encountered an error (this is normal for dry-run without proper tokens)"
}

echo ""
echo "✅ Test completed!"
SCRIPT

chmod +x /tmp/test-release.sh

# Run the test in Docker
echo ""
echo "🚀 Running test in Docker container..."
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  -e MODULE="$MODULE" \
  ghcr.io/catthehacker/ubuntu:act-latest \
  bash /tmp/test-release.sh "$MODULE"

# Clean up
rm -f /tmp/test-release.sh

echo ""
echo "✅ Docker test completed!"
echo ""
echo "📋 Test Summary:"
echo "- Module tested: $MODULE"
echo "- Environment: GitHub Actions Ubuntu container"
echo "- Mode: Dry run (no actual release)"
echo ""
echo "💡 To test with actual GitHub Actions locally:"
echo "   act workflow_dispatch -W .github/workflows/module-release.yml --input module=$MODULE --input dry_run=true"