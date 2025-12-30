# Makefile for Terratest execution, aligned with project standards.
SHELL := /bin/bash

# Variables
TIMEOUT ?= 30m
PARALLEL ?= 8
TEST_NAME ?= ""
LOG_DIR ?= test_outputs
LOG_TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

define run_with_log
	@mkdir -p $(LOG_DIR)
	@echo "Saving test output to $(LOG_DIR)/$(1)_$(LOG_TIMESTAMP).log"
	@bash -c 'set -o pipefail; $(2) 2>&1 | tee "$(LOG_DIR)/$(1)_$(LOG_TIMESTAMP).log"'
endef

# Environment check
check-env:
	@echo "Checking required environment variables..."
	@test -n "$(ARM_SUBSCRIPTION_ID)" || test -n "$(AZURE_SUBSCRIPTION_ID)" || (echo "ARM_SUBSCRIPTION_ID or AZURE_SUBSCRIPTION_ID is not set" && exit 1)
	@test -n "$(ARM_TENANT_ID)" || test -n "$(AZURE_TENANT_ID)" || (echo "ARM_TENANT_ID or AZURE_TENANT_ID is not set" && exit 1)
	@test -n "$(ARM_CLIENT_ID)" || test -n "$(AZURE_CLIENT_ID)" || (echo "ARM_CLIENT_ID or AZURE_CLIENT_ID is not set" && exit 1)
	@test -n "$(ARM_CLIENT_SECRET)" || test -n "$(AZURE_CLIENT_SECRET)" || (echo "ARM_CLIENT_SECRET or AZURE_CLIENT_SECRET is not set" && exit 1)
	@echo "All required environment variables are set."

# Default target
all: test

# Install dependencies
deps:
	@echo "Installing Go dependencies..."
	go mod download
	go mod tidy

# Run all Go tests in parallel. This is the default command for a full test run.
test: check-env deps
	@echo "Running all Go tests..."
	$(call run_with_log,all,go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...)

# Run a single, specific test function. Useful for debugging.
# Example: make test-single TEST_NAME=TestSimpleNetworkSecurityGroup
test-single: check-env deps
	@echo "Running single test: $(TEST_NAME)..."
	$(call run_with_log,single,go test -v -timeout $(TIMEOUT) -run "^$(TEST_NAME)$$" ./...)

# Run unit tests only (skip integration tests)
test-unit: check-env deps
	@echo "Running unit tests only..."
	$(call run_with_log,unit,go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) -short ./...)

# Run integration tests only
test-integration: check-env deps
	@echo "Running integration tests only..."
	$(call run_with_log,integration,go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) -run "TestNetworkSecurityGroupLifecycle|TestSecureNetworkSecurityGroup" ./...)

# Run test for simple fixture
test-simple: check-env deps
	@echo "Running test for simple fixture..."
	$(call run_with_log,simple,go test -v -timeout $(TIMEOUT) -run TestSimpleNetworkSecurityGroup ./...)

# Run test for complete fixture
test-complete: check-env deps
	@echo "Running test for complete fixture..."
	$(call run_with_log,complete,go test -v -timeout $(TIMEOUT) -run TestCompleteNetworkSecurityGroup ./...)

# Run test for security fixture
test-security: check-env deps
	@echo "Running test for security fixture..."
	$(call run_with_log,security,go test -v -timeout $(TIMEOUT) -run TestSecureNetworkSecurityGroup ./...)

# Run test for network fixture
test-network: check-env deps
	@echo "Running test for network fixture..."
	$(call run_with_log,network,go test -v -timeout $(TIMEOUT) -run TestNetworkNetworkSecurityGroup ./...)

# Run test for negative fixture
test-negative: check-env deps
	@echo "Running test for negative fixture..."
	$(call run_with_log,negative,go test -v -timeout $(TIMEOUT) -run TestNetworkSecurityGroupValidationRules ./...)

# Run all performance benchmarks.
benchmark: check-env deps
	@echo "Running performance benchmarks..."
	$(call run_with_log,bench,go test -run=^$ -bench=.)

# Run tests and generate an HTML code coverage report.
test-coverage: check-env deps
	@echo "Running tests with coverage..."
	$(call run_with_log,coverage,go test -v -coverprofile=coverage.out -covermode=atomic ./...)
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests and generate a JUnit XML report for CI/CD integration.
test-junit: check-env deps
	@echo "Running tests and generating JUnit report..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	@mkdir -p $(LOG_DIR)
	@echo "Saving test output to $(LOG_DIR)/junit_$(LOG_TIMESTAMP).log"
	@bash -c 'set -o pipefail; go test -v ./... 2>&1 | tee "$(LOG_DIR)/junit_$(LOG_TIMESTAMP).log" | go-junit-report -set-exit-code > test-results.xml'
	@echo "JUnit report generated: test-results.xml"

# Format all Go code using gofmt.
fmt:
	@echo "Formatting Go code..."
	gofmt -w .

# Run the golangci-lint linter to check for code style issues.
lint:
	@echo "Running linter..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	golangci-lint run ./...

# Delete all test artifacts.
clean:
	@echo "Cleaning test artifacts..."
	rm -f coverage.out coverage.html test-results.xml
	rm -rf test_outputs/
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	find . -type f -name "*.tfstate*" -delete
	find . -type f -name ".terraform.lock.hcl" -delete

# A comprehensive target that simulates the CI/CD pipeline.
ci: fmt lint test-coverage test-junit

# Help target to display available commands.
help:
	@echo "Available targets:"
	@echo "  make test              - Run all Go tests."
	@echo "  make test-unit         - Run unit tests only (skip integration tests)."
	@echo "  make test-integration  - Run integration tests only (TestNetworkSecurityGroupLifecycle, TestSecureNetworkSecurityGroup)."
	@echo "  make test-single       - Run a single test. Usage: make test-single TEST_NAME=TestSimpleNetworkSecurityGroup"
	@echo ""
	@echo "Fixture-specific tests:"
	@echo "  make test-simple       - Run test for simple fixture (TestSimpleNetworkSecurityGroup)."
	@echo "  make test-complete     - Run test for complete fixture (TestCompleteNetworkSecurityGroup)."
	@echo "  make test-security     - Run test for security fixture (TestSecureNetworkSecurityGroup)."
	@echo "  make test-network      - Run test for network fixture (TestNetworkNetworkSecurityGroup)."
	@echo "  make test-negative     - Run test for negative fixture (TestNetworkSecurityGroupValidationRules)."
	@echo ""
	@echo "Other targets:"
	@echo "  make benchmark         - Run all performance benchmarks."
	@echo "  make test-coverage     - Generate an HTML code coverage report."
	@echo "  make test-junit        - Generate a JUnit XML report for CI/CD."
	@echo "  make fmt               - Format Go source code."
	@echo "  make lint              - Run the Go linter."
	@echo "  make clean             - Remove all test artifacts."
	@echo "  make ci                - Run a full CI pipeline simulation (fmt, lint, coverage, junit)."
	@echo "  make help              - Show this help message."

.PHONY: all check-env deps test test-unit test-integration test-single test-simple test-complete test-security test-network test-negative benchmark test-coverage test-junit fmt lint clean ci help
