#!/bin/bash

# Script to generate documentation using terraform-docs
# Requires terraform-docs to be installed

set -e

echo "Generating documentation for Azure Storage Account module..."

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "terraform-docs is not installed. Please install it first:"
    echo "  brew install terraform-docs"
    echo "  or"
    echo "  curl -sSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64.tar.gz"
    exit 1
fi

# Generate main module documentation
echo "Generating main module documentation..."
terraform-docs markdown table . --config .terraform-docs.yml --output-file README.md --output-mode inject

# Generate documentation for examples
for example in examples/*/; do
    if [ -d "$example" ]; then
        example_name=$(basename "$example")
        echo "Generating documentation for example: $example_name"
        
        # Create a simple terraform-docs config for examples
        cat > "$example/.terraform-docs.yml" << EOF
formatter: "markdown"
content: |-
  {{ .Providers }}
  {{ .Inputs }}
  {{ .Outputs }}
EOF
        
        # Generate and append to example README
        if [ -f "$example/README.md" ]; then
            echo -e "\n## Module Documentation\n" >> "$example/README.md"
            terraform-docs markdown "$example" >> "$example/README.md"
        fi
        
        # Clean up temp config
        rm -f "$example/.terraform-docs.yml"
    fi
done

echo "Documentation generation complete!"
echo ""
echo "Next steps:"
echo "1. Review the generated documentation in README.md"
echo "2. Check example documentation in examples/*/README.md"
echo "3. Commit the changes if everything looks correct"