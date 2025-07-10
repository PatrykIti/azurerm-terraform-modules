#!/bin/bash

# Fix example documentation to work with terraform-docs validation
# This creates proper terraform-docs configs for all examples

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Process storage account module examples
STORAGE_MODULE="$PROJECT_ROOT/modules/azurerm_storage_account"

# Create terraform-docs config for examples that includes custom content
create_example_config() {
    local example_dir="$1"
    local example_name=$(basename "$example_dir")
    
    echo "Creating terraform-docs config for: $example_name"
    
    # Create a simple config that preserves existing content
    cat > "$example_dir/.terraform-docs.yml" << 'EOF'
formatter: "markdown table"

header-from: main.tf

content: |-
  {{ .Header }}
  
  {{ .Requirements }}

  {{ .Providers }}

  {{ .Modules }}

  {{ .Resources }}

  {{ .Inputs }}

  {{ .Outputs }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
EOF
}

# Find all example directories
EXAMPLES=$(find "$STORAGE_MODULE/examples" -mindepth 1 -maxdepth 1 -type d | sort)

echo "Processing $(echo "$EXAMPLES" | wc -l | xargs) examples..."
echo ""

for example in $EXAMPLES; do
    example_name=$(basename "$example")
    echo "Processing: $example_name"
    
    # Create the config
    create_example_config "$example"
    
    # If README doesn't have terraform-docs markers, we need to add them
    if ! grep -q "BEGIN_TF_DOCS" "$example/README.md" 2>/dev/null; then
        echo "  Adding terraform-docs markers to README.md"
        
        # Append terraform-docs section at the end
        echo "" >> "$example/README.md"
        echo "<!-- BEGIN_TF_DOCS -->" >> "$example/README.md"
        echo "<!-- END_TF_DOCS -->" >> "$example/README.md"
    fi
    
    # Run terraform-docs to update the content
    cd "$example"
    terraform-docs markdown table . > /dev/null 2>&1 || echo "  Warning: terraform-docs failed for $example_name"
    cd - > /dev/null
    
    echo "  ✅ Completed"
done

echo ""
echo "✅ All examples processed!"
echo ""
echo "Now testing if documentation is up to date..."

# Test each example
all_good=true
for example in $EXAMPLES; do
    example_name=$(basename "$example")
    cd "$example"
    
    # Generate temp file and compare
    if terraform-docs markdown table --output-file README.md.tmp . 2>/dev/null; then
        if diff -q README.md README.md.tmp > /dev/null 2>&1; then
            echo "✅ $example_name: Documentation is up to date"
        else
            echo "❌ $example_name: Documentation differs"
            all_good=false
        fi
        rm -f README.md.tmp
    else
        echo "❌ $example_name: terraform-docs failed"
        all_good=false
    fi
    
    cd - > /dev/null
done

if [ "$all_good" = true ]; then
    echo ""
    echo "✅ All documentation is up to date!"
else
    echo ""
    echo "❌ Some documentation needs updating"
    exit 1
fi