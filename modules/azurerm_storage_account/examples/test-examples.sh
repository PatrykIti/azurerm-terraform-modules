#!/bin/bash
# Storage Account Examples Testing Script
# Tests all examples in order from simple to complex

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to test an example
test_example() {
    local example_name=$1
    local example_path=$2
    
    echo ""
    echo "=================================="
    print_status "Testing: $example_name"
    echo "=================================="
    
    cd "$example_path"
    
    # Initialize Terraform
    print_status "Running terraform init..."
    terraform init -upgrade
    
    # Validate configuration
    print_status "Running terraform validate..."
    terraform validate
    
    # Format check
    print_status "Running terraform fmt check..."
    terraform fmt -check || {
        print_warning "Formatting issues found. Running terraform fmt..."
        terraform fmt
    }
    
    # Plan
    print_status "Running terraform plan..."
    terraform plan -out=tfplan
    
    # Apply with auto-approve (for testing)
    read -p "Do you want to apply this example? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running terraform apply..."
        terraform apply tfplan
        
        # Show outputs
        print_status "Terraform outputs:"
        terraform output
        
        # Wait before destroy
        read -p "Press any key to destroy resources..." -n 1 -r
        echo
        
        # Destroy
        print_status "Running terraform destroy..."
        terraform destroy -auto-approve
    else
        print_warning "Skipping apply for $example_name"
        rm -f tfplan
    fi
    
    cd - > /dev/null
}

# Main script
print_status "Azure Storage Account Module Examples Testing"
print_status "Current Azure Subscription: $(az account show --query name -o tsv)"
print_status "Subscription ID: $(az account show --query id -o tsv)"

# Base path for examples
BASE_PATH="/Users/pciechanski/Documents/_moje_projekty/azurerm-terraform-modules/modules/azurerm_storage_account/examples"

# Test examples in order from simple to complex
examples=(
    "simple:$BASE_PATH/simple"
    "secure-private-endpoint:$BASE_PATH/secure-private-endpoint"
    "secure:$BASE_PATH/secure"
    "complete:$BASE_PATH/complete"
    "multi-region:$BASE_PATH/multi-region"
)

# Create a test results file
RESULTS_FILE="$BASE_PATH/test-results-$(date +%Y%m%d-%H%M%S).txt"
echo "Storage Account Examples Test Results" > "$RESULTS_FILE"
echo "====================================" >> "$RESULTS_FILE"
echo "Date: $(date)" >> "$RESULTS_FILE"
echo "Subscription: $(az account show --query name -o tsv)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Run tests
for example in "${examples[@]}"; do
    IFS=':' read -r name path <<< "$example"
    
    if [ -d "$path" ]; then
        {
            test_example "$name" "$path"
            echo "✓ $name: SUCCESS" >> "$RESULTS_FILE"
        } || {
            print_error "Failed to test $name"
            echo "✗ $name: FAILED" >> "$RESULTS_FILE"
        }
    else
        print_error "Example directory not found: $path"
        echo "✗ $name: NOT FOUND" >> "$RESULTS_FILE"
    fi
done

print_status "Testing complete! Results saved to: $RESULTS_FILE"
cat "$RESULTS_FILE"