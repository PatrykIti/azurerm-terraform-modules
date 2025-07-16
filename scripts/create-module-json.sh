#!/bin/bash
# Create module.json file for a Terraform module

set -e

# Function to convert module name to different formats
convert_name() {
    local module_name=$1
    local format=$2
    
    case $format in
        "title")
            # azurerm_storage_account -> Storage Account
            echo "$module_name" | sed 's/azurerm_//' | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
            ;;
        "scope")
            # azurerm_storage_account -> storage-account
            echo "$module_name" | sed 's/azurerm_//' | sed 's/_/-/g'
            ;;
        "prefix")
            # azurerm_storage_account -> SAv
            local words=$(echo "$module_name" | sed 's/azurerm_//' | sed 's/_/ /g')
            local prefix=""
            for word in $words; do
                prefix="${prefix}$(echo $word | cut -c1 | tr '[:lower:]' '[:upper:]')"
            done
            echo "${prefix}v"
            ;;
    esac
}

# Main execution
if [[ -z "$1" ]]; then
    echo "Usage: $0 <module-directory> [title] [scope] [prefix]"
    echo "Example: $0 modules/azurerm_storage_account"
    echo "         $0 modules/azurerm_storage_account 'Storage Account' storage-account SAv"
    exit 1
fi

MODULE_DIR=$1
MODULE_NAME=$(basename "$MODULE_DIR")

# Use provided values or auto-generate
TITLE=${2:-$(convert_name "$MODULE_NAME" "title")}
SCOPE=${3:-$(convert_name "$MODULE_NAME" "scope")}
PREFIX=${4:-$(convert_name "$MODULE_NAME" "prefix")}

# Create module.json
MODULE_JSON_PATH="$MODULE_DIR/module.json"

echo "📝 Creating $MODULE_JSON_PATH..."
echo "   Module: $MODULE_NAME"
echo "   Title: $TITLE"
echo "   Scope: $SCOPE"
echo "   Prefix: $PREFIX"

cat > "$MODULE_JSON_PATH" << EOF
{
  "name": "$MODULE_NAME",
  "title": "$TITLE",
  "commit_scope": "$SCOPE",
  "tag_prefix": "$PREFIX",
  "description": "Azure $TITLE Terraform module with enterprise-grade features"
}
EOF

echo "✅ Created $MODULE_JSON_PATH"

# Also create/update .releaserc.js if it doesn't exist or is old format
RELEASERC_PATH="$MODULE_DIR/.releaserc.js"
if [[ ! -f "$RELEASERC_PATH" ]] || ! grep -q "module.json" "$RELEASERC_PATH"; then
    echo "📝 Creating/updating $RELEASERC_PATH..."
    cp scripts/templates/.releaserc.auto.js "$RELEASERC_PATH"
    echo "✅ Created/updated $RELEASERC_PATH"
fi