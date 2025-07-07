#!/bin/bash

# Generate terraform-docs configuration with dynamic examples list
# Usage: ./generate-terraform-docs-config.sh <module-path>

set -e

MODULE_PATH="${1:-.}"
MODULE_NAME=$(basename "$MODULE_PATH")

# Extract module prefix from the module config or use a default
if [[ -f "$MODULE_PATH/.releaserc.js" ]]; then
    MODULE_PREFIX=$(grep -o "tagFormat:.*'\([A-Za-z]*\)v" "$MODULE_PATH/.releaserc.js" | sed "s/tagFormat:.*'\([A-Za-z]*\)v/\1/" | head -1 || echo "v")
else
    MODULE_PREFIX="v"
fi

# Get current version from CHANGELOG or default
if [[ -f "$MODULE_PATH/CHANGELOG.md" ]]; then
    CURRENT_VERSION=$(grep -m1 "^## \[" "$MODULE_PATH/CHANGELOG.md" | sed 's/## \[\(.*\)\].*/\1/' || echo "1.0.0")
else
    CURRENT_VERSION="1.0.0"
fi

# Get module description from README.md or use default
if [[ -f "$MODULE_PATH/README.md" ]]; then
    # Extract description from between "## Description" and next ## heading
    DESCRIPTION=$(awk '/^## Description/{flag=1; next} /^##/{flag=0} flag' "$MODULE_PATH/README.md" | grep -v "^$" | head -5 | tr '\n' ' ' | xargs)
fi

# If no description in README, try main.tf header
if [[ -z "$DESCRIPTION" ]] && [[ -f "$MODULE_PATH/main.tf" ]]; then
    DESCRIPTION=$(awk '/^#/{p=1} p&&/^[^#]/{exit} p' "$MODULE_PATH/main.tf" | grep -v "^#$" | sed 's/^# *//' | grep -v "^-*$" | head -5 | tr '\n' ' ' | xargs)
fi

# Use default if still empty
if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="Terraform module for managing $MODULE_NAME resources."
fi

# Find the first available example for the usage section
USAGE_EXAMPLE=""
if [[ -d "$MODULE_PATH/examples" ]]; then
    for example in basic simple complete; do
        if [[ -f "$MODULE_PATH/examples/$example/main.tf" ]]; then
            USAGE_EXAMPLE="examples/$example/main.tf"
            break
        fi
    done
    
    # If no standard example found, use the first one
    if [[ -z "$USAGE_EXAMPLE" ]]; then
        USAGE_EXAMPLE=$(find "$MODULE_PATH/examples" -name "main.tf" -type f | head -1 | sed "s|$MODULE_PATH/||")
    fi
fi

# Generate examples list dynamically
EXAMPLES_LIST=""
if [[ -d "$MODULE_PATH/examples" ]]; then
    # Get all example directories and sort them
    for example_dir in $(find "$MODULE_PATH/examples" -mindepth 1 -maxdepth 1 -type d | sort); do
        if [[ -f "$example_dir/main.tf" ]]; then
            example_name=$(basename "$example_dir")
            # Convert directory name to human-readable format
            # First letter uppercase, rest lowercase, replace hyphens with spaces
            example_title=$(echo "$example_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
            
            # Try to extract description from README or main.tf
            example_desc=""
            if [[ -f "$example_dir/README.md" ]]; then
                # Get first non-empty line after # heading
                example_desc=$(grep -A5 "^#" "$example_dir/README.md" | grep -v "^#" | grep -v "^$" | head -1 || echo "")
            fi
            
            if [[ -z "$example_desc" ]] && [[ -f "$example_dir/main.tf" ]]; then
                # Get first comment line from main.tf
                example_desc=$(grep "^#" "$example_dir/main.tf" | head -1 | sed 's/^# *//' || echo "")
            fi
            
            # Use a generic description if none found
            if [[ -z "$example_desc" ]]; then
                case "$example_name" in
                    basic|simple)
                        example_desc="Basic configuration example"
                        ;;
                    complete|full)
                        example_desc="Full-featured configuration with all options"
                        ;;
                    secure*)
                        example_desc="Security-focused configuration"
                        ;;
                    multi-region*)
                        example_desc="Multi-region deployment example"
                        ;;
                    data-lake*)
                        example_desc="Data Lake Storage configuration"
                        ;;
                    private-endpoint*)
                        example_desc="Private endpoint configuration"
                        ;;
                    *)
                        example_desc="$example_title configuration example"
                        ;;
                esac
            fi
            
            EXAMPLES_LIST="${EXAMPLES_LIST}  - [$example_title](examples/$example_name) - $example_desc\n"
        fi
    done
fi

# If no examples found, add a placeholder
if [[ -z "$EXAMPLES_LIST" ]]; then
    EXAMPLES_LIST="  - No examples available yet\n"
fi

# Generate the terraform-docs configuration
cat > "$MODULE_PATH/.terraform-docs.yml" << EOF
formatter: "markdown table"

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules

sections:
  hide: []
  show: []

content: |-
  {{ .Header }}

  ## Module Version

  Current version: **${MODULE_PREFIX}v${CURRENT_VERSION}**

  ## Description

  ${DESCRIPTION}

  ## Usage

  \`\`\`hcl
EOF

# Add the usage example include
if [[ -n "$USAGE_EXAMPLE" ]]; then
    echo "  {{ include \"$USAGE_EXAMPLE\" }}" >> "$MODULE_PATH/.terraform-docs.yml"
else
    echo "  # See examples directory for usage" >> "$MODULE_PATH/.terraform-docs.yml"
fi

cat >> "$MODULE_PATH/.terraform-docs.yml" << 'EOF'
  ```

  ## Examples

EOF

# Add the examples list
echo -e "$EXAMPLES_LIST" | sed 's/^/  /' >> "$MODULE_PATH/.terraform-docs.yml"

# Add the rest of the template
cat >> "$MODULE_PATH/.terraform-docs.yml" << 'EOF'
  ## Requirements

  {{ .Requirements }}

  ## Providers

  {{ .Providers }}

  ## Modules

  {{ .Modules }}

  ## Resources

  {{ .Resources }}

  ## Inputs

  {{ .Inputs }}

  ## Outputs

  {{ .Outputs }}

  ## Additional Documentation

  - [VERSIONING.md](VERSIONING.md) - Module versioning and release process
  - [SECURITY.md](SECURITY.md) - Security features and configuration guidelines

  {{ if .Config.Sections.Footer }}
  {{ .Footer }}
  {{ end }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

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

echo "✅ Generated .terraform-docs.yml for $MODULE_NAME with dynamic examples list"