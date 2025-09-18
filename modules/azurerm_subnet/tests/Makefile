# Makefile for Terratest execution

# Variables
TIMEOUT ?= 30m
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
	go mod download
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
	go test -v -timeout 15m -run TestBasicSubnet ./...

# Run complete tests
test-complete: check-env deps
	@echo "Running complete tests..."
	go test -v -timeout 30m -run TestCompleteSubnet ./...

# Run security tests
test-security: check-env deps
	@echo "Running security tests..."
	go test -v -timeout 30m -run TestSubnetSecurity ./...
	go test -v -timeout 30m -run TestSubnetSecurityConfiguration ./...

# Run network tests
test-network: check-env deps
	@echo "Running network tests..."
	go test -v -timeout 30m -run TestSubnetNetworkRules ./...
	go test -v -timeout 30m -run TestSubnetWithNetworkRules ./...

# Run private endpoint tests
test-private-endpoint: check-env deps
	@echo "Running private endpoint tests..."
	go test -v -timeout 30m -run TestSubnetPrivateEndpoint ./...
	go test -v -timeout 30m -run TestSubnetPrivateEndpointIntegration ./...

# Run validation tests
test-validation: check-env deps
	@echo "Running validation tests..."
	go test -v -timeout 10m -run TestSubnetValidationRules ./...
	go test -v -timeout 30m -run TestSubnetValidationIntegration ./...

# Run lifecycle tests
test-lifecycle: check-env deps
	@echo "Running lifecycle tests..."
	go test -v -timeout 30m -run TestSubnetLifecycle ./...

# Run compliance tests
test-compliance: check-env deps
	@echo "Running compliance tests..."
	go test -v -timeout 30m -run TestSubnetCompliance ./...

# Run integration tests
test-integration: check-env deps
	@echo "Running integration tests..."
	go test -v -timeout 45m -run TestSubnetFullIntegration ./...

# Run performance tests
test-performance: check-env deps
	@echo "Running performance tests..."
	go test -v -timeout 60m -run TestSubnetCreationTime ./...
	go test -v -timeout 60m -run TestSubnetScaling ./...
	go test -v -timeout 60m -run TestSubnetUpdatePerformance ./...
	go test -v -timeout 60m -run TestSubnetDestroyPerformance ./...

# Run benchmarks
benchmark: check-env deps
	@echo "Running benchmarks..."
	go test -v -run=^$$ -bench=. -benchtime=1x ./...

# Run specific benchmarks
benchmark-creation: check-env deps
	@echo "Running creation benchmarks..."
	go test -v -run=^$$ -bench=BenchmarkSubnetCreation -benchtime=1x ./...

benchmark-integration: check-env deps
	@echo "Running integration benchmarks..."
	go test -v -run=^$$ -bench=BenchmarkSubnetIntegrationCreation -benchtime=1x ./...

benchmark-performance: check-env deps
	@echo "Running performance benchmarks..."
	go test -v -run=^$$ -bench=BenchmarkSubnetCreationSimple -benchtime=1x ./...
	go test -v -run=^$$ -bench=BenchmarkSubnetCreationWithFeatures -benchtime=1x ./...
	go test -v -run=^$$ -bench=BenchmarkSubnetCreationWithScale -benchtime=1x ./...
	go test -v -run=^$$ -bench=BenchmarkSubnetParallelCreation -benchtime=1x ./...

# Run tests with coverage
test-coverage: check-env deps
	@echo "Running tests with coverage..."
	go test -v -timeout $(TIMEOUT) -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests with race detection
test-race: check-env deps
	@echo "Running tests with race detection..."
	go test -v -timeout $(TIMEOUT) -race ./...

# Generate JUnit report
test-junit: check-env deps
	@echo "Running tests with JUnit output..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v -timeout $(TIMEOUT) ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	rm -f coverage.out coverage.html test-results.xml security-report.json
	rm -rf test_outputs/ test_results_*/ test-results/
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +
	find . -name ".test-data" -type d -exec rm -rf {} +

# Validate terraform fixtures
validate-fixtures:
	@echo "Validating Terraform fixtures..."
	@for dir in fixtures/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Validating $$dir..."; \
			cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
		fi \
	done
	@for dir in fixtures/*/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Validating $$dir..."; \
			cd $$dir && terraform init -backend=false && terraform validate && cd ../../..; \
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

# Run tests sequentially (for debugging)
test-sequential: check-env deps
	@echo "Running tests sequentially..."
	./run_tests_sequential.sh

# Run tests in parallel
test-parallel: check-env deps
	@echo "Running tests in parallel..."
	./run_tests_parallel.sh

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
	@echo "  make test-basic          - Run basic tests only"
	@echo "  make test-complete       - Run complete tests"
	@echo "  make test-security       - Run security tests"
	@echo "  make test-network        - Run network tests"
	@echo "  make test-private-endpoint - Run private endpoint tests"
	@echo "  make test-validation     - Run validation tests"
	@echo "  make test-lifecycle      - Run lifecycle tests"
	@echo "  make test-compliance     - Run compliance tests"
	@echo "  make test-integration    - Run integration tests"
	@echo "  make test-performance    - Run performance tests"
	@echo "  make test-quick          - Run quick smoke tests (with -short flag)"
	@echo "  make test-sequential     - Run tests sequentially using script"
	@echo "  make test-parallel       - Run tests in parallel using script"
	@echo "  make benchmark           - Run all benchmarks"
	@echo "  make benchmark-creation  - Run creation benchmarks"
	@echo "  make benchmark-integration - Run integration benchmarks"
	@echo "  make benchmark-performance - Run performance benchmarks"
	@echo "  make test-coverage       - Run tests with coverage"
	@echo "  make test-race          - Run tests with race detection"
	@echo "  make test-junit         - Generate JUnit report"
	@echo "  make validate-fixtures   - Validate Terraform fixtures"
	@echo "  make clean              - Clean test artifacts"
	@echo "  make fmt                - Format Go code"
	@echo "  make lint               - Run linters"
	@echo "  make security           - Run security scan"
	@echo "  make ci                 - Run CI pipeline"
	@echo "  make cd                 - Run CD pipeline (includes integration tests)"

.PHONY: check-env deps test test-single test-basic test-complete test-security test-network test-private-endpoint test-validation test-lifecycle test-compliance test-integration test-performance benchmark benchmark-creation benchmark-integration benchmark-performance test-coverage test-race test-junit clean validate-fixtures fmt-check fmt lint security test-quick test-sequential test-parallel ci cd help