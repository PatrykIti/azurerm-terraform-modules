#!/bin/bash
# Azure DevOps credentials for testing
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/YOUR_ORG_HERE"
export AZDO_PERSONAL_ACCESS_TOKEN="YOUR_PAT_HERE"

# Marketplace extension identifiers
export AZDO_EXTENSION_PUBLISHER_ID="YOUR_PUBLISHER_ID_HERE"
export AZDO_EXTENSION_ID="YOUR_EXTENSION_ID_HERE"
# Optional version pins
# export AZDO_EXTENSION_VERSION="1.2.3"
# export AZDO_EXTENSION_PUBLISHER_ID_2="YOUR_PUBLISHER_ID_2"
# export AZDO_EXTENSION_ID_2="YOUR_EXTENSION_ID_2"
# export AZDO_EXTENSION_VERSION_2="2.0.0"

echo "Azure DevOps credentials set for testing"
