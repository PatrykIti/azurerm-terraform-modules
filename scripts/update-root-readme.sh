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
ROOT_README="../../README.md"

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

# Update module status from Development to Completed with version link
sed -i.bak "s|\[${MODULE_DISPLAY_NAME}\](./modules/${ESCAPED_MODULE_NAME}/) | 🔧 Development | - |\[${MODULE_DISPLAY_NAME}\](./modules/${ESCAPED_MODULE_NAME}/) | ✅ Completed | [${TAG_PREFIX}${VERSION}](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${TAG_PREFIX}${VERSION}) |g" "$TMP_FILE"

# Add module version badge if it doesn't exist
if ! grep -q "img.shields.io/github/v/tag.*filter=${ESCAPED_TAG_PREFIX}" "$TMP_FILE"; then
    echo "Adding version badge for ${MODULE_NAME}"
    
    # Find the line with "## 📦 Available Modules" and add badge after it
    sed -i.bak "/## 📦 Available Modules/a\\
\\
[![${MODULE_DISPLAY_NAME} Version](https://img.shields.io/github/v/tag/${REPO_OWNER}/${REPO_NAME}?filter=${TAG_PREFIX}*&label=${MODULE_NAME})](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases?q=${TAG_PREFIX})" "$TMP_FILE"
fi

# Copy back the updated file
cp "$TMP_FILE" "$ROOT_README"
rm -f "$TMP_FILE" "${TMP_FILE}.bak"

echo "Root README.md updated successfully"