#!/bin/bash
set -e

# Script to run module-specific actions
# This is a workaround for GitHub Actions limitation where 'uses' doesn't support expressions

MODULE="$1"
ACTION="$2"
TERRAFORM_VERSION="${3:-1.10.3}"

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
      # Download TFLint directly from GitHub releases to avoid script download issues
      TFLINT_VERSION="v0.52.0"
      arch=$(uname -m)
      case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
      esac
      
      download_url="https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_${arch}.zip"
      
      # Use GitHub token if available to avoid rate limits
      if [[ -n "${GITHUB_TOKEN}" ]]; then
        curl -L -H "Authorization: token ${GITHUB_TOKEN}" -o /tmp/tflint.zip "$download_url"
      else
        curl -L -o /tmp/tflint.zip "$download_url"
      fi
      
      unzip -o /tmp/tflint.zip -d /tmp/
      sudo mv /tmp/tflint /usr/local/bin/
      rm /tmp/tflint.zip
      
      # Verify installation
      tflint --version
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
    # Export Azure credentials for Terraform provider
    if [[ -n "${AZURE_CLIENT_ID}" ]]; then
      echo "::group::Setting up Azure credentials"
      echo "Configuring Azure authentication"
      echo "ARM_CLIENT_ID is set"
      echo "ARM_TENANT_ID is set"
      echo "ARM_SUBSCRIPTION_ID is set"
      if [[ -n "${ARM_CLIENT_SECRET}" ]]; then
        echo "ARM_CLIENT_SECRET is set"
      fi
      echo "ARM_USE_OIDC=${ARM_USE_OIDC}"
      echo "::endgroup::"
    fi
    
    # Check for Go tests
    if [[ -d "tests" ]] && compgen -G "tests/*.go" > /dev/null; then
      echo "::group::Running Go Tests"
      cd tests
      
      # Setup Go if needed
      if [[ -f "go.mod" ]]; then
        go mod download
      fi
      
      # Run tests with Azure credentials
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