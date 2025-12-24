# Terraform Azure Modules - Development Guide

This document contains references to mandatory guidelines for Terraform module development in this project.

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

## Multi-Agent Execution Guidelines

**MANDATORY**: When working with TaskMaster tasks that have subtasks, you MUST:
- Always use multiple agents (subagents) for parallel execution wherever possible
- Assign each independent subtask to a different agent for maximum efficiency
- Provide each agent with:
  - This CLAUDE.md file for project context
  - Specific, detailed instructions for their subtask
  - All necessary reference files and paths
  - Clear success criteria
- Use `mcp__taskmaster-ai__set_task_status` to mark subtasks as "in-progress" when assigning to agents
- Monitor progress and coordinate results between agents

This approach is REQUIRED to maximize development speed and efficiency. Sequential execution of independent tasks is NOT acceptable when parallel execution is possible.

## Important Instructions

- **ALWAYS** review the relevant reference files based on your current task
- **NEVER** skip reading these documents when they apply to your work
- **CRITICALLY EVALUATE** all suggestions from tools - you are the final decision maker
- **PRIORITIZE** project-specific needs over generic best practices
- **MANDATORY**: When Gemini Zen or other tools suggest using web search, ALWAYS use Context7 MCP first if the information is available there. Think independently - do not follow tool suggestions 1:1. You are the orchestrator and must make your own decisions about which tools to use based on what's available to you

## Project Documentation

### [AGENTS.md](AGENTS.md)
**MANDATORY REVIEW** when:
- Starting work on this project
- Creating or updating modules
- Making decisions about structure, documentation, testing, or releases

Contains: Condensed, repo-specific guidance sourced from `docs/MODULE_GUIDE/*` and current repo conventions.

### [PROJECT.md](PROJECT.md)
**MANDATORY REVIEW** when:
- Starting work on this project
- Understanding project architecture and goals
- Implementing any features or modifications
- Making technical decisions about implementation

Contains: Complete project specification for BlenderForge MCP including system architecture (Blender addon + MCP server), MVP functionality, development phases, directory structure, implementation principles, and technology stack. This is the primary reference document that defines what we're building and how.

## Reference Documentation

### 1. [Terraform Best Practices Guide](docs/TERRAFORM_BEST_PRACTICES_GUIDE.md)
**MANDATORY REVIEW** when:
- Creating new Terraform modules
- Contributing to existing modules
- Understanding module structure and naming conventions
- Implementing security best practices
- Writing module documentation
- Setting up module testing
- Following iteration patterns and variable design principles

Contains: Comprehensive guide for Terraform module development including resource naming conventions, module structure, variable design patterns, security best practices, testing requirements, documentation standards, contribution process, and common pitfalls to avoid. This is the primary reference for all Terraform module development standards in this repository.

### 2. [Terraform Testing Guide](docs/TESTING_GUIDE/README.md)
**MANDATORY REVIEW** when:
- Setting up testing for new modules
- Writing unit tests with native Terraform test framework
- Implementing integration tests with Terratest
- Creating end-to-end test scenarios
- Configuring CI/CD testing pipelines
- Implementing security and compliance testing
- Optimizing test performance and costs
- Using mock strategies for expensive resources

Contains: A comprehensive, structured guide to testing Terraform modules. It covers the testing philosophy, directory organization, native unit tests, Terratest integration tests (including file structure, helper patterns, fixtures, and execution), advanced scenarios (lifecycle, compliance, performance), CI/CD integration, and a troubleshooting guide.

### 3. [Terraform New Module Guide](docs/MODULE_GUIDE/README.md)
**MANDATORY REVIEW** when:
- Creating a new Terraform module from scratch
- Planning module architecture and structure
- Setting up module directory structure
- Implementing security-first defaults
- Creating examples for different use cases
- Setting up comprehensive testing (unit and integration)
- Configuring CI/CD for new modules
- Preparing module for release
- Following the module creation checklist

Contains: Step-by-step guide for creating new Terraform modules including module planning considerations, complete directory structure, core file templates (main.tf, variables.tf, outputs.tf), example implementations (basic, complete, secure), test setup with Terratest and native Terraform tests, Makefile configuration, documentation requirements, CI/CD integration steps, release process, and comprehensive checklist. This is the primary reference for creating production-ready Terraform modules in this repository.

### 4. [GitHub Actions Workflows Documentation](docs/WORKFLOWS.md)
**MANDATORY REVIEW** when:
- Understanding the current GitHub Actions workflow architecture
- Debugging workflow issues or failures
- Adding new Terraform modules to the repository
- Modifying existing CI/CD pipelines
- Understanding how workflows interact with each other
- Troubleshooting module detection or composite actions

Contains: Comprehensive documentation of the implemented GitHub Actions workflow system including architecture overview with diagrams, detailed description of each workflow (module-ci, module-release, module-docs, pr-validation, repo-maintenance), shared actions documentation, module-specific composite actions, workflow interaction flows, step-by-step guide for adding new modules, and troubleshooting guide.

### 5. [Security Policy](docs/SECURITY.md)
**MANDATORY REVIEW** when:
- Implementing security features in modules
- Understanding compliance requirements (SOC 2, ISO 27001, GDPR, PCI DSS)
- Following security best practices
- Conducting security reviews
- Reporting or handling security vulnerabilities
- Creating new modules with security-by-default approach
- Implementing network restrictions and private endpoints

Contains: Comprehensive security policies including security principles (Defense in Depth, Least Privilege, Zero Trust), compliance standards details, security controls by Azure service, security scanning requirements, vulnerability management procedures, best practices for module users, security checklist for new modules, and continuous improvement guidelines.

## GitHub Project Management

**Project**: AzureRM Terraform Modules (Project #2)
- We are actively working within the GitHub Project "AzureRM Terraform Modules" for task tracking and project management
- Use `gh project` commands to interact with project items when needed
- This project tracks the development progress of all Terraform modules in this repository
