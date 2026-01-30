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
	go test -v -timeout 15m -run TestBasicRedisCache ./...

# Run complete tests
test-complete: check-env deps
	@echo "Running complete tests..."
	go test -v -timeout 30m -run TestCompleteRedisCache ./...

# Run security tests
test-secure: check-env deps
	@echo "Running security tests..."
	go test -v -timeout 30m -run TestSecureRedisCache ./...

# Run patch schedule tests
test-patch-schedule: check-env deps
	@echo "Running patch schedule tests..."
	go test -v -timeout 30m -run TestRedisCachePatchSchedule ./...

# Run firewall rules tests
test-firewall-rules: check-env deps
	@echo "Running firewall rules tests..."
	go test -v -timeout 30m -run TestRedisCacheFirewallRules ./...

# Run linked server tests
test-linked-server: check-env deps
	@echo "Running linked server tests..."
	go test -v -timeout 45m -run TestRedisCacheLinkedServer ./...

# Run integration tests
test-integration: check-env deps
	@echo "Running integration tests..."
	go test -v -timeout 45m -run 'TestRedisCache(FullIntegration|Lifecycle)' ./...

# Run performance tests
test-performance: check-env deps
	@echo "Running performance tests..."
	go test -v -timeout 60m -run TestRedisCacheCreationTime ./...

# Run benchmarks
benchmark: check-env deps
	@echo "Running benchmarks..."
	go test -v -run=^$$ -bench=. -benchtime=1x ./...

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
		echo "Go files need formatting:"; \
		gofmt -l .; \
		exit 1; \
	fi
	@echo "Go formatting OK."

# Lint check (optional)
lint:
	@echo "Running Go lint..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run ./...; \
	else \
		echo "golangci-lint not installed; skipping."; \
	fi

.PHONY: check-env deps test test-single test-basic test-complete test-secure test-patch-schedule test-firewall-rules test-linked-server test-integration test-performance benchmark test-coverage test-race test-junit clean validate-fixtures fmt-check lint
