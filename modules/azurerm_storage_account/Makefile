.PHONY: all test test-short test-integration test-all docs clean validate security check help

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

# Run integration tests
test-integration:
	@echo "Running integration tests..."
	cd tests && make test

# Run full test suite
test-all:
	@echo "Running full test suite..."
	cd tests && make test

# Generate documentation
docs:
	@echo "Generating documentation..."
	./generate-docs.sh
	@echo "Documentation updated in README.md"

# Clean up artifacts
clean:
	@echo "Cleaning up artifacts..."
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

# Run validation and security checks
check: validate security

# Show help
help:
	@echo "Available targets:"
	@echo "  make all          - Run all checks and short tests"
	@echo "  make test         - Run all tests"
	@echo "  make test-short   - Run only basic functionality tests"
	@echo "  make test-all     - Run full test suite"
	@echo "  make docs         - Generate/update documentation"
	@echo "  make clean        - Clean up test artifacts"
	@echo "  make validate     - Validate Terraform configuration"
	@echo "  make security     - Run security scans"
	@echo "  make check        - Run validation and security scans"
	@echo "  make help         - Show this help message"
