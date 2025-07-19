# Makefile for Terratest execution, aligned with project standards.

# Variables
TIMEOUT ?= 30m
PARALLEL ?= 8
TEST_NAME ?= ""

# Default target
all: test

# Run all Go tests in parallel. This is the default command for a full test run.
test:
	@echo "Running all Go tests..."
	go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...

# Run a single, specific test function. Useful for debugging.
# Example: make test-single TEST_NAME=TestRouteTableBasic
test-single:
	@echo "Running single test: $(TEST_NAME)..."
	go test -v -timeout $(TIMEOUT) -run ^$(TEST_NAME)$ ./...

# Run all performance benchmarks.
benchmark:
	@echo "Running performance benchmarks..."
	go test -run=^$ -bench=.

# Run tests and generate an HTML code coverage report.
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests and generate a JUnit XML report for CI/CD integration.
test-junit:
	@echo "Running tests and generating JUnit report..."
	go install github.com/jstemmer/go-junit-report/v2@latest
	go test -v ./... 2>&1 | go-junit-report -set-exit-code > test-results.xml
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
	@echo "  make test-single       - Run a single test. Usage: make test-single TEST_NAME=TestRouteTableBasic"
	@echo "  make benchmark         - Run all performance benchmarks."
	@echo "  make test-coverage     - Generate an HTML code coverage report."
	@echo "  make test-junit        - Generate a JUnit XML report for CI/CD."
	@echo "  make fmt               - Format Go source code."
	@echo "  make lint              - Run the Go linter."
	@echo "  make clean             - Remove all test artifacts."
	@echo "  make ci                - Run a full CI pipeline simulation (fmt, lint, coverage, junit)."
	@echo "  make help              - Show this help message."

.PHONY: all test test-single benchmark test-coverage test-junit fmt lint clean ci help
