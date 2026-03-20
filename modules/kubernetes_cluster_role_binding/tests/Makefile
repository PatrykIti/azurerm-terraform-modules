# Makefile for Terratest execution
SHELL := /bin/bash

TIMEOUT ?= 90m
PARALLEL ?= 1
LOG_DIR ?= test_outputs
LOG_TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

define run_with_log
	@mkdir -p $(LOG_DIR)
	@bash -c 'set -o pipefail; $(2) 2>&1 | tee "$(LOG_DIR)/$(1)_$(LOG_TIMESTAMP).log"'
endef

test:
	$(call run_with_log,all,go test -v -timeout $(TIMEOUT) -parallel $(PARALLEL) ./...)

test-integration:
	$(call run_with_log,integration,go test -v -timeout $(TIMEOUT) -run TestKubernetesClusterRoleBindingLifecycle ./...)

test-performance:
	$(call run_with_log,performance,go test -v -timeout $(TIMEOUT) -run TestKubernetesClusterRoleBindingCreationTime ./...)
