.PHONY: test test-short test-go unit

TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

test: test-short

test-short: unit

unit:
	@echo "Running terraform unit tests..."
	cd "$(TEST_DIR)" && terraform test -test-directory=./unit

test-go:
	@echo "Running Go tests..."
	cd "$(TEST_DIR)" && go test -v ./...
