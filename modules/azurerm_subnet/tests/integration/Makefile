# Makefile for Subnet Module Terratest

.PHONY: test test-basic test-complete test-secure test-private-endpoint deps clean

# Default test timeout
TIMEOUT ?= 30m

# Test specific targets
test: deps
	@echo "Running all Subnet module integration tests..."
	go test -v -timeout $(TIMEOUT) -parallel 4

test-basic: deps
	@echo "Running basic subnet test..."
	go test -v -timeout $(TIMEOUT) -run TestSubnetBasic

test-complete: deps
	@echo "Running complete subnet test..."
	go test -v -timeout $(TIMEOUT) -run TestSubnetComplete

test-secure: deps
	@echo "Running secure subnet test..."
	go test -v -timeout $(TIMEOUT) -run TestSubnetSecure

test-private-endpoint: deps
	@echo "Running private endpoint subnet test..."
	go test -v -timeout $(TIMEOUT) -run TestSubnetPrivateEndpoint

# Install dependencies
deps:
	@echo "Installing Go dependencies..."
	go mod download
	go mod tidy

# Clean up
clean:
	@echo "Cleaning up..."
	go clean -testcache
	rm -rf .terraform terraform.tfstate* .terraform.lock.hcl

# Validate environment
validate-env:
	@echo "Validating environment variables..."
	@test -n "$(ARM_SUBSCRIPTION_ID)" || (echo "ARM_SUBSCRIPTION_ID not set" && exit 1)
	@test -n "$(ARM_TENANT_ID)" || (echo "ARM_TENANT_ID not set" && exit 1)
	@test -n "$(ARM_CLIENT_ID)" || (echo "ARM_CLIENT_ID not set" && exit 1)
	@test -n "$(ARM_CLIENT_SECRET)" || (echo "ARM_CLIENT_SECRET not set" && exit 1)
	@echo "Environment validation successful!"

# Help
help:
	@echo "Available targets:"
	@echo "  make test                 - Run all integration tests"
	@echo "  make test-basic          - Run basic subnet test"
	@echo "  make test-complete       - Run complete subnet test"
	@echo "  make test-secure         - Run secure subnet test"
	@echo "  make test-private-endpoint - Run private endpoint subnet test"
	@echo "  make deps                - Install Go dependencies"
	@echo "  make clean               - Clean up test artifacts"
	@echo "  make validate-env        - Validate required environment variables"
	@echo ""
	@echo "Required environment variables:"
	@echo "  ARM_SUBSCRIPTION_ID      - Azure subscription ID"
	@echo "  ARM_TENANT_ID           - Azure tenant ID"
	@echo "  ARM_CLIENT_ID           - Azure service principal client ID"
	@echo "  ARM_CLIENT_SECRET       - Azure service principal client secret"
	@echo ""
	@echo "Optional environment variables:"
	@echo "  ARM_TEST_LOCATION       - Azure region for tests (default: northeurope)"
	@echo "  TIMEOUT                 - Test timeout (default: 30m)"