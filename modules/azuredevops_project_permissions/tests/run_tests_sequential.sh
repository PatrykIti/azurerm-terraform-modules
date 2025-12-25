#!/bin/bash

# Source environment variables if they exist
if [ -f "./test_env.sh" ]; then
  source ./test_env.sh
fi

# Ensure required environment variables are set
if [[ -z "${AZDO_ORG_SERVICE_URL:-}" || -z "${AZDO_PERSONAL_ACCESS_TOKEN:-}" || -z "${AZDO_PROJECT_ID:-}" ]]; then
  echo "Missing required environment variables: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN, AZDO_PROJECT_ID"
  exit 1
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

    cat > "$output_file" << EOF_JSON
{
  "test_name": "$test_name",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_status": $exit_status,
  "success": $([ $exit_status -eq 0 ] && echo "true" || echo "false"),
  "log_file": "$(basename "$log_file")"
}
EOF_JSON

    echo "Test $test_name completed with status: $exit_status"
    return $exit_status
}

# List of tests to run
tests=(
    "TestBasicAzuredevopsProjectPermissions"
    "TestCompleteAzuredevopsProjectPermissions"
    "TestSecureAzuredevopsProjectPermissions"
    "TestAzuredevopsProjectPermissionsValidationRules"
    "TestAzuredevopsProjectPermissionsFullIntegration"
)

echo "Starting sequential test execution for azuredevops_project_permissions"
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
