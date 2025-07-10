#!/bin/bash

# Update module version in README.md
# Usage: ./update-module-version.sh <module-path> <version>

set -e

MODULE_PATH="${1:-.}"
VERSION="${2}"
README_PATH="$MODULE_PATH/README.md"

# Check if README exists
if [[ ! -f "$README_PATH" ]]; then
    echo "❌ README.md not found in $MODULE_PATH"
    exit 1
fi

# Check if version provided
if [[ -z "$VERSION" ]]; then
    echo "❌ Version not provided"
    echo "Usage: $0 <module-path> <version>"
    exit 1
fi

# Extract module prefix from .releaserc.js if exists
MODULE_PREFIX=""
if [[ -f "$MODULE_PATH/.releaserc.js" ]]; then
    MODULE_PREFIX=$(grep -o "TAG_PREFIX = '[^']*'" "$MODULE_PATH/.releaserc.js" | sed "s/TAG_PREFIX = '\\([^']*\\)'/\\1/" || echo "")
fi

# Format version (add prefix if not already present and not "vUnreleased")
if [[ "$VERSION" == "vUnreleased" ]]; then
    FORMATTED_VERSION="vUnreleased"
elif [[ -n "$MODULE_PREFIX" ]] && [[ "$VERSION" != "$MODULE_PREFIX"* ]]; then
    FORMATTED_VERSION="${MODULE_PREFIX}${VERSION}"
else
    FORMATTED_VERSION="${VERSION}"
fi

# Create temporary file
TEMP_FILE=$(mktemp)

# Process README and update version section
awk -v version="$FORMATTED_VERSION" '
BEGIN {
    in_version = 0
    found_begin = 0
    found_end = 0
}
/<!-- BEGIN_VERSION -->/ {
    in_version = 1
    found_begin = 1
    print
    print "Current version: **" version "**"
    next
}
/<!-- END_VERSION -->/ {
    in_version = 0
    found_end = 1
    print
    next
}
!in_version {
    print
}
END {
    if (found_begin && !found_end) {
        print "<!-- END_VERSION -->"
    }
}
' "$README_PATH" > "$TEMP_FILE"

# Check if markers were found
if ! grep -q "<!-- BEGIN_VERSION -->" "$TEMP_FILE"; then
    echo "⚠️  Warning: <!-- BEGIN_VERSION --> marker not found in $README_PATH"
    echo "Trying to update legacy format..."
    
    # Try to update the old format
    sed -i.bak "s/Current version: \*\*[^*]*\*\*/Current version: **$FORMATTED_VERSION**/" "$README_PATH"
    
    if grep -q "Current version: \*\*$FORMATTED_VERSION\*\*" "$README_PATH"; then
        echo "✅ Updated version to $FORMATTED_VERSION in $README_PATH (legacy format)"
        rm -f "$README_PATH.bak"
    else
        echo "❌ Failed to update version"
        mv "$README_PATH.bak" "$README_PATH"
        exit 1
    fi
    rm -f "$TEMP_FILE"
else
    # Compare and update if different
    if ! diff -q "$README_PATH" "$TEMP_FILE" > /dev/null 2>&1; then
        mv "$TEMP_FILE" "$README_PATH"
        echo "✅ Updated version to $FORMATTED_VERSION in $README_PATH"
    else
        rm -f "$TEMP_FILE"
        echo "✅ Version is already up to date in $README_PATH"
    fi
fi