#!/bin/bash

# Source environment variables if they exist
if [ -f "./test_env.sh" ]; then
  source ./test_env.sh
fi

# Create output directory for test results
OUTPUT_DIR="test_outputs/parallel_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Function to run a single test and save output
run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"
    
    echo "[$(date +%H:%M:%S)] Starting test: $test_name"
    
    local start_time=$(date +%s)
    go test -v -timeout 60m -run "^${test_name}$" . 2>&1 > "$log_file"
    local exit_status=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    local status="unknown"
    if grep -q "^--- PASS:" "$log_file"; then
        status="passed"
    elif grep -q "^--- FAIL:" "$log_file"; then
        status="failed"
    elif grep -q "^--- SKIP:" "$log_file"; then
        status="skipped"
    fi
    
    local error_message=""
    if [ "$status" = "failed" ]; then
        error_message=$(grep -A 5 "^--- FAIL:" "$log_file" | tail -n +2 | head -5 | tr '\n' ' ' | sed 's/"/\\"/g')
    fi
    
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
    "TestBasicMODULE_PASCAL_PLACEHOLDER"
    "TestCompleteMODULE_PASCAL_PLACEHOLDER"
    "TestSecureMODULE_PASCAL_PLACEHOLDER"
    "TestNetworkMODULE_PASCAL_PLACEHOLDER"
    "TestMODULE_PASCAL_PLACEHOLDERPrivateEndpoint"
    "TestMODULE_PASCAL_PLACEHOLDERValidationRules"
    "TestMODULE_PASCAL_PLACEHOLDERFullIntegration"
    "TestMODULE_PASCAL_PLACEHOLDERLifecycle"
    "TestMODULE_PASCAL_PLACEHOLDERCreationTime"
    "BenchmarkMODULE_PASCAL_PLACEHOLDERCreation"
)

echo "Starting parallel test execution for MODULE_NAME_PLACEHOLDER"
echo "Total tests to run: ${#tests[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

declare -a pids=()

for test in "${tests[@]}"; do
    run_test "$test" &
    pids+=($!)
done

echo "Waiting for all tests to complete..."
for pid in "${pids[@]}"; do
    wait "$pid" || true
done

echo "All tests completed. Results saved in: $OUTPUT_DIR"
exit 0
