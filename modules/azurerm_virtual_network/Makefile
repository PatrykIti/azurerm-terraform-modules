.PHONY: test test-short test-integration test-all
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TESTS_DIR := $(abspath $(MAKEFILE_DIR)/tests)

# Run only short tests (basic functionality)
test-short:
	cd "$(TESTS_DIR)" && go test -v -short -parallel 8 -timeout 30m

# Run only integration tests
test-integration:
	cd "$(TESTS_DIR)" && go test -v -run "Integration|Lifecycle|Disaster|Compliance|Monitoring" -parallel 4 -timeout 60m

# Run all tests
test-all:
	cd "$(TESTS_DIR)" && go test -v -parallel 8 -timeout 60m

# Default target
test: test-short
