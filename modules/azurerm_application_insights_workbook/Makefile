.PHONY: test test-short test-basic test-complete test-secure test-validation test-integration test-performance benchmark test-all docs clean validate security check help

# Default module test entrypoint delegates to the module-local test harness
# to keep one canonical flow for local and CI usage.
test:
	$(MAKE) -C tests test

# Compatibility aliases
# test-short is kept for callers using older target names.
test-short:
	$(MAKE) -C tests test-basic

test-basic:
	$(MAKE) -C tests test-basic

test-complete:
	$(MAKE) -C tests test-complete

test-secure:
	$(MAKE) -C tests test-secure

test-validation:
	$(MAKE) -C tests test-validation

test-integration:
	$(MAKE) -C tests test-integration

test-performance:
	$(MAKE) -C tests test-performance

benchmark:
	$(MAKE) -C tests benchmark

# test-all is kept for backward compatibility.
test-all: test

# Generate documentation
docs:
	@echo "Generating documentation..."
	./generate-docs.sh

# Clean module and test artifacts
clean:
	@echo "Cleaning module and test artifacts..."
	$(MAKE) -C tests clean
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +
	@echo "Cleanup complete"

# Validate Terraform configuration
validate:
	@echo "Initializing Terraform..."
	terraform init -backend=false -input=false
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
	@echo "  make test             - Run canonical module test flow (delegates to tests/Makefile)"
	@echo "  make test-short       - Run basic tests (compatibility alias)"
	@echo "  make test-basic       - Run basic tests"
	@echo "  make test-complete    - Run complete tests"
	@echo "  make test-secure      - Run secure tests"
	@echo "  make test-validation  - Run validation tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-performance - Run performance tests"
	@echo "  make benchmark        - Run benchmarks"
	@echo "  make test-all         - Run all tests (compatibility alias)"
	@echo "  make docs             - Generate/update documentation"
	@echo "  make clean            - Clean up test and Terraform artifacts"
	@echo "  make validate         - Validate Terraform configuration"
	@echo "  make security         - Run security scans"
	@echo "  make check            - Run validation and security scans"
	@echo "  make help             - Show this help message"
