# Terraform Azure Modules - New Module Creation Guide

This guide provides a structured overview of the process for creating a new, production-ready Terraform module in this repository. Each section links to a more detailed document covering specific aspects of module development.

Following these guides is mandatory to ensure all modules are consistent, secure, and maintainable.

## Table of Contents

1.  [**Introduction to New Module Creation**](./01-introduction.md)
    - Guiding Principles
    - Module Naming Convention

2.  [**Module Structure**](./02-module-structure.md)
    - Standard Directory Layout
    - Key Components Explained

3.  [**Core Module Files**](./03-core-files.md)
    - `versions.tf`
    - `variables.tf`
    - `main.tf`
    - `outputs.tf`

4.  [**Configuration Files**](./04-configuration-files.md)
    - `module.json`
    - `.releaserc.js`
    - `.terraform-docs.yml`

5.  [**Module Documentation**](./05-documentation.md)
    - `README.md`
    - `CONTRIBUTING.md`
    - `SECURITY.md`
    - `VERSIONING.md`

6.  [**Module Examples**](./06-examples.md)
    - Philosophy of Examples
    - Standard Example Scenarios (`basic`, `complete`, `secure`)
    - Example Structure

7.  [**Automation and Helper Scripts**](./07-automation.md)
    - `Makefile`
    - `generate-docs.sh`

8.  [**Testing Overview**](./08-testing-overview.md)
    - Testing Layers (Static Analysis, Unit, Integration)
    - Link to the complete [Terraform Testing Guide](../TESTING_GUIDE/README.md)

9.  [**CI/CD Integration**](./09-cicd-integration.md)
    - Integrating with GitHub Actions Workflows
    - Release Process

10. [**New Module Checklist**](./10-checklist.md)
    - A comprehensive checklist to verify before submitting a new module.
