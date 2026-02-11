#!/bin/bash

# Source environment variables if they exist
if [ -f "./test_env.sh" ]; then
  # shellcheck disable=SC1091
  source ./test_env.sh
fi

# Create output directory for test results
OUTPUT_DIR="test_outputs/parallel_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

run_test_case() {
    local test_name=$1
    local kind=$2
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"

    echo "[$(date +%H:%M:%S)] Starting ${kind}: $test_name"

    local start_time
    start_time=$(date +%s)

    if [ "$kind" = "benchmark" ]; then
        go test -v -timeout 60m -run=^$ -bench "^${test_name}$" -benchtime=1x . 2>&1 | tee "$log_file"
    else
        go test -v -timeout 60m -run "^${test_name}$" . 2>&1 | tee "$log_file"
    fi

    local exit_status=${PIPESTATUS[0]}
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    local status="failed"
    if [ "$exit_status" -eq 0 ]; then
        status="passed"
    fi

    cat > "$output_file" << EOF_JSON
{
  "test_name": "$test_name",
  "kind": "$kind",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "status": "$status",
  "duration_seconds": $duration,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "log_file": "$(basename "$log_file")"
}
EOF_JSON

    echo "[$(date +%H:%M:%S)] Completed ${kind}: $test_name - Status: $status (${duration}s)"
    return $exit_status
}

# Tests and benchmarks are executed in separate phases.
tests=(
    "TestBasicApplicationInsightsWorkbook"
    "TestCompleteApplicationInsightsWorkbook"
    "TestSecureApplicationInsightsWorkbook"
    "TestWorkbookIdentityFixture"
    "TestApplicationInsightsWorkbookValidationRules"
    "TestApplicationInsightsWorkbookFullIntegration"
    "TestApplicationInsightsWorkbookLifecycle"
    "TestApplicationInsightsWorkbookCreationTime"
)

benchmarks=(
    "BenchmarkApplicationInsightsWorkbookCreationSimple"
    "BenchmarkApplicationInsightsWorkbookParallelCreation"
)

echo "Starting parallel test execution for azurerm_application_insights_workbook"
echo "Total tests: ${#tests[@]}"
echo "Total benchmarks: ${#benchmarks[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

declare -a pids=()

for test_name in "${tests[@]}"; do
    run_test_case "$test_name" "test" &
    pids+=($!)
done

echo "Waiting for parallel tests to complete..."
for pid in "${pids[@]}"; do
    wait "$pid" || true
done

echo "Running benchmarks sequentially..."
for benchmark_name in "${benchmarks[@]}"; do
    run_test_case "$benchmark_name" "benchmark" || true
done

echo "All test phases completed. Results saved in: $OUTPUT_DIR"
exit 0
