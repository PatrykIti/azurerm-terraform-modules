#!/bin/bash

# Source environment variables if they exist
if [ -f "./test_env.sh" ]; then
  source ./test_env.sh
fi

# Create output directory for test results
OUTPUT_DIR="test_outputs/sequential_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Function to run a single test and save output
run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"
    
    echo "Running test: $test_name"
    
    go test -v -timeout 60m -run "^${test_name}$" . 2>&1 | tee "$log_file"
    local exit_status=${PIPESTATUS[0]}
    
    cat > "$output_file" << EOF
{
  "test_name": "$test_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "log_file": "$log_file"
}
EOF
    
    echo "Test $test_name completed with status: $exit_status"
    return $exit_status
}

# List of tests to run
tests=(
    "TestBasicLinuxFunctionApp"
    "TestCompleteLinuxFunctionApp"
    "TestSecureLinuxFunctionApp"
    "TestNetworkLinuxFunctionApp"
    "TestLinuxFunctionAppPrivateEndpoint"
    "TestLinuxFunctionAppValidationRules"
    "TestLinuxFunctionAppFullIntegration"
    "TestLinuxFunctionAppLifecycle"
    "TestLinuxFunctionAppCreationTime"
    "BenchmarkLinuxFunctionAppCreation"
)

echo "Starting sequential test execution for azurerm_linux_function_app"
echo "Total tests to run: ${#tests[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

for test in "${tests[@]}"; do
    run_test "$test" || true
done

echo "=================================="
echo "Sequential test execution completed!"
echo "Results saved in: $OUTPUT_DIR"
exit 0
