#!/bin/bash
# Security scanning script for Terraform modules

set -e

echo "🔒 Starting security scan..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any issues were found
ISSUES_FOUND=0

# Function to run a security tool
run_security_tool() {
    local tool_name=$1
    local tool_command=$2
    
    echo -e "\n${YELLOW}Running ${tool_name}...${NC}"
    
    if eval "${tool_command}"; then
        echo -e "${GREEN}✓ ${tool_name} passed${NC}"
    else
        echo -e "${RED}✗ ${tool_name} found issues${NC}"
        ISSUES_FOUND=1
    fi
}

# Check if tools are installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        echo "Please install $1 to run security scans"
        exit 1
    fi
}

# Check required tools
echo "Checking required tools..."
check_tool terraform
check_tool checkov
check_tool tfsec

# Terraform validation
run_security_tool "Terraform Format Check" "terraform fmt -check -recursive"
run_security_tool "Terraform Validation" "terraform init -backend=false && terraform validate"

# Security scans
run_security_tool "Checkov" "checkov -d . --config-file .checkov.yaml --quiet"
run_security_tool "tfsec" "tfsec . --config-file .tfsec.yml"

# Custom security checks
echo -e "\n${YELLOW}Running custom security checks...${NC}"

# Check for hardcoded secrets
if grep -r "password\|secret\|key" --include="*.tf" . | grep -v "variable\|description\|output" | grep -v "#"; then
    echo -e "${RED}✗ Potential secrets found in code${NC}"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✓ No hardcoded secrets found${NC}"
fi

# Check for secure defaults
echo "Checking security defaults..."

# Check storage account module for secure defaults
if [ -f "modules/azurerm_storage_account/variables.tf" ]; then
    # Check HTTPS enforcement
    if grep -q 'default.*=.*true.*# Security by default' modules/azurerm_storage_account/variables.tf; then
        echo -e "${GREEN}✓ Security defaults are properly configured${NC}"
    else
        echo -e "${YELLOW}⚠ Some security defaults might be missing${NC}"
    fi
fi

# Summary
echo -e "\n${YELLOW}Security Scan Summary${NC}"
echo "========================"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ All security checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Security issues found. Please fix them before committing.${NC}"
    exit 1
fi