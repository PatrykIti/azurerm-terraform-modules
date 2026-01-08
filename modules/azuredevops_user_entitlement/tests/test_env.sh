#!/bin/bash
# Azure DevOps credentials for testing (set real values before running integration tests)
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"
export AZDO_USER_PRINCIPAL_NAME="user@example.com"
export AZDO_USER_ORIGIN_ID="00000000-0000-0000-0000-000000000000"
export AZDO_USER_ORIGIN="aad"

# Optional per-fixture overrides
# export AZDO_USER_PRINCIPAL_NAME_BASIC="basic.user@example.com"
# export AZDO_USER_PRINCIPAL_NAME_SECURE="secure.user@example.com"
# export AZDO_USER_ORIGIN_ID_COMPLETE="11111111-1111-1111-1111-111111111111"
# export AZDO_USER_ORIGIN_COMPLETE="aad"
# export AZDO_USER_PRINCIPAL_NAME_NEGATIVE="negative.user@example.com"
# export AZDO_USER_ORIGIN_ID_NEGATIVE="22222222-2222-2222-2222-222222222222"
# export AZDO_USER_ORIGIN_NEGATIVE="aad"

echo "Azure DevOps credentials set for testing (placeholders)."
