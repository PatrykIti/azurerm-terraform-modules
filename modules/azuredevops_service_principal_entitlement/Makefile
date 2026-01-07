.PHONY: test docs clean validate security check help

TESTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/tests)

test:
	@echo "Running terraform unit tests..."
	terraform test -test-directory="$(TESTS_DIR)/unit"

docs:
	@echo "Generating documentation..."
	./generate-docs.sh
	@echo "Documentation updated in README.md"

clean:
	@echo "Cleaning up test artifacts..."
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +
	@echo "Cleanup complete"

validate:
	@echo "Initializing Terraform..."
	terraform init -backend=false
	@echo "Validating Terraform configuration..."
	terraform validate
	@echo "Formatting check..."
	terraform fmt -check -recursive
	@echo "Validation complete"

security:
	@echo "Running security scan with tfsec..."
	tfsec . --minimum-severity HIGH
	@echo "Running checkov scan..."
	checkov -d . --framework terraform --quiet
	@echo "Security scanning complete"

check: validate security

help:
	@echo "Available targets:"
	@echo "  make test           - Run terraform unit tests"
	@echo "  make docs           - Generate/update documentation"
	@echo "  make clean          - Clean up test artifacts"
	@echo "  make validate       - Validate Terraform configuration"
	@echo "  make security       - Run security scans"
	@echo "  make check          - Run validation and security scans"
	@echo "  make help           - Show this help message"
