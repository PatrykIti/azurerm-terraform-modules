#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TARGET_DIR="${ROOT_DIR}/modules"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: modules directory not found at $TARGET_DIR"
  exit 1
fi

echo "Cleaning Terraform artifacts under: $TARGET_DIR"

# Remove Terraform working directories and state folders
find "$TARGET_DIR" -type d -name ".terraform" -prune -exec rm -rf {} +
find "$TARGET_DIR" -type d -name "terraform.tfstate.d" -prune -exec rm -rf {} +

# Remove Terraform lock/state/plan/log files
find "$TARGET_DIR" -type f \( \
  -name ".terraform.lock.hcl" -o \
  -name ".terraform.tfstate.lock.info" -o \
  -name "terraform.tfstate" -o \
  -name "terraform.tfstate.backup" -o \
  -name "*.tfstate" -o \
  -name "*.tfstate.backup" -o \
  -name "*.tfplan" -o \
  -name "crash.log" -o \
  -name "crash.*.log" \
  \) -exec rm -f {} +

echo "Done."
