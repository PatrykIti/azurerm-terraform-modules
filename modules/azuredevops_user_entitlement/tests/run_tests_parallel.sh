#!/bin/bash
set -euo pipefail

if [ -f "./test_env.sh" ]; then
  source ./test_env.sh
fi

echo "Running terraform unit tests (parallel default)..."
terraform test -test-directory=./unit
