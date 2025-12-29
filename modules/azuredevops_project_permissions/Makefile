.PHONY: test test-short test-integration test-all docs clean validate

# Run only short tests (basic functionality)
test-short:
	$(MAKE) -C tests test-short

# Run only integration tests
test-integration:
	$(MAKE) -C tests test-integration

# Run all tests
test-all:
	$(MAKE) -C tests test

# Default test target
test: test-all

# Generate documentation
docs:
	@echo "Generating documentation..."
	terraform-docs markdown table --output-file README.md --output-mode inject .
	@echo "Documentation updated in README.md"

# Clean up test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +
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
	@echo "  make test           - Run all tests (default)"
	@echo "  make test-short     - Run only basic functionality tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-all       - Run all tests"
	@echo "  make docs           - Generate/update documentation"
	@echo "  make clean          - Clean up test artifacts"
	@echo "  make validate       - Validate Terraform configuration"
	@echo "  make security       - Run security scans"
	@echo "  make check          - Run validation and security scans"
	@echo "  make help           - Show this help message"
