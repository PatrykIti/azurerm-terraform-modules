# Makefile for Terratest execution
SHELL := /bin/bash

TIMEOUT ?= 60m
PARALLEL ?= 4
LOG_DIR ?= test_outputs
LOG_TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

define run_with_log
	@mkdir -p $(LOG_DIR)
	@echo "Saving output to $(LOG_DIR)/$(1)_$(LOG_TIMESTAMP).log"
	@bash -c 'set -o pipefail; { $(2); } 2>&1 | tee "$(LOG_DIR)/$(1)_$(LOG_TIMESTAMP).log"'
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

check-env:
	@echo "Checking required environment variables..."
	@test -n "$(ARM_SUBSCRIPTION_ID)" || test -n "$(AZURE_SUBSCRIPTION_ID)" || (echo "ARM_SUBSCRIPTION_ID or AZURE_SUBSCRIPTION_ID is not set" && exit 1)
	@test -n "$(ARM_TENANT_ID)" || test -n "$(AZURE_TENANT_ID)" || (echo "ARM_TENANT_ID or AZURE_TENANT_ID is not set" && exit 1)
	@test -n "$(ARM_CLIENT_ID)" || test -n "$(AZURE_CLIENT_ID)" || (echo "ARM_CLIENT_ID or AZURE_CLIENT_ID is not set" && exit 1)
	@test -n "$(ARM_CLIENT_SECRET)" || test -n "$(AZURE_CLIENT_SECRET)" || (echo "ARM_CLIENT_SECRET or AZURE_CLIENT_SECRET is not set" && exit 1)
	@echo "All required environment variables are set."

deps:
	@echo "Installing Go dependencies..."
	go mod download

test-compile: deps
	@echo "Running Go compile gate..."
	$(call run_with_log,compile,go test ./... -run=^$$)

test: check-env deps test-compile
	@echo "Running all Terratest tests..."
	$(call run_with_log,all,go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...)

test-single: check-env deps
	@test -n "$(TEST_NAME)" || (echo "Usage: make test-single TEST_NAME=TestName" && exit 1)
	$(call run_with_log,single,go test -v -timeout $(TIMEOUT) -run "^$(TEST_NAME)$$" ./...)

test-basic: check-env deps
	$(call run_with_log,basic,go test -v -timeout 20m -run '^TestBasicLinuxVirtualMachine$$' ./...)

test-secure: check-env deps
	$(call run_with_log,secure,go test -v -timeout 20m -run '^TestSecureLinuxVirtualMachine$$' ./...)

test-complete: check-env deps
	$(call run_with_log,complete,go test -v -timeout 30m -run '^TestLinuxVirtualMachineCompleteIntegration$$' ./...)

test-data-disks: check-env deps
	$(call run_with_log,data-disks,go test -v -timeout 30m -run '^TestLinuxVirtualMachineDataDisks$$' ./...)

test-extensions: check-env deps
	$(call run_with_log,extensions,go test -v -timeout 30m -run '^TestLinuxVirtualMachineExtensions$$' ./...)

test-integration: check-env deps
	$(call run_with_log,integration,go test -v -timeout 45m -run '^TestLinuxVirtualMachine(CompleteIntegration|Lifecycle)$$' ./...)

benchmark: check-env deps
	$(call run_with_log,benchmark,go test -v -run=^$$ -bench '^BenchmarkLinuxVirtualMachineCreationSimple$$' -benchtime=1x ./...)

test-short: deps
	$(call run_with_log,short,go test -v -short ./...)

run-sequential: check-env deps
	$(call run_with_log,sequential,bash ./run_tests_sequential.sh)

run-parallel: check-env deps
	$(call run_with_log,parallel,bash ./run_tests_parallel.sh)

clean:
	@echo "Cleaning test artifacts..."
	rm -f test-results.xml coverage.out coverage.html
	rm -rf test_outputs/
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +

fmt-check:
	@echo "Checking Go formatting..."
	@if [ -n "$$(gofmt -l .)" ]; then \
		echo "Go files are not formatted. Run 'make fmt' to fix."; \
		gofmt -l .; \
		exit 1; \
	fi

fmt:
	@echo "Formatting Go code..."
	gofmt -w .

help:
	@echo "Available targets:"
	@echo "  make test                  - Run all Terratest tests"
	@echo "  make test-compile          - Compile Go tests only (no execution)"
	@echo "  make test-single TEST_NAME=TestName"
	@echo "  make test-basic            - Run TestBasicLinuxVirtualMachine"
	@echo "  make test-secure           - Run TestSecureLinuxVirtualMachine"
	@echo "  make test-complete         - Run TestLinuxVirtualMachineCompleteIntegration"
	@echo "  make test-data-disks       - Run TestLinuxVirtualMachineDataDisks"
	@echo "  make test-extensions       - Run TestLinuxVirtualMachineExtensions"
	@echo "  make test-integration      - Run integration lifecycle tests"
	@echo "  make benchmark             - Run BenchmarkLinuxVirtualMachineCreationSimple"
	@echo "  make test-short            - Run tests in short mode"
	@echo "  make run-sequential        - Run wrapper script sequentially"
	@echo "  make run-parallel          - Run wrapper script in parallel"
	@echo "  make clean                 - Clean test artifacts"
	@echo "  make fmt-check             - Verify Go formatting"
	@echo "  make fmt                   - Format Go files"

.PHONY: check-env deps test-compile test test-single test-basic test-secure test-complete test-data-disks test-extensions test-integration benchmark test-short run-sequential run-parallel clean fmt-check fmt help
