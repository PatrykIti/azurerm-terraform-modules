#!/bin/bash
# Azure DevOps credentials for testing.
# Replace placeholder values to use this file, otherwise existing env vars are preserved.

AZDO_ORG_SERVICE_URL_VALUE="https://dev.azure.com/YOUR_ORG_HERE"
AZDO_PERSONAL_ACCESS_TOKEN_VALUE="YOUR_PAT_HERE"
AZDO_PROJECT_ID_VALUE="YOUR_PROJECT_ID_HERE"

set_if_missing() {
  local var_name=$1
  local value=$2
  local placeholder=$3

  if [ -z "${!var_name}" ] && [ "$value" != "$placeholder" ]; then
    export "$var_name=$value"
  fi
}

set_if_missing "AZDO_ORG_SERVICE_URL" "$AZDO_ORG_SERVICE_URL_VALUE" "https://dev.azure.com/YOUR_ORG_HERE"
set_if_missing "AZDO_PERSONAL_ACCESS_TOKEN" "$AZDO_PERSONAL_ACCESS_TOKEN_VALUE" "YOUR_PAT_HERE"
set_if_missing "AZDO_PROJECT_ID" "$AZDO_PROJECT_ID_VALUE" "YOUR_PROJECT_ID_HERE"

missing=()
if [ -z "${AZDO_ORG_SERVICE_URL:-}" ]; then
  missing+=("AZDO_ORG_SERVICE_URL")
fi
if [ -z "${AZDO_PERSONAL_ACCESS_TOKEN:-}" ]; then
  missing+=("AZDO_PERSONAL_ACCESS_TOKEN")
fi
if [ -z "${AZDO_PROJECT_ID:-}" ]; then
  missing+=("AZDO_PROJECT_ID")
fi

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Azure DevOps credentials not set: ${missing[*]}"
  echo "Set them in the environment or update test_env.sh placeholders."
else
  echo "Azure DevOps credentials set for testing"
fi
