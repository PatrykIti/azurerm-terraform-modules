#!/bin/bash

# Update examples list in module README.md
# Usage: ./update-examples-list.sh <module-path>

set -e

MODULE_PATH="${1:-.}"
README_PATH="$MODULE_PATH/README.md"

# Check if README exists
if [[ ! -f "$README_PATH" ]]; then
    echo "❌ README.md not found in $MODULE_PATH"
    exit 1
fi

# Check if examples directory exists
if [[ ! -d "$MODULE_PATH/examples" ]]; then
    echo "ℹ️  No examples directory found in $MODULE_PATH"
    exit 0
fi

# Generate examples list
EXAMPLES_LIST=""
examples_found=false

# Get all example directories and sort them
for example_dir in $(find "$MODULE_PATH/examples" -mindepth 1 -maxdepth 1 -type d | sort); do
    if [[ -f "$example_dir/main.tf" ]]; then
        examples_found=true
        example_name=$(basename "$example_dir")
        
        # Convert directory name to human-readable format
        # First letter uppercase, rest lowercase, replace hyphens with spaces
        example_title=$(echo "$example_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        
        # Try to extract description from README or main.tf
        example_desc=""
        
        # First try README.md
        if [[ -f "$example_dir/README.md" ]]; then
            # Get first paragraph after the main heading
            example_desc=$(awk '/^#[^#]/{p=1; next} /^#{1,2} /{p=0} p && /^[[:alnum:]]/' "$example_dir/README.md" | head -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        fi
        
        # If no description in README, try main.tf header comments
        if [[ -z "$example_desc" ]] && [[ -f "$example_dir/main.tf" ]]; then
            # Get first non-empty comment line
            example_desc=$(awk '/^# / && !/^# -/ && !/^#$/{gsub(/^# /, ""); print; exit}' "$example_dir/main.tf")
        fi
        
        # Use a generic description if none found
        if [[ -z "$example_desc" ]]; then
            case "$example_name" in
                basic|simple)
                    example_desc="Basic configuration example with minimal setup"
                    ;;
                complete|full)
                    example_desc="Complete configuration example with all features"
                    ;;
                secure*)
                    example_desc="Security-focused configuration example"
                    ;;
                private-endpoint*)
                    example_desc="Private endpoint configuration example"
                    ;;
                multi-region*)
                    example_desc="Multi-region deployment example"
                    ;;
                data-lake*)
                    example_desc="Data Lake Storage configuration example"
                    ;;
                identity*)
                    example_desc="Identity-based access configuration example"
                    ;;
                advanced*)
                    example_desc="Advanced configuration example"
                    ;;
                *)
                    example_desc="Example configuration for $example_title"
                    ;;
            esac
        fi
        
        # Add to list with proper indentation
        EXAMPLES_LIST="${EXAMPLES_LIST}- [${example_title}](examples/${example_name}) - ${example_desc}\n"
    fi
done

# If no examples found with main.tf, exit
if [[ "$examples_found" = false ]]; then
    echo "ℹ️  No examples with main.tf found in $MODULE_PATH/examples"
    exit 0
fi

# Create temporary file
TEMP_FILE=$(mktemp)

# Process README and update examples section
awk -v examples="$EXAMPLES_LIST" '
BEGIN {
    in_examples = 0
    found_begin = 0
    found_end = 0
}
/<!-- BEGIN_EXAMPLES -->/ {
    in_examples = 1
    found_begin = 1
    print
    printf "%s", examples
    next
}
/<!-- END_EXAMPLES -->/ {
    in_examples = 0
    found_end = 1
    print
    next
}
!in_examples {
    print
}
END {
    if (found_begin && !found_end) {
        print "<!-- END_EXAMPLES -->"
    }
}
' "$README_PATH" > "$TEMP_FILE"

# Check if markers were found
if ! grep -q "<!-- BEGIN_EXAMPLES -->" "$TEMP_FILE"; then
    echo "⚠️  Warning: <!-- BEGIN_EXAMPLES --> marker not found in $README_PATH"
    echo "Please add the following to your README.md where you want the examples list:"
    echo ""
    echo "<!-- BEGIN_EXAMPLES -->"
    echo "<!-- Examples list will be auto-generated here -->"
    echo "<!-- END_EXAMPLES -->"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Compare and update if different
if ! diff -q "$README_PATH" "$TEMP_FILE" > /dev/null 2>&1; then
    mv "$TEMP_FILE" "$README_PATH"
    echo "✅ Updated examples list in $README_PATH"
else
    rm -f "$TEMP_FILE"
    echo "✅ Examples list is already up to date in $README_PATH"
fi