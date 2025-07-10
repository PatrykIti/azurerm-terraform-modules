#!/bin/bash
set -e

# Script to run module-specific actions
# This is a workaround for GitHub Actions limitation where 'uses' doesn't support expressions

MODULE="$1"
ACTION="$2"
TERRAFORM_VERSION="${3:-1.10.3}"

# Check if module action exists
ACTION_PATH="modules/${MODULE}/.github/actions/${ACTION}/action.yml"
if [[ ! -f "$ACTION_PATH" ]]; then
  echo "::warning::No ${ACTION} action found for module ${MODULE}"
  echo "Module-specific action not implemented yet. Skipping..."
  exit 0
fi

echo "Found action: $ACTION_PATH"
echo "Executing ${ACTION} action for module ${MODULE}..."

# Change to module directory
cd "modules/${MODULE}"

# Execute based on action type
case "$ACTION" in
  validate)
    # Terraform Format Check
    echo "::group::Terraform Format Check"
    terraform fmt -check -recursive
    echo "::endgroup::"
    
    # Terraform Init
    echo "::group::Terraform Init"
    terraform init -backend=false
    echo "::endgroup::"
    
    # Terraform Validate
    echo "::group::Terraform Validate"
    terraform validate
    echo "::endgroup::"
    
    # Install TFLint if needed
    if ! command -v tflint &> /dev/null; then
      echo "::group::Install TFLint"
      curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
      echo "::endgroup::"
    fi
    
    # TFLint
    echo "::group::TFLint"
    tflint --init
    tflint
    echo "::endgroup::"
    
    # Validate Examples
    echo "::group::Validate Examples"
    cd "${GITHUB_WORKSPACE}"
    for example in ./modules/${MODULE}/examples/*/; do
      if [[ -d "$example" && -f "$example/main.tf" ]]; then
        echo "Validating example: $example"
        cd "$example"
        terraform init -backend=false
        terraform validate
        cd - > /dev/null
      fi
    done
    echo "::endgroup::"
    ;;
    
  test)
    # Check for Go tests
    if [[ -d "tests" ]] && ls tests/*.go &> /dev/null 2>&1; then
      echo "::group::Running Go Tests"
      cd tests
      
      # Setup Go if needed
      if [[ -f "go.mod" ]]; then
        go mod download
      fi
      
      # Run tests
      go test -v -timeout 30m
      echo "::endgroup::"
    else
      echo "::warning::No tests found for module ${MODULE}"
    fi
    ;;
    
  security)
    # Run tfsec
    echo "::group::Running tfsec"
    docker run --rm -v "$(pwd):/src" aquasec/tfsec /src \
      --format sarif \
      --out /src/tfsec-results.sarif \
      --soft-fail || true
    
    # Set output for SARIF upload
    if [[ -f "tfsec-results.sarif" ]]; then
      echo "tfsec-sarif=modules/${MODULE}/tfsec-results.sarif" >> $GITHUB_OUTPUT
    fi
    echo "::endgroup::"
    
    # Run checkov
    echo "::group::Running Checkov"
    docker run --rm -v "$(pwd):/tf" bridgecrew/checkov \
      -d /tf \
      --framework terraform \
      --output sarif \
      --output-file-path /tf/checkov-results.sarif \
      --soft-fail || true
    
    # Set output for SARIF upload
    if [[ -f "checkov-results.sarif" ]]; then
      echo "checkov-sarif=modules/${MODULE}/checkov-results.sarif" >> $GITHUB_OUTPUT
    fi
    echo "::endgroup::"
    ;;
    
  *)
    echo "::error::Unknown action: ${ACTION}"
    exit 1
    ;;
esac

echo "✅ ${ACTION} completed successfully for module ${MODULE}"