# Terraform Testing Guide - Complete Reference

This comprehensive testing guide is organized into focused sections covering all aspects of testing Terraform modules in this repository. It establishes the standards and patterns that all module tests must follow. The `modules/azurerm_kubernetes_cluster` module is the baseline for test structure; Azure DevOps modules (for example `modules/azuredevops_repository`) follow the same structure but use Azure DevOps credentials and provider-specific validation. Some resources will have fewer or different test scenarios based on their capabilities.

## 📚 Guide Structure

### Part 1: Core Concepts
- [**01 - Testing Philosophy & Pyramid**](01-testing-philosophy.md) - Outlines the core principles, testing levels (static, unit, integration), and the "fail fast" approach.
- [**02 - Test Organization & Structure**](02-test-organization.md) - Details the standard directory structure for tests, including fixtures, unit tests, and Go files.

### Part 2: Unit Testing (Native Terraform)
- [**03 - Native Terraform Tests**](03-native-terraform-tests.md) - A deep dive into writing fast, free unit tests using HCL (`.tftest.hcl`) and mocked providers to validate module logic.

### Part 3: Integration Testing (Terratest & Go)
- [**04 - Terratest Integration Overview**](04-terratest-integration-overview.md) - Introduction to using Terratest with Go for deploying and validating real Azure infrastructure. Covers setup and authentication.
- [**05 - Terratest Go File Structure**](05-terratest-file-structure.md) - Defines the roles of the different Go test files: `{module}_test.go`, `integration_test.go`, and `performance_test.go`.
- [**06 - Helper Pattern & Validation Functions**](06-terratest-helpers-and-validation.md) - Explains the crucial "Helper Pattern" for encapsulating Azure SDK logic in `test_helpers.go` to keep tests clean and reusable.
- [**07 - Fixtures and Test Execution**](07-terratest-fixtures-and-execution.md) - Describes how to create Terraform test scenarios (`fixtures`) and use the `Makefile` to run tests in a standardized way.
- [**08 - Advanced Test Scenarios**](08-advanced-testing.md) - Covers complex test cases, including resource lifecycle (updates), security compliance, disaster recovery, and performance benchmarking.

### Part 4: Automation & Troubleshooting
- [**09 - CI/CD Integration**](09-cicd-integration.md) - Details the GitHub Actions workflow for automated test execution, including dynamic module detection and reporting.
- [**10 - Troubleshooting Guide**](10-troubleshooting-guide.md) - Provides solutions for common issues and outlines effective debugging techniques.

## 🚀 Quick Start

To get started with writing tests for a new module:

1.  **[01 - Testing Philosophy](01-testing-philosophy.md)** - Understand the overall approach.
2.  **[02 - Test Organization](02-test-organization.md)** - Create the standard directory structure inside your module's `tests` directory.
3.  **[03 - Native Terraform Tests](03-native-terraform-tests.md)** - Implement unit tests first to validate inputs and logic.
4.  **[06 - Helper Pattern & Validation](06-terratest-helpers-and-validation.md)** - Create a `test_helpers.go` file and a helper struct for your module.
5.  **[07 - Fixtures and Execution](07-terratest-fixtures-and-execution.md)** - Create `fixtures` for your test cases and a `Makefile` to run them.
6.  **[05 - Terratest File Structure](05-terratest-file-structure.md)** - Write your main Go integration tests in `{module_name}_test.go`.

## 🎯 Testing Standards

All modules in this repository must meet these testing standards:

-   **Unit Test Coverage**: All input variable validation logic must be covered by native Terraform tests.
-   **Integration Test Coverage**: All major module features and configuration scenarios must be covered by Terratest integration tests. In this repo, integration tests are the end-to-end validation for a single module (no separate E2E tier).
-   **Security Validation**: All security-related features (e.g., network rules, encryption, secure defaults) must be explicitly validated.
-   **Clean Test Runs**: All tests must pass, and `make clean` should leave no test artifacts behind.
-   **CI/CD Compliance**: All tests must successfully run in the automated GitHub Actions pipeline before a pull request can be merged.
