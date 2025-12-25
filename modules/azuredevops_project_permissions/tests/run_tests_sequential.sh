#!/usr/bin/env bash
set -euo pipefail

MODULE_NAME="azuredevops_project_permissions"

echo "Starting sequential test execution for ${MODULE_NAME}"

cd "$(dirname "$0")"

# Load environment variables if available
if [ -f "./test_env.sh" ]; then
  source "./test_env.sh"
fi

# Ensure required environment variables are set
if [[ -z "${AZDO_ORG_SERVICE_URL:-}" || -z "${AZDO_PERSONAL_ACCESS_TOKEN:-}" || -z "${AZDO_PROJECT_ID:-}" ]]; then
  echo "Missing required environment variables: AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN, AZDO_PROJECT_ID"
  exit 1
fi

# Run tests sequentially

go test -v -run TestBasicAzuredevopsProjectPermissions -timeout 30m

go test -v -run TestCompleteAzuredevopsProjectPermissions -timeout 30m

go test -v -run TestSecureAzuredevopsProjectPermissions -timeout 30m

go test -v -run TestAzuredevopsProjectPermissionsValidationRules -timeout 15m

go test -v -run TestAzuredevopsProjectPermissionsFullIntegration -timeout 60m

echo "Sequential test execution complete"
