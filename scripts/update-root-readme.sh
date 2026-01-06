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
if [ -f "README.md" ]; then
    ROOT_README="README.md"
elif [ -f "../../README.md" ]; then
    ROOT_README="../../README.md"
else
    echo "Root README.md not found"
    exit 1
fi

if [ ! -f "$ROOT_README" ]; then
    echo "Root README.md not found at $ROOT_README"
    exit 1
fi

echo "Updating root README.md for ${MODULE_NAME} release ${TAG_PREFIX}${VERSION}"

# Create temporary file
TMP_FILE=$(mktemp)
cp "$ROOT_README" "$TMP_FILE"

# Function to escape special characters for sed
escape_sed() {
    echo "$1" | sed -e 's/[\[\.*^$()+?{|]/\\&/g'
}

# Escaped values
ESCAPED_TAG_PREFIX=$(escape_sed "$TAG_PREFIX")
ESCAPED_MODULE_DISPLAY_NAME=$(escape_sed "$MODULE_DISPLAY_NAME")

# Update module table row (AzureRM or Azure DevOps tables)
VERSION_TAG="${TAG_PREFIX}${VERSION}"
VERSION_LINK="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${VERSION_TAG}"

awk -v module="$MODULE_NAME" -v version_tag="$VERSION_TAG" -v version_link="$VERSION_LINK" '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
{
    if ($0 ~ /^\|/ && $0 ~ "\\(./modules/" module "/\\)") {
        n = split($0, parts, "|")
        if (n >= 5) {
            module_cell = trim(parts[2])
            desc_cell = trim(parts[5])
            status = "✅ Completed"
            version = "[" version_tag "](" version_link ")"
            printf("| %s | %s | %s | %s |\n", module_cell, status, version, desc_cell)
            next
        }
    }
    print
}
' "$TMP_FILE" > "${TMP_FILE}.new"
mv "${TMP_FILE}.new" "$TMP_FILE"

if ! grep -q "(./modules/${MODULE_NAME}/)" "$TMP_FILE"; then
    echo "⚠️  Module entry not found in root README table: ${MODULE_NAME}"
fi

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

# Remove existing badge(s) for this module (regardless of prefix)
sed -i.bak "/\[${ESCAPED_MODULE_DISPLAY_NAME}\].*img.shields.io/d" "$TMP_FILE"

# URL encode the module display name for the badge label
URL_ENCODED_NAME=$(echo "$MODULE_DISPLAY_NAME" | sed 's/ /%20/g')

# Add the new badge in the badges section
sed -i.bak "/<!-- MODULE BADGES START -->/a\\
[![${MODULE_DISPLAY_NAME}](https://img.shields.io/github/v/tag/${REPO_OWNER}/${REPO_NAME}?filter=${TAG_PREFIX}*&label=${URL_ENCODED_NAME}&color=success)](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${VERSION_TAG})" "$TMP_FILE"

# Update the example module reference with correct source path
echo "Updating example module reference"
if grep -q 'source = "github.com/your-org/azurerm-terraform-modules' "$TMP_FILE"; then
    sed -i.bak "s|github.com/your-org/azurerm-terraform-modules|github.com/${REPO_OWNER}/${REPO_NAME}|g" "$TMP_FILE"
fi

# Update any root README snippets that reference this module's source tag
sed -i.bak -E "s#(source = \"github.com/${REPO_OWNER}/${REPO_NAME}//modules/${MODULE_NAME}\\?ref=)[^\"]+\"#\\1${VERSION_TAG}\"#g" "$TMP_FILE"

# Copy back the updated file
cp "$TMP_FILE" "$ROOT_README"
rm -f "$TMP_FILE" "${TMP_FILE}.bak"

echo "Root README.md updated successfully"
