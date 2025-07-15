#!/bin/bash

# Source environment variables
source ./test_env.sh

# Create output directory for test results
OUTPUT_DIR="test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Function to run a single test and save output
run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"
    
    echo "Running test: $test_name"
    echo "Output will be saved to: $output_file"
    
    # Run the test and capture output
    go test -v -timeout 30m -run "^${test_name}$" . 2>&1 | tee "$log_file"
    
    # Get exit status
    local exit_status=${PIPESTATUS[0]}
    
    # Create JSON output
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
    echo "---"
    
    return $exit_status
}

# List of tests to run
tests=(
    "TestBasicStorageAccount"
    "TestCompleteStorageAccount"
    "TestStorageAccountSecurity"
    "TestStorageAccountNetworkRules"
    "TestStorageAccountPrivateEndpoint"
    "TestStorageAccountValidationRules"
    "BenchmarkStorageAccountCreation"
)

# Summary tracking
total_tests=${#tests[@]}
passed_tests=0
failed_tests=0
skipped_tests=0

echo "Starting sequential test execution"
echo "Total tests to run: $total_tests"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

# Run each test
for test in "${tests[@]}"; do
    run_test "$test" || true  # Continue even if test fails
    
    # Check the exit status from the JSON file
    if [ -f "$OUTPUT_DIR/${test}.json" ]; then
        exit_status=$(grep '"exit_status":' "$OUTPUT_DIR/${test}.json" | sed 's/.*"exit_status": \([0-9]*\).*/\1/')
        if [ "$exit_status" = "0" ]; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
    fi
done

# Create summary JSON
cat > "$OUTPUT_DIR/summary.json" << EOF
{
  "test_run_id": "$(basename $OUTPUT_DIR)",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "total_tests": $total_tests,
  "passed": $passed_tests,
  "failed": $failed_tests,
  "skipped": $skipped_tests,
  "tests": [
EOF

# Add test results to summary
first=true
for test in "${tests[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_DIR/summary.json"
    fi
    cat "$OUTPUT_DIR/${test}.json" | sed 's/^/    /' | tr '\n' ' ' >> "$OUTPUT_DIR/summary.json"
done

echo -e "\n  ]\n}" >> "$OUTPUT_DIR/summary.json"

# Print summary
echo "=================================="
echo "Test execution completed!"
echo "Total tests: $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $failed_tests"
echo "Skipped: $skipped_tests"
echo "Results saved in: $OUTPUT_DIR"

# Exit with 0 to allow seeing all results
# The number of failed tests is shown in the summary
exit 0