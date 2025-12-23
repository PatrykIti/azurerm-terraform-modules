# Makefile for Terratest execution

# Variables
TIMEOUT ?= 30m
TEST_FILTER ?= Test
PARALLEL ?= 8

# Environment check
check-env:
	@echo "Checking required environment variables..."
	@test -n "$(AZDO_ORG_SERVICE_URL)" || (echo "AZDO_ORG_SERVICE_URL is not set" && exit 1)
	@test -n "$(AZDO_PERSONAL_ACCESS_TOKEN)" || (echo "AZDO_PERSONAL_ACCESS_TOKEN is not set" && exit 1)
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
	go test -v -timeout 15m -run TestBasicAzuredevopsProject ./...

# Run complete tests
test-complete: check-env deps
	@echo "Running complete tests..."
	go test -v -timeout 30m -run TestCompleteAzuredevopsProject ./...

# Run security tests
test-secure: check-env deps
	@echo "Running security tests..."
	go test -v -timeout 30m -run TestSecureAzuredevopsProject ./...

# Run validation tests
test-validation: check-env deps
	@echo "Running validation tests..."
	go test -v -timeout 10m -run TestAzuredevopsProjectValidationRules ./...

# Run integration tests
test-integration: check-env deps
	@echo "Running integration tests..."
	go test -v -timeout 45m -run TestAzuredevopsProjectFullIntegration ./...

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
	@if [ -n "$(shell gofmt -l .)" ]; then \
		echo "Go files are not formatted:"; \
		gofmt -l .; \
		exit 1; \
	fi
	@echo "Go formatting is OK."
