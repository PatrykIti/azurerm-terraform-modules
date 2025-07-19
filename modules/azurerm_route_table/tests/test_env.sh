#!/bin/bash
# This script sets environment variables required for running Terratest against Azure.
# It is sourced by the main test execution scripts.

# To run tests, you must provide credentials for an Azure Service Principal.
# It is recommended to set these in your CI/CD environment or a local .env file.
#
# Example:
# export AZURE_SUBSCRIPTION_ID="your-subscription-id"
# export AZURE_TENANT_ID="your-tenant-id"
# export AZURE_CLIENT_ID="your-client-id"
# export AZURE_CLIENT_SECRET="your-client-secret"

# Check for required environment variables
if [ -z "$AZURE_SUBSCRIPTION_ID" ] || [ -z "$AZURE_TENANT_ID" ] || [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_CLIENT_SECRET" ]; then
    echo "Warning: One or more required Azure environment variables are not set."
    echo "Please set: AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET"
fi

echo "Test environment script loaded."