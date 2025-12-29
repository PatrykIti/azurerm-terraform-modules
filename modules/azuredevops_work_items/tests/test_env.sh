#!/bin/bash
# Azure DevOps credentials for testing (only set placeholders if missing).
if [ -z "$AZDO_ORG_SERVICE_URL" ]; then
  export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
fi
if [ -z "$AZDO_PERSONAL_ACCESS_TOKEN" ]; then
  export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"
fi
if [ -z "$AZDO_PROJECT_ID" ]; then
  export AZDO_PROJECT_ID="YOUR_PROJECT_ID_HERE"
fi

echo "Azure DevOps credentials set for testing"
