#!/bin/bash
# Azure DevOps credentials for testing (set real values before running integration tests)
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"
export AZDO_USER_PRINCIPAL_NAME="user@example.com"
export AZDO_USER_ORIGIN_ID="00000000-0000-0000-0000-000000000000"
export AZDO_USER_ORIGIN="aad"

echo "Azure DevOps credentials set for testing (placeholders)."
