#!/bin/bash
# Azure DevOps credentials for testing (set real values before running integration tests)
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"

# Service principal object IDs for each fixture
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_BASIC="<sp-object-id-basic>"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_COMPLETE="<sp-object-id-complete>"
export AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_SECURE="<sp-object-id-secure>"

echo "Azure DevOps credentials set for testing (placeholders)."
