# Makefile for Terratest execution
SHELL := /bin/bash

# Variables
TIMEOUT ?= 45m
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

# Normalize credential environment variables (ARM_ <-> AZURE_)
ifdef AZURE_SUBSCRIPTION_ID
ARM_SUBSCRIPTION_ID ?= $(AZURE_SUBSCRIPTION_ID)
endif
ifdef AZURE_TENANT_ID
ARM_TENANT_ID ?= $(AZURE_TENANT_ID)
endif
ifdef AZURE_CLIENT_ID
ARM_CLIENT_ID ?= $(AZURE_CLIENT_ID)
endif
ifdef AZURE_CLIENT_SECRET
ARM_CLIENT_SECRET ?= $(AZURE_CLIENT_SECRET)
endif

ifdef ARM_SUBSCRIPTION_ID
AZURE_SUBSCRIPTION_ID ?= $(ARM_SUBSCRIPTION_ID)
endif
ifdef ARM_TENANT_ID
AZURE_TENANT_ID ?= $(ARM_TENANT_ID)
endif
ifdef ARM_CLIENT_ID
AZURE_CLIENT_ID ?= $(ARM_CLIENT_ID)
endif
ifdef ARM_CLIENT_SECRET
AZURE_CLIENT_SECRET ?= $(ARM_CLIENT_SECRET)
endif

export ARM_SUBSCRIPTION_ID ARM_TENANT_ID ARM_CLIENT_ID ARM_CLIENT_SECRET
export AZURE_SUBSCRIPTION_ID AZURE_TENANT_ID AZURE_CLIENT_ID AZURE_CLIENT_SECRET

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
	$(call run_with_log,basic,go test -v -timeout 30m -run TestBasicRouteTable ./...)

# Run complete tests
test-complete: check-env deps
	@echo "Running complete tests..."
	$(call run_with_log,complete,go test -v -timeout 45m -run TestCompleteRouteTable ./...)

# Run security tests
test-secure: check-env deps
	@echo "Running security tests..."
	$(call run_with_log,secure,go test -v -timeout 45m -run TestSecureRouteTable ./...)

# Run network tests
test-network: check-env deps
	@echo "Running network tests..."
	$(call run_with_log,network,go test -v -timeout 45m -run TestNetworkRouteTable ./...)

# Run validation tests
test-validation: check-env deps
	@echo "Running validation tests..."
	$(call run_with_log,validation,go test -v -timeout 15m -run TestRouteTableValidationRules ./...)

# Run integration tests (long-running)
test-integration: check-env deps
	@echo "Running integration tests..."
	$(call run_with_log,integration,go test -v -timeout 60m -run "TestRouteTableLifecycle|TestRouteTableMultipleUpdates|TestRouteTableWithSubnetAssociation" ./...)

# Run performance tests
test-performance: check-env deps
	@echo "Running performance tests..."
	$(call run_with_log,performance,go test -v -timeout 30m -run TestRouteTableCreationTime ./...)

# Run benchmarks
benchmark: check-env deps
	@echo "Running benchmarks..."
	$(call run_with_log,bench,go test -v -run=^$ -bench=. -benchtime=1x ./...)

# Run tests with coverage
test-coverage: check-env deps
	@echo "Running tests with coverage..."
	$(call run_with_log,coverage,go test -v -timeout $(TIMEOUT) -coverprofile=coverage.out -covermode=atomic ./...)
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Generate JUnit report for CI/CD
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

# Format and lint
fmt:
	@echo "Formatting Go code..."
	gofmt -w .

lint:
	@echo "Running linters..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	golangci-lint run ./...

# CI pipeline simulation
ci: clean fmt lint test-coverage test-junit
	@echo "CI pipeline completed successfully!"

.PHONY: check-env deps test test-single test-basic test-complete test-secure test-network test-validation test-integration test-performance benchmark test-coverage test-junit clean fmt lint ci
