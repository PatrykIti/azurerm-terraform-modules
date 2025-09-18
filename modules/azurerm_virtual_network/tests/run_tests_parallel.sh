#!/bin/bash

# Source environment variables
source ./test_env.sh

# Create output directory for test results
OUTPUT_DIR="/Users/pciechanski/Documents/_moje_projekty/azurerm-terraform-modules/modules/azurerm_virtual_network/tests/test_outputs"
mkdir -p "$OUTPUT_DIR"

# Function to run a single test and save output
run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"
    
    echo "[$(date +%H:%M:%S)] Starting test: $test_name"
    
    # Run the test and capture output
    local start_time=$(date +%s)
    go test -v -timeout 30m -run "^${test_name}$" . 2>&1 > "$log_file"
    local exit_status=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Extract pass/fail/skip status from log
    local status="unknown"
    if grep -q "^--- PASS:" "$log_file"; then
        status="passed"
    elif grep -q "^--- FAIL:" "$log_file"; then
        status="failed"
    elif grep -q "^--- SKIP:" "$log_file"; then
        status="skipped"
    fi
    
    # Extract error message if failed
    local error_message=""
    if [ "$status" = "failed" ]; then
        error_message=$(grep -A 5 "^--- FAIL:" "$log_file" | tail -n +2 | head -5 | tr '\n' ' ' | sed 's/"/\\"/g')
    fi
    
    # Create JSON output
    cat > "$output_file" << EOF
{
  "test_name": "$test_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "status": "$status",
  "duration_seconds": $duration,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "error_message": "$error_message",
  "log_file": "$(basename "$log_file")"
}
EOF
    
    echo "[$(date +%H:%M:%S)] Completed test: $test_name - Status: $status (${duration}s)"
    
    return $exit_status
}

# List of tests to run
tests=(
    "TestVirtualNetworkBasic"
    "TestVirtualNetworkComplete"
    "TestVirtualNetworkSecure"
    "TestVirtualNetworkWithPeering"
    "TestVirtualNetworkPrivateEndpoint"
    "TestVirtualNetworkDNS"
    "TestVirtualNetworkValidationRules"
    "TestVirtualNetworkFullIntegration"
    "TestVirtualNetworkCreationTime"
    "TestVirtualNetworkScaling"
)

echo "Starting parallel test execution"
echo "Total tests to run: ${#tests[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

# Array to store PIDs of background jobs
declare -a pids=()

# Run all tests in parallel
for test in "${tests[@]}"; do
    run_test "$test" &
    pids+=($!)
done

# Wait for all background jobs to complete
echo "Waiting for all tests to complete..."
for pid in "${pids[@]}"; do
    wait "$pid" || true  # Don't exit on error
done

# Create summary JSON
echo "Creating summary..."

# Count results
passed_tests=0
failed_tests=0
skipped_tests=0

for test in "${tests[@]}"; do
    if [ -f "$OUTPUT_DIR/${test}.json" ]; then
        status=$(grep '"status":' "$OUTPUT_DIR/${test}.json" | sed 's/.*"status": "\(.*\)".*/\1/')
        case $status in
            passed) ((passed_tests++)) ;;
            failed) ((failed_tests++)) ;;
            skipped) ((skipped_tests++)) ;;
        esac
    fi
done

total_tests=${#tests[@]}

# Create summary JSON
cat > "$OUTPUT_DIR/summary.json" << EOF
{
  "test_run_id": "parallel_run_$(date +%Y%m%d_%H%M%S)",
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
    if [ -f "$OUTPUT_DIR/${test}.json" ]; then
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$OUTPUT_DIR/summary.json"
        fi
        cat "$OUTPUT_DIR/${test}.json" | sed 's/^/    /' | tr '\n' ' ' >> "$OUTPUT_DIR/summary.json"
    fi
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

# Always exit with 0 to see all results
# The summary will show which tests failed
exit 0