#!/bin/bash
# Update .releaserc.js files to use the new multi-scope filter

set -e

# Function to extract configuration from existing .releaserc.js
extract_config() {
    local file=$1
    local module_name=$(sed -n "s/^const MODULE_NAME = '\([^']*\)'.*/\1/p" "$file" | head -1)
    local commit_scope=$(sed -n "s/^const COMMIT_SCOPE = '\([^']*\)'.*/\1/p" "$file" | head -1)
    local tag_prefix=$(sed -n "s/^const TAG_PREFIX = '\([^']*\)'.*/\1/p" "$file" | head -1)
    local module_title=$(sed -n "s/^const MODULE_TITLE = '\([^']*\)'.*/\1/p" "$file" | head -1)
    
    echo "$module_name|$commit_scope|$tag_prefix|$module_title"
}

# Update a single module's .releaserc.js
update_module() {
    local module_dir=$1
    local releaserc_file="$module_dir/.releaserc.js"
    
    if [[ ! -f "$releaserc_file" ]]; then
        echo "⚠️  No .releaserc.js found in $module_dir, skipping..."
        return
    fi
    
    echo "📝 Updating $releaserc_file..."
    
    # Extract existing configuration
    IFS='|' read -r module_name commit_scope tag_prefix module_title <<< "$(extract_config "$releaserc_file")"
    
    if [[ -z "$module_name" || -z "$commit_scope" || -z "$tag_prefix" || -z "$module_title" ]]; then
        echo "❌ Failed to extract configuration from $releaserc_file"
        return 1
    fi
    
    echo "   Module: $module_name"
    echo "   Scope: $commit_scope"
    echo "   Tag Prefix: $tag_prefix"
    echo "   Title: $module_title"
    
    # Create backup
    cp "$releaserc_file" "$releaserc_file.bak"
    
    # Copy auto-loading template
    cp scripts/templates/.releaserc.auto.js "$releaserc_file"
    
    echo "✅ Updated $releaserc_file"
}

# Main execution
echo "🔄 Updating .releaserc.js files for multi-scope support..."

# Update all modules or specific module
if [[ -n "$1" ]]; then
    # Update specific module
    update_module "modules/$1"
else
    # Update all modules
    for module_dir in modules/*/; do
        if [[ -d "$module_dir" ]]; then
            update_module "$module_dir"
        fi
    done
fi

echo "✅ Done!"