#!/bin/bash
# Azure DevOps credentials for testing
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"

# Inputs required by azuredevops_elastic_pool tests
export AZDO_TEST_SERVICE_ENDPOINT_ID="00000000-0000-0000-0000-000000000001"
export AZDO_TEST_SERVICE_ENDPOINT_SCOPE="00000000-0000-0000-0000-000000000000"
export AZDO_TEST_AZURE_RESOURCE_ID="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/virtualMachineScaleSets/vmss"

echo "Azure DevOps credentials and elastic pool test inputs are set"
