.PHONY: test unit

TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

test: unit

unit:
	@echo "Running terraform unit tests..."
	cd "$(TEST_DIR)" && terraform test -test-directory=./unit
