# 7. Automation and Helper Scripts

To ensure consistency and reduce manual effort, each module MUST include a `Makefile` and a `generate-docs.sh` script for automating common development tasks.

## `Makefile`

A `Makefile` at the root of the module provides a standard interface for common operations like testing, validation, and documentation generation. This allows developers to use consistent commands across all modules.

**Key Targets:**
- `test` or `test-all`: Runs the full suite of tests (unit and integration).
- `test-short`: Runs a quick subset of tests, typically the basic Terratest example and native unit tests.
- `validate`: Initializes Terraform, validates the configuration (`terraform validate`), and checks formatting (`terraform fmt -check`).
- `docs`: Generates or updates the `README.md` by running `terraform-docs`.
- `security`: Runs security scanning tools like `tfsec` and `checkov`.
- `check`: A convenience target that runs `validate` and `security`.
- `clean`: Removes temporary files and test artifacts.
- `help`: Displays a list of available targets and their descriptions.

**Template (`Makefile`):**
```makefile
.PHONY: test test-short docs clean validate security check help

# Default target
all: check test-short

# Run all tests
test:
	@echo "Running all tests..."
	cd tests && make test

# Run only short/basic tests
test-short:
	@echo "Running short tests..."
	cd tests && make test-basic

# Generate documentation
docs:
	@echo "Generating documentation..."
	./generate-docs.sh
	@echo "Documentation updated in README.md"

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	cd tests && make clean

# Validate Terraform configuration
validate:
	@echo "Initializing Terraform..."
	terraform init -backend=false
	@echo "Validating Terraform configuration..."
	terraform validate
	@echo "Formatting check..."
	terraform fmt -check -recursive
	@echo "Validation complete"

# Run security scanning
security:
	@echo "Running security scan with tfsec..."
	tfsec . --minimum-severity HIGH
	@echo "Running checkov scan..."
	checkov -d . --framework terraform --quiet
	@echo "Security scanning complete"

# Run all checks (validate + security)
check: validate security

# Show help
help:
	@echo "Available targets:"
	@echo "  make all          - Run all checks and short tests"
	@echo "  make test         - Run all tests"
	@echo "  make test-short   - Run only basic functionality tests"
	@echo "  make docs         - Generate/update documentation"
	@echo "  make clean        - Clean up test artifacts"
	@echo "  make validate     - Validate Terraform configuration"
	@echo "  make security     - Run security scans"
	@echo "  make check        - Run validation and security scans"
	@echo "  make help         - Show this help message"
```

---

## `generate-docs.sh`

This shell script is a simple wrapper around the `terraform-docs` command. It ensures that documentation is generated with the correct configuration and provides a single, consistent command for both local use and CI/CD pipelines.

**Key Responsibilities:**
- Verify that `terraform-docs` is installed.
- (Optional) Run any pre-generation scripts, such as one to dynamically update the examples list in the `.terraform-docs.yml` file.
- Execute `terraform-docs` with the correct arguments to inject content into the `README.md`.

**Template (`generate-docs.sh`):**
```bash
#!/bin/bash

# This script generates README.md using terraform-docs for the current module.

set -e

# Get the directory of the script to find the module root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Generating documentation for the module in $SCRIPT_DIR..."

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "Error: terraform-docs is not installed. Please install it first."
    echo "Visit: https://terraform-docs.io/user-guide/installation/"
    exit 1
fi

# (Optional) Logic to update .terraform-docs.yml with the current list of examples
# if [[ -x "../../scripts/update-examples-list.sh" ]]; then
#     echo "Updating examples list in .terraform-docs.yml..."
#     "../../scripts/update-examples-list.sh" "$SCRIPT_DIR"
# fi

# Generate documentation
echo "Running terraform-docs..."
terraform-docs markdown table --output-file README.md --output-mode inject "$SCRIPT_DIR"

echo "✅ Documentation generated successfully!"
```
