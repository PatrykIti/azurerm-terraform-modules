#!/bin/bash
# Validate Terraform module structure

set -e

echo "📁 Validating module structure..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VALID=true

# Function to check if file exists
check_file() {
    local module=$1
    local file=$2
    local required=$3
    
    if [ -f "${module}/${file}" ]; then
        echo -e "${GREEN}✓${NC} ${module}/${file}"
    else
        if [ "$required" = "required" ]; then
            echo -e "${RED}✗${NC} ${module}/${file} (required)"
            VALID=false
        else
            echo -e "${YELLOW}⚠${NC} ${module}/${file} (recommended)"
        fi
    fi
}

# Function to check module structure
check_module() {
    local module=$1
    
    if [ ! -d "$module" ]; then
        return
    fi
    
    echo -e "\n${YELLOW}Checking module: ${module}${NC}"
    
    # Required files
    check_file "$module" "main.tf" "required"
    check_file "$module" "variables.tf" "required"
    check_file "$module" "outputs.tf" "required"
    check_file "$module" "versions.tf" "required"
    check_file "$module" "README.md" "required"
    
    # Recommended files
    check_file "$module" "SECURITY.md" "recommended"
    check_file "$module" "examples/simple/main.tf" "recommended"
    check_file "$module" "examples/complete/main.tf" "recommended"
}

# Check each module directory
for dir in */; do
    if [[ "$dir" =~ ^azurerm_ ]] || [[ "$dir" =~ ^modules/ ]]; then
        check_module "${dir%/}"
    fi
done

# Check root-level files
echo -e "\n${YELLOW}Checking root-level files${NC}"
check_file "." ".gitignore" "required"
check_file "." "README.md" "required"
check_file "." "CONTRIBUTING.md" "recommended"
check_file "." ".pre-commit-config.yaml" "recommended"
check_file "." ".checkov.yaml" "required"
check_file "." ".tfsec.yml" "required"
check_file "docs" "SECURITY.md" "required"

# Additional structure checks
echo -e "\n${YELLOW}Additional checks${NC}"

# Check for security examples
if find . -path "*/examples/*" -name "*secure*" -o -name "*private*" | grep -q .; then
    echo -e "${GREEN}✓${NC} Security-focused examples found"
else
    echo -e "${YELLOW}⚠${NC} No security-focused examples found"
fi

# Check for tests
if [ -d "tests" ] && find tests -name "*.go" -o -name "*.tf" | grep -q .; then
    echo -e "${GREEN}✓${NC} Test files found"
else
    echo -e "${YELLOW}⚠${NC} No test files found"
fi

# Summary
echo -e "\n${YELLOW}Structure Validation Summary${NC}"
echo "============================"

if [ "$VALID" = true ]; then
    echo -e "${GREEN}✅ Module structure is valid!${NC}"
    exit 0
else
    echo -e "${RED}❌ Module structure has issues. Please fix them.${NC}"
    exit 1
fi