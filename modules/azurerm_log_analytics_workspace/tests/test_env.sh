#!/bin/bash
# Azure credentials for testing
export AZURE_CLIENT_ID="YOUR_AZURE_CLIENT_ID_HERE"
export AZURE_CLIENT_SECRET="YOUR_AZURE_CLIENT_SECRET_HERE"
export AZURE_SUBSCRIPTION_ID="YOUR_AZURE_SUBSCRIPTION_ID_HERE"
export AZURE_TENANT_ID="YOUR_AZURE_TENANT_ID_HERE"

# ARM_ prefixed variables for Terraform provider
export ARM_CLIENT_ID="${AZURE_CLIENT_ID}"
export ARM_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_TENANT_ID}"

# Additional settings
export ARM_SKIP_PROVIDER_REGISTRATION=true
export AZURE_LOCATION="northeurope"
export RUN_LOG_ANALYTICS_CLUSTER_TESTS="false"

echo "Azure credentials set for testing"
