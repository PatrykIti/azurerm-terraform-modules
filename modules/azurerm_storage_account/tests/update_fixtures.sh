#!/bin/bash

# Function to update a fixture
update_fixture() {
    local fixture_dir=$1
    local main_tf="${fixture_dir}/main.tf"
    local variables_tf="${fixture_dir}/variables.tf"
    
    echo "Processing ${fixture_dir}..."
    
    # Check if main.tf exists
    if [[ ! -f "$main_tf" ]]; then
        echo "  No main.tf found, skipping..."
        return
    fi
    
    # Check if variables.tf exists, create if needed
    if [[ ! -f "$variables_tf" ]]; then
        echo "  Creating variables.tf..."
        cat > "$variables_tf" << 'EOF'
variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "northeurope"
}
EOF
    else
        # Check if random_suffix variable exists
        if ! grep -q 'variable "random_suffix"' "$variables_tf"; then
            echo "  Adding random_suffix variable to variables.tf..."
            # Add random_suffix at the beginning of the file
            tmp_file=$(mktemp)
            cat > "$tmp_file" << 'EOF'
variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

EOF
            cat "$variables_tf" >> "$tmp_file"
            mv "$tmp_file" "$variables_tf"
        fi
    fi
    
    # Remove random provider requirement
    if grep -q 'random = {' "$main_tf"; then
        echo "  Removing random provider..."
        sed -i.bak '/random = {/,/}/d' "$main_tf"
        # Clean up empty lines
        sed -i.bak '/^[[:space:]]*$/N;/\n[[:space:]]*$/d' "$main_tf"
    fi
    
    # Remove random_string resources
    if grep -q 'resource "random_string"' "$main_tf"; then
        echo "  Removing random_string resources..."
        sed -i.bak '/resource "random_string"/,/^}/d' "$main_tf"
    fi
    
    # Replace random_string references with var.random_suffix
    if grep -q 'random_string\.[^.]*\.result' "$main_tf"; then
        echo "  Replacing random_string references..."
        sed -i.bak 's/\${random_string\.[^}]*\.result}/\${var.random_suffix}/g' "$main_tf"
    fi
    
    # Clean up backup files
    rm -f "${main_tf}.bak" "${variables_tf}.bak"
}

# Process all fixtures
for fixture in fixtures/*/; do
    if [[ -d "$fixture" ]]; then
        update_fixture "$fixture"
    fi
done

# Process negative test fixtures
for fixture in fixtures/negative/*/; do
    if [[ -d "$fixture" ]]; then
        update_fixture "$fixture"
    fi
done

echo "Fixture update complete!"