# Makefile for Terratest execution

# Variables
TIMEOUT ?= 60m
TEST_FILTER ?= Test
PARALLEL ?= 8
AZURE_LOCATION ?= northeurope

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
	go mod tidy

# Run all tests
test: check-env deps
	@echo "Running all tests..."
	go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...

# Run specific test
test-single: check-env deps
	@echo "Running test: $(TEST_NAME)"
	go test -v -timeout $(TIMEOUT) -run $(TEST_NAME) ./...

# Run basic tests only
test-basic: check-env deps
	@echo "Running basic tests..."
	go test -v -timeout 30m -run TestBasicKubernetesCluster ./...

# Run complete tests
test-complete: check-env deps
	@echo "Running complete tests..."
	go test -v -timeout 60m -run TestCompleteKubernetesCluster ./...

# Run security tests
test-secure: check-env deps
	@echo "Running security tests..."
	go test -v -timeout 60m -run TestSecureKubernetesCluster ./...

# Run network tests
test-network: check-env deps
	@echo "Running network tests..."
	go test -v -timeout 60m -run TestNetworkKubernetesCluster ./...


# Run validation tests
test-validation: check-env deps
	@echo "Running validation tests..."
	go test -v -timeout 15m -run TestKubernetesClusterValidationRules ./...

# Run integration tests (long-running)
test-integration: check-env deps
	@echo "Running integration tests..."
	go test -v -timeout 60m -run "TestKubernetesClusterLifecycle" ./...

# Run benchmarks
benchmark: check-env deps
	@echo "Running benchmarks..."
	go test -v -run=^$ -bench=. -benchtime=1x ./...

# Run tests with coverage
test-coverage: check-env deps
	@echo "Running tests with coverage..."
	go test -v -timeout $(TIMEOUT) -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Generate JUnit report for CI/CD
test-junit: check-env deps
	@echo "Running tests with JUnit output..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v -timeout $(TIMEOUT) ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml

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

.PHONY: check-env deps test test-single test-basic test-complete test-secure test-network test-validation test-integration benchmark test-coverage test-junit clean fmt lint ci
