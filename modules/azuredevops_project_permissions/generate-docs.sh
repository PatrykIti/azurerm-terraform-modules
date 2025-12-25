#!/usr/bin/env bash
set -euo pipefail

# Generate documentation for azuredevops_project_permissions module
MODULE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "${MODULE_DIR}"

echo "Generating documentation for azuredevops_project_permissions module..."
terraform-docs -c .terraform-docs.yml .
