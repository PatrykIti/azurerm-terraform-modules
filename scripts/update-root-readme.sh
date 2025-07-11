#!/bin/bash
# Update root README.md with module release information

set -e

# Arguments from semantic-release
MODULE_NAME="${1}"
MODULE_DISPLAY_NAME="${2}"
TAG_PREFIX="${3}"
VERSION="${4}"
REPO_OWNER="${5}"
REPO_NAME="${6}"

# Path to root README
# When called from semantic-release running at root, adjust path
if [[ -f "README.md" ]]; then
    ROOT_README="README.md"
elif [[ -f "../../README.md" ]]; then
    ROOT_README="../../README.md"
else
    echo "Root README.md not found"
    exit 0
fi

if [[ ! -f "$ROOT_README" ]]; then
    echo "Root README.md not found at $ROOT_README"
    exit 0
fi

echo "Updating root README.md for ${MODULE_NAME} release ${TAG_PREFIX}${VERSION}"

# Create temporary file
TMP_FILE=$(mktemp)
cp "$ROOT_README" "$TMP_FILE"

# Function to escape special characters for sed
escape_sed() {
    echo "$1" | sed -e 's/[[\.*^$()+?{|]/\\&/g'
}

# Escaped values
ESCAPED_MODULE_NAME=$(escape_sed "$MODULE_NAME")
ESCAPED_TAG_PREFIX=$(escape_sed "$TAG_PREFIX")

# Update module status - handle both Development and already Completed status
# First, try to update from Development status
sed -i.bak "s|\[${MODULE_DISPLAY_NAME}\](./modules/${ESCAPED_MODULE_NAME}/) | 🔧 Development | - |\[${MODULE_DISPLAY_NAME}\](./modules/${ESCAPED_MODULE_NAME}/) | ✅ Completed | [${TAG_PREFIX}${VERSION}](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${TAG_PREFIX}${VERSION}) |g" "$TMP_FILE"

# Then, update existing Completed status with new version (handles any previous version)
sed -i.bak -E "s|\[${MODULE_DISPLAY_NAME}\](./modules/${ESCAPED_MODULE_NAME}/) \| ✅ Completed \| \[${ESCAPED_TAG_PREFIX}[^]]+\]\([^)]+\)|\[${MODULE_DISPLAY_NAME}\](./modules/${ESCAPED_MODULE_NAME}/) | ✅ Completed | [${TAG_PREFIX}${VERSION}](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${TAG_PREFIX}${VERSION})|g" "$TMP_FILE"

# Add or update module version badge at the top of the file
echo "Adding/updating version badge for ${MODULE_NAME}"

# Check if any module badges section exists
if ! grep -q "<!-- MODULE BADGES START -->" "$TMP_FILE"; then
    echo "Creating module badges section"
    # Add the badges section after the main badges (after AzureRM Provider badge line)
    sed -i.bak "/\[AzureRM Provider\]/a\\
\\
<!-- MODULE BADGES START -->\\
<!-- MODULE BADGES END -->" "$TMP_FILE"
fi

# Remove existing badge for this module if it exists
sed -i.bak "/\[${MODULE_DISPLAY_NAME}\].*img.shields.io.*${ESCAPED_TAG_PREFIX}/d" "$TMP_FILE"

# Add the new badge in the badges section
sed -i.bak "/<!-- MODULE BADGES START -->/a\\
[![${MODULE_DISPLAY_NAME}](https://img.shields.io/github/v/tag/${REPO_OWNER}/${REPO_NAME}?filter=${TAG_PREFIX}*&label=${MODULE_DISPLAY_NAME}&color=success)](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases?q=${TAG_PREFIX})" "$TMP_FILE"

# Update the example module reference with correct source path
echo "Updating example module reference"
if grep -q 'source = "github.com/your-org/azurerm-terraform-modules' "$TMP_FILE"; then
    sed -i.bak "s|github.com/your-org/azurerm-terraform-modules|github.com/${REPO_OWNER}/${REPO_NAME}|g" "$TMP_FILE"
fi

# Copy back the updated file
cp "$TMP_FILE" "$ROOT_README"
rm -f "$TMP_FILE" "${TMP_FILE}.bak"

echo "Root README.md updated successfully"