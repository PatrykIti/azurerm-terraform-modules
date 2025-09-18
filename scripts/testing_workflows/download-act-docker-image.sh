#!/bin/bash

# Download Act Docker Image
# This script downloads the Docker image used for GitHub Actions testing

set -e

echo "🐳 Docker Image Downloader for Act"
echo "==================================="
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

# Function to format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes} B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    else
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    fi
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker Desktop first"
    echo "Download from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker daemon is not running. Please start Docker Desktop"
    exit 1
fi

# Available images
echo "Available Act Docker Images:"
echo "----------------------------"
echo ""
echo "1. ${YELLOW}act-latest${NC} (Recommended)"
echo "   • Size: ~3-5 GB"
echo "   • Contains: Most common tools and languages"
echo "   • Best for: Most GitHub Actions workflows"
echo ""
echo "2. ${BLUE}act-22.04${NC}"
echo "   • Size: ~3-5 GB"
echo "   • Based on: Ubuntu 22.04"
echo "   • Best for: Modern workflows"
echo ""
echo "3. ${GREEN}act-20.04${NC}"
echo "   • Size: ~3-5 GB"
echo "   • Based on: Ubuntu 20.04"
echo "   • Best for: Legacy compatibility"
echo ""
echo "4. ${RED}full-latest${NC} (Large!)"
echo "   • Size: ~14 GB"
echo "   • Contains: Everything from GitHub-hosted runners"
echo "   • Best for: Complex workflows requiring all tools"
echo ""

# Ask user which image to download
read -p "Which image do you want to download? (1-4, default: 1): " choice
choice=${choice:-1}

case $choice in
    1) IMAGE="ghcr.io/catthehacker/ubuntu:act-latest" ;;
    2) IMAGE="ghcr.io/catthehacker/ubuntu:act-22.04" ;;
    3) IMAGE="ghcr.io/catthehacker/ubuntu:act-20.04" ;;
    4) IMAGE="ghcr.io/catthehacker/ubuntu:full-latest" ;;
    *) 
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_info "Selected image: $IMAGE"

# Check if image already exists
if docker image inspect "$IMAGE" > /dev/null 2>&1; then
    print_warning "Image already exists locally!"
    CURRENT_SIZE=$(docker image inspect "$IMAGE" --format='{{.Size}}')
    print_info "Current size: $(format_bytes $CURRENT_SIZE)"
    echo ""
    read -p "Do you want to re-download it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping download"
        exit 0
    fi
fi

# Check available disk space
echo ""
print_info "Checking available disk space..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    AVAILABLE=$(df -k / | awk 'NR==2 {print $4}')
    AVAILABLE_GB=$(echo "scale=2; $AVAILABLE/1048576" | bc)
else
    # Linux
    AVAILABLE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    AVAILABLE_GB=$AVAILABLE
fi

print_info "Available disk space: ${AVAILABLE_GB} GB"

# Warn if low disk space
if (( $(echo "$AVAILABLE_GB < 10" | bc -l) )); then
    print_warning "Low disk space! You need at least 10 GB free"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Download the image
echo ""
print_info "Downloading Docker image..."
print_info "This may take several minutes depending on your internet connection"
echo ""

# Show progress while downloading
docker pull "$IMAGE" || {
    print_error "Failed to download image"
    exit 1
}

# Get final image size
echo ""
print_success "Image downloaded successfully!"

# Display image info
docker image inspect "$IMAGE" --format='
Image: {{.RepoTags}}
ID: {{.Id}}
Created: {{.Created}}
Size: {{.Size}} bytes
Architecture: {{.Architecture}}
OS: {{.Os}}' | while IFS= read -r line; do
    if [[ $line == Size:* ]]; then
        SIZE_BYTES=$(echo "$line" | grep -o '[0-9]*')
        echo "Size: $(format_bytes $SIZE_BYTES)"
    else
        echo "$line"
    fi
done

echo ""
print_success "Docker image is ready to use!"
echo ""
echo "📋 Next steps:"
echo "  1. Test a single module:    ./test-release-workflow.sh azurerm_storage_account"
echo "  2. Test full workflow:      ./test-full-release-workflow.sh"
echo "  3. Run with act directly:   act workflow_dispatch -W .github/workflows/release-changed-modules.yml"
echo ""

# List all act images
echo "📦 Available Act images on your system:"
docker images "ghcr.io/catthehacker/ubuntu" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "(REPOSITORY|act|full)"