.PHONY: test test-unit test-integration test-all test-basic test-complete test-secure test-network test-private-endpoint test-validation test-performance test-parallel test-sequential docs clean validate

# Variables
TIMEOUT ?= 30m
PARALLEL_TESTS ?= 4

# Run native Terraform unit tests
test-unit:
	@echo "Running native Terraform tests..."
	terraform init
	terraform test

# Individual Terratest tests
test-basic:
	@echo "Running basic subnet test..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestBasicSubnet

test-complete:
	@echo "Running complete subnet test..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestCompleteSubnet

test-secure:
	@echo "Running security subnet test..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestSubnetSecurity

test-network:
	@echo "Running network rules test..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestSubnetNetworkRules

test-private-endpoint:
	@echo "Running private endpoint test..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestSubnetPrivateEndpoint

test-validation:
	@echo "Running validation tests..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestSubnetValidationRules

test-performance:
	@echo "Running performance benchmarks..."
	cd tests && go test -bench=. -benchtime=10s -run=^BenchmarkSubnetCreation$

# Run integration tests (all feature tests)
test-integration:
	@echo "Running all integration tests..."
	cd tests && go test -v -timeout $(TIMEOUT) -run TestSubnetFullIntegration

# Run tests in parallel
test-parallel:
	@echo "Running tests in parallel (max $(PARALLEL_TESTS) concurrent)..."
	cd tests && go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL_TESTS)

# Run tests sequentially
test-sequential:
	@echo "Running tests sequentially..."
	cd tests && go test -v -timeout $(TIMEOUT) -parallel 1

# Run all tests
test-all: test-unit test-basic test-complete test-secure test-network test-private-endpoint test-validation test-integration

# Default test target (unit tests only)
test: test-unit

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
	@echo "  make test           - Run short tests (default)"
	@echo "  make test-short     - Run only basic functionality tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-all       - Run all tests"
	@echo "  make docs           - Generate/update documentation"
	@echo "  make clean          - Clean up test artifacts"
	@echo "  make validate       - Validate Terraform configuration"
	@echo "  make security       - Run security scans"
	@echo "  make check          - Run validation and security scans"
	@echo "  make help           - Show this help message"