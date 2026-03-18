#!/bin/bash
# Azure DevOps credentials for testing (set real values before running integration tests)
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"

# Group selector values used by fixtures
export AZDO_GROUP_DISPLAY_NAME="ADO Platform Team"
export AZDO_GROUP_ORIGIN="aad"
export AZDO_GROUP_ORIGIN_ID="00000000-0000-0000-0000-000000000000"

# Optional per-fixture overrides
# export AZDO_GROUP_DISPLAY_NAME_BASIC="ADO Platform Team"
# export AZDO_GROUP_DISPLAY_NAME_SECURE="ADO Security Reviewers"
# export AZDO_GROUP_ORIGIN_ID_COMPLETE="11111111-1111-1111-1111-111111111111"
# export AZDO_GROUP_ORIGIN_COMPLETE="aad"

echo "Azure DevOps credentials set for testing (placeholders)."
