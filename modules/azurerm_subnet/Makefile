.PHONY: all test test-short test-unit test-all test-basic test-complete test-secure test-network test-private-endpoint test-validation test-performance test-parallel test-sequential test-integration docs clean validate security check help

# Default target
all: check test-short

# Run all tests (unit + integration)
test: test-unit
	@echo "Running all Terratest suites..."
	cd tests && make test

test-all: test

# Run only short/basic tests
test-short: test-unit
	@echo "Running short Terratest suites..."
	cd tests && make test-basic

# Run native Terraform unit tests
test-unit:
	@echo "Running native Terraform tests..."
	terraform test -test-directory=tests/unit

# Convenience wrappers for Terratest targets
test-basic:
	cd tests && make test-basic

test-complete:
	cd tests && make test-complete

test-secure:
	cd tests && make test-secure

test-network:
	cd tests && make test-network

test-private-endpoint:
	cd tests && make test-private-endpoint

test-validation:
	cd tests && make test-validation

test-performance:
	cd tests && make test-performance

test-parallel:
	cd tests && make test-parallel

test-sequential:
	cd tests && make test-sequential

test-integration:
	cd tests && make test-integration

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
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +
	cd tests && make clean
	@echo "Cleanup complete"

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
	@echo "  make all                - Run checks and short tests"
	@echo "  make test               - Run all tests"
	@echo "  make test-short         - Run only short/basic tests"
	@echo "  make test-unit          - Run Terraform unit tests"
	@echo "  make docs               - Generate/update documentation"
	@echo "  make clean              - Clean up test artifacts"
	@echo "  make validate           - Validate Terraform configuration"
	@echo "  make security           - Run security scans"
	@echo "  make check              - Run validation and security scans"
	@echo "  make help               - Show this help message"
