# Makefile for Terratest execution
SHELL := /bin/bash

# Variables
TIMEOUT ?= 90m
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
	$(call run_with_log,basic,go test -v -timeout 15m -run TestBasicLogAnalyticsWorkspace ./...)

# Run complete tests
test-complete: check-env deps
	@echo "Running complete tests..."
	$(call run_with_log,complete,go test -v -timeout 30m -run TestCompleteLogAnalyticsWorkspace ./...)

# Run security tests
test-secure: check-env deps
	@echo "Running security tests..."
	$(call run_with_log,secure,go test -v -timeout 30m -run TestSecureLogAnalyticsWorkspace ./...)

# Run solutions tests
test-solutions: check-env deps
	@echo "Running solutions tests..."
	$(call run_with_log,solutions,go test -v -timeout 20m -run TestLogAnalyticsSolutions ./...)

# Run data export rules tests
test-data-export: check-env deps
	@echo "Running data export rules tests..."
	$(call run_with_log,data-export,go test -v -timeout 20m -run TestLogAnalyticsDataExportRules ./...)

# Run Windows event datasource tests
test-windows-event: check-env deps
	@echo "Running Windows event datasource tests..."
	$(call run_with_log,windows-event,go test -v -timeout 20m -run TestLogAnalyticsWindowsEventDatasource ./...)

# Run Windows performance counter tests
test-windows-performance: check-env deps
	@echo "Running Windows performance counter tests..."
	$(call run_with_log,windows-performance,go test -v -timeout 20m -run TestLogAnalyticsWindowsPerformanceCounters ./...)

# Run storage insights tests
test-storage-insights: check-env deps
	@echo "Running storage insights tests..."
	$(call run_with_log,storage-insights,go test -v -timeout 20m -run TestLogAnalyticsStorageInsights ./...)

# Run linked services tests
test-linked-services: check-env deps
	@echo "Running linked services tests..."
	$(call run_with_log,linked-services,go test -v -timeout 20m -run TestLogAnalyticsLinkedServices ./...)

# Run clusters tests
test-clusters: check-env deps
	@echo "Running clusters tests..."
	$(call run_with_log,clusters,go test -v -timeout 30m -run TestLogAnalyticsClusters ./...)

# Run cluster CMK tests
test-cluster-cmk: check-env deps
	@echo "Running cluster CMK tests..."
	$(call run_with_log,cluster-cmk,go test -v -timeout 30m -run TestLogAnalyticsClusterCustomerManagedKey ./...)

# Run validation tests
test-validation: check-env deps
	@echo "Running validation tests..."
	$(call run_with_log,validation,go test -v -timeout 10m -run TestLogAnalyticsWorkspaceValidationRules ./...)

# Run integration tests
test-integration: check-env deps
	@echo "Running integration tests..."
	$(call run_with_log,integration,go test -v -timeout 45m -run TestLogAnalyticsWorkspaceFullIntegration ./...)

# Run performance tests
test-performance: check-env deps
	@echo "Running performance tests..."
	$(call run_with_log,performance-create,go test -v -timeout 60m -run TestLogAnalyticsWorkspaceCreationTime ./...)
	$(call run_with_log,performance-scale,go test -v -timeout 60m -run TestLogAnalyticsWorkspaceScaling ./...)

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
		if [ -f "$$dir/main.tf" ]; then \
			echo "Validating $$dir..."; \
			cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
		fi \
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

# Run quick smoke tests
test-quick: check-env deps
	@echo "Running quick smoke tests..."
	go test -v -timeout 5m -short ./...

# CI/CD pipeline simulation
ci: clean fmt-check lint test-coverage test-junit
	@echo "CI pipeline completed successfully!"

# CD pipeline simulation (includes performance and integration tests)
cd: ci test-integration test-performance
	@echo "CD pipeline completed successfully!"

# Help
help:
	@echo "Available targets:"
	@echo "  make test                 - Run all tests"
	@echo "  make test-single TEST_NAME=TestName - Run specific test"
	@echo "  make test-basic           - Run basic tests only"
	@echo "  make test-complete        - Run complete tests"
	@echo "  make test-secure          - Run security tests"
	@echo "  make test-solutions       - Run solutions tests"
	@echo "  make test-data-export     - Run data export rules tests"
	@echo "  make test-windows-event   - Run Windows event datasource tests"
	@echo "  make test-windows-performance - Run Windows performance counter tests"
	@echo "  make test-storage-insights - Run storage insights tests"
	@echo "  make test-linked-services - Run linked services tests"
	@echo "  make test-clusters        - Run clusters tests"
	@echo "  make test-cluster-cmk     - Run cluster CMK tests"
	@echo "  make test-validation      - Run validation tests"
	@echo "  make test-integration     - Run integration tests"
	@echo "  make test-performance     - Run performance tests"
	@echo "  make test-quick           - Run quick smoke tests (with -short flag)"
	@echo "  make benchmark            - Run benchmarks"
	@echo "  make test-coverage        - Run tests with coverage"
	@echo "  make test-race            - Run tests with race detection"
	@echo "  make test-junit           - Generate JUnit report"
	@echo "  make validate-fixtures    - Validate Terraform fixtures"
	@echo "  make clean                - Clean test artifacts"
	@echo "  make fmt                  - Format Go code"
	@echo "  make lint                 - Run linters"
	@echo "  make security             - Run security scan"
	@echo "  make ci                   - Run CI pipeline"
	@echo "  make cd                   - Run CD pipeline (includes integration tests)"

.PHONY: check-env deps test test-single test-basic test-complete test-secure test-solutions test-data-export test-windows-event test-windows-performance test-storage-insights test-linked-services test-clusters test-cluster-cmk test-validation test-integration test-performance benchmark test-coverage test-race test-junit clean validate-fixtures fmt-check fmt lint security test-quick ci cd help
