#!/bin/bash
# Create module.json file for a Terraform module

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to convert module name to different formats
convert_name() {
    local module_name=$1
    local format=$2
    local base_name="$module_name"

    for prefix in azurerm_ azuredevops_ kubernetes_; do
        if [[ "$base_name" == "${prefix}"* ]]; then
            base_name="${base_name#${prefix}}"
            break
        fi
    done
    
    case $format in
        "title")
            echo "$base_name" | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
            ;;
        "scope")
            echo "$base_name" | sed 's/_/-/g'
            ;;
        "prefix")
            local words=$(echo "$base_name" | sed 's/_/ /g')
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

PROVIDER_LABEL="Azure"
if [[ "$MODULE_NAME" == azuredevops_* ]]; then
    PROVIDER_LABEL="Azure DevOps"
elif [[ "$MODULE_NAME" == kubernetes_* ]]; then
    PROVIDER_LABEL="Kubernetes"
fi

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
  "description": "$PROVIDER_LABEL $TITLE Terraform module with enterprise-grade features"
}
EOF

echo "✅ Created $MODULE_JSON_PATH"

# Also create/update .releaserc.js if it doesn't exist or is old format
RELEASERC_PATH="$MODULE_DIR/.releaserc.js"
TEMPLATE_RELEASERC="$SCRIPT_DIR/templates/.releaserc.js"
if [[ ! -f "$RELEASERC_PATH" ]] || ! grep -q "module.json" "$RELEASERC_PATH"; then
    if [[ -f "$TEMPLATE_RELEASERC" ]]; then
        echo "📝 Creating/updating $RELEASERC_PATH..."
        cp "$TEMPLATE_RELEASERC" "$RELEASERC_PATH"
        echo "✅ Created/updated $RELEASERC_PATH"
    else
        echo "⚠️  Template $TEMPLATE_RELEASERC not found. Skipping .releaserc.js creation."
    fi
fi
