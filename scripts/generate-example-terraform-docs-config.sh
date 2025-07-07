#!/bin/bash

# Generate terraform-docs configuration for example directories
# Usage: ./generate-example-terraform-docs-config.sh <example-path>

set -e

EXAMPLE_PATH="${1:-.}"
EXAMPLE_NAME=$(basename "$EXAMPLE_PATH")

# Generate the terraform-docs configuration for examples
cat > "$EXAMPLE_PATH/.terraform-docs.yml" << 'EOF'
formatter: "markdown table"

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false

sections:
  hide: []
  show: []

content: |-
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

echo "✅ Generated .terraform-docs.yml for example: $EXAMPLE_NAME"