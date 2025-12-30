# Makefile for Terratest execution
SHELL := /bin/bash

# Variables
TIMEOUT ?= 30m
TEST_FILTER ?= Test
PARALLEL ?= 8
AZURE_LOCATION ?= northeurope
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

# Install dependencies
deps:
	@echo "Installing Go dependencies..."
	go mod download
	go mod tidy

# Run all tests
test: check-env deps
	@echo "Running all tests..."
	$(call run_with_log,all,go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...)

# Run specific test
test-single: check-env deps
	@echo "Running test: $(TEST_NAME)"
	$(call run_with_log,single,go test -v -timeout $(TIMEOUT) -run $(TEST_NAME) ./...)

# Run basic tests only
test-basic: check-env deps
	@echo "Running basic tests..."
	$(call run_with_log,basic,go test -v -timeout 15m -run TestBasicStorageAccount ./...)

# Run security tests
test-security: check-env deps
	@echo "Running security tests..."
	$(call run_with_log,security,go test -v -timeout 20m -run TestStorageAccountSecurity ./...)

# Run network tests
test-network: check-env deps
	@echo "Running network tests..."
	$(call run_with_log,network,go test -v -timeout 20m -run TestStorageAccountNetworkRules ./...)

# Run private endpoint tests
test-private-endpoint: check-env deps
	@echo "Running private endpoint tests..."
	$(call run_with_log,private-endpoint,go test -v -timeout 20m -run TestStorageAccountPrivateEndpoint ./...)

# Run validation tests
test-validation: check-env deps
	@echo "Running validation tests..."
	$(call run_with_log,validation,go test -v -timeout 10m -run TestStorageAccountValidationRules ./...)

# Run benchmarks
benchmark: check-env deps
	@echo "Running benchmarks..."
	$(call run_with_log,bench,go test -v -run=^$$ -bench=. -benchtime=1x ./...)

# Run tests with coverage
test-coverage: check-env deps
	@echo "Running tests with coverage..."
	$(call run_with_log,coverage,go test -v -timeout $(TIMEOUT) -coverprofile=coverage.out -covermode=atomic ./...)
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests with race detection
test-race: check-env deps
	@echo "Running tests with race detection..."
	$(call run_with_log,race,go test -v -timeout $(TIMEOUT) -race ./...)

# Generate JUnit report
test-junit: check-env deps
	@echo "Running tests with JUnit output..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	@mkdir -p $(LOG_DIR)
	@echo "Saving test output to $(LOG_DIR)/junit_$(LOG_TIMESTAMP).log"
	@bash -c 'set -o pipefail; go test -v -timeout $(TIMEOUT) ./... 2>&1 | tee "$(LOG_DIR)/junit_$(LOG_TIMESTAMP).log" | go-junit-report -set-exit-code > test-results.xml'

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	rm -f coverage.out coverage.html test-results.xml
	rm -rf test_outputs/
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +

# Validate terraform fixtures
validate-fixtures:
	@echo "Validating Terraform fixtures..."
	@for dir in fixtures/*/; do \
		echo "Validating $$dir..."; \
		cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
	done

# Format check
fmt-check:
	@echo "Checking Go formatting..."
	@if [ -n "$$(gofmt -l .)" ]; then \
		echo "Go files are not formatted. Run 'make fmt' to fix."; \
		gofmt -l .; \
		exit 1; \
	fi

# Format code
fmt:
	@echo "Formatting Go code..."
	gofmt -w .

# Lint code
lint:
	@echo "Running linters..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	golangci-lint run ./...

# Security scan
security:
	@echo "Running security scan..."
	go install github.com/securego/gosec/v2/cmd/gosec@latest
	gosec -fmt=json -out=security-report.json ./...

# CI/CD pipeline simulation
ci: clean fmt-check lint test-coverage test-junit
	@echo "CI pipeline completed successfully!"

# Help
help:
	@echo "Available targets:"
	@echo "  make test                 - Run all tests"
	@echo "  make test-single TEST_NAME=TestName - Run specific test"
	@echo "  make test-basic          - Run basic tests only"
	@echo "  make test-security       - Run security tests"
	@echo "  make test-network        - Run network tests"
	@echo "  make test-private-endpoint - Run private endpoint tests"
	@echo "  make test-validation     - Run validation tests"
	@echo "  make benchmark           - Run benchmarks"
	@echo "  make test-coverage       - Run tests with coverage"
	@echo "  make test-race          - Run tests with race detection"
	@echo "  make test-junit         - Generate JUnit report"
	@echo "  make validate-fixtures   - Validate Terraform fixtures"
	@echo "  make clean              - Clean test artifacts"
	@echo "  make fmt                - Format Go code"
	@echo "  make lint               - Run linters"
	@echo "  make security           - Run security scan"
	@echo "  make ci                 - Run CI pipeline"

.PHONY: check-env deps test test-single test-basic test-security test-network test-private-endpoint test-validation benchmark test-coverage test-race test-junit clean validate-fixtures fmt-check fmt lint security ci help
