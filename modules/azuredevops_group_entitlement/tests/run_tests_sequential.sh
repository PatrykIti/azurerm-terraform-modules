#!/bin/bash

if [ -f "./test_env.sh" ]; then
  source ./test_env.sh
fi

OUTPUT_DIR="test_outputs/sequential_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

run_test() {
    local test_name=$1
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"

    echo "[$(date +%H:%M:%S)] Starting test: $test_name"

    local start_time=$(date +%s)
    go test -v -timeout 60m -run "^${test_name}$" . > "$log_file" 2>&1
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

    cat > "$output_file" << EOF_JSON
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
EOF_JSON

    echo "[$(date +%H:%M:%S)] Completed test: $test_name - Status: $status (${duration}s)"
    return $exit_status
}

tests=(
    "TestBasicAzuredevopsGroupEntitlement"
    "TestCompleteAzuredevopsGroupEntitlement"
    "TestSecureAzuredevopsGroupEntitlement"
    "TestAzuredevopsGroupEntitlementValidationRules"
    "TestAzuredevopsGroupEntitlementFullIntegration"
)

echo "Starting sequential test execution for azuredevops_group_entitlement"
echo "Total tests to run: ${#tests[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

for test in "${tests[@]}"; do
    run_test "$test" || true
    echo "----------------------------------"
done

echo "All tests completed. Results saved in: $OUTPUT_DIR"
exit 0
