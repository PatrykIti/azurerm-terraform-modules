#!/bin/bash

# Source environment variables if they exist
if [ -f "./test_env.sh" ]; then
  # shellcheck disable=SC1091
  source ./test_env.sh
fi

# Create output directory for test results
OUTPUT_DIR="test_outputs/sequential_run_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

run_test_case() {
    local test_name=$1
    local kind=$2
    local output_file="$OUTPUT_DIR/${test_name}.json"
    local log_file="$OUTPUT_DIR/${test_name}.log"

    echo "Running ${kind}: $test_name"

    if [ "$kind" = "benchmark" ]; then
        go test -v -timeout 60m -run=^$ -bench "^${test_name}$" -benchtime=1x . 2>&1 | tee "$log_file"
    else
        go test -v -timeout 60m -run "^${test_name}$" . 2>&1 | tee "$log_file"
    fi

    local exit_status=${PIPESTATUS[0]}

    cat > "$output_file" << EOF_JSON
{
  "test_name": "$test_name",
  "kind": "$kind",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "log_file": "$(basename "$log_file")"
}
EOF_JSON

    echo "${kind} $test_name completed with status: $exit_status"
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

echo "Starting sequential test execution for azurerm_application_insights_workbook"
echo "Total tests: ${#tests[@]}"
echo "Total benchmarks: ${#benchmarks[@]}"
echo "Output directory: $OUTPUT_DIR"
echo "=================================="

for test_name in "${tests[@]}"; do
    run_test_case "$test_name" "test" || true
done

for benchmark_name in "${benchmarks[@]}"; do
    run_test_case "$benchmark_name" "benchmark" || true
done

echo "=================================="
echo "Sequential test execution completed"
echo "Results saved in: $OUTPUT_DIR"
exit 0
