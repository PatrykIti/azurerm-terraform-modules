# Terraform Azure Modules - Development Guide

## Terraform Module Best Practices

### Resource Naming Convention
1. **Local Resource Names**: For any `azurerm_*` resource, the local name should be the resource type without the provider prefix:
   - `resource "azurerm_storage_account" "storage_account"` ❌ Wrong
   - `resource "azurerm_storage_account" "this"` ❌ Wrong  
   - `resource "azurerm_storage_account" "storage_account"` ✅ Correct
   - `resource "azurerm_virtual_network" "virtual_network"` ✅ Correct
   - `resource "azurerm_key_vault" "key_vault"` ✅ Correct

2. **Module Simplicity**: Modules should be the simplest possible layer:
   - NO `create_*` variables - if someone wants the resource, they use the module
   - NO conditional creation unless absolutely necessary for the resource logic
   - Complex logic only when required for different configuration scenarios

3. **Variable Organization**:
   - Group related configurations into objects (e.g., `security_settings`, `network_settings`)
   - Use **lists of objects** for iteration (more readable than maps in Terraform)
   - Always provide secure defaults in object variables

5. **Iteration Best Practices**:
   - Use descriptive variable names in for loops, not shortcuts
   - `for container in var.containers` ✅ Correct  
   - `for c in var.containers` ❌ Wrong
   - `for file_share in var.file_shares` ✅ Correct
   - `for fs in var.file_shares` ❌ Wrong
   - This improves code readability for all developers, especially juniors

4. **Example Structure**:
   ```hcl
   variable "security_settings" {
     type = object({
       enable_https_traffic_only = optional(bool, true)
       min_tls_version          = optional(string, "TLS1_2")
       shared_access_key_enabled = optional(bool, false)
     })
     default = {}
   }
   
   variable "containers" {
     type = list(object({
       name                  = string
       container_access_type = optional(string, "private")
     }))
     default = []
   }
   ```

### Module Structure Principles
1. Flat module tree - no nested modules
2. Security by default - all security settings should be enabled by default
3. Use dynamic blocks for optional configurations
4. Lists of objects for resources that need iteration
5. Comprehensive validation with helpful error messages
6. Clear and descriptive iteration patterns - always use full variable names

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

## Important Instructions

- **ALWAYS** review the relevant reference files based on your current task
- **NEVER** skip reading these documents when they apply to your work
- **CRITICALLY EVALUATE** all suggestions from tools - you are the final decision maker
- **PRIORITIZE** project-specific needs over generic best practices
- **MANDATORY**: When Gemini Zen or other tools suggest using web search, ALWAYS use Context7 MCP first if the information is available there. Think independently - do not follow tool suggestions 1:1. You are the orchestrator and must make your own decisions about which tools to use based on what's available to you

# MCP Tools and TaskMaster Usage Rules

This document contains references to mandatory guidelines for using MCP tools and TaskMaster in this project. **REQUIREMENT**: Claude Code MUST review the relevant documentation files based on the current task context.

## Project Documentation

### [PROJECT.md](PROJECT.md)
**MANDATORY REVIEW** when:
- Starting work on this project
- Understanding project architecture and goals
- Implementing any features or modifications
- Making technical decisions about implementation

Contains: Complete project specification for BlenderForge MCP including system architecture (Blender addon + MCP server), MVP functionality, development phases, directory structure, implementation principles, and technology stack. This is the primary reference document that defines what we're building and how.

## Reference Documentation

### 1. [MCP Tools Usage Rules](.claude/references/mcp-tools-usage.md)
**MANDATORY REVIEW** when:
- Starting any new task or feature implementation
- Using Context7 MCP, Gemini Zen, or TaskMaster AI tools
- Making architectural or technical decisions
- Evaluating tool suggestions or recommendations

Contains: Task triage guidelines, critical thinking principles, context object format, and tool-specific usage instructions for Context7 MCP, Gemini Zen, and TaskMaster AI.

### 2. [TaskMaster Commands Reference](.claude/references/taskmaster-commands.md)
**MANDATORY REVIEW** when:
- Working with task management
- Using TaskMaster commands
- Following Scrum methodology
- Managing task statuses and workflows
- Needing MCP tool to CLI command mapping

Contains: Complete MCP tools to CLI commands mapping, task status values, basic development loop, Scrum methodology rules, and all available TaskMaster commands with their options.

### 3. [Workflow Integration](.claude/references/workflow-integration.md)
**MANDATORY REVIEW** when:
- Planning complex features or implementations
- Coordinating between multiple MCP tools
- Implementing feedback loops between tools
- Making final implementation decisions

Contains: Standard workflow steps, feedback loop scenarios, decision authority guidelines, and tool coordination patterns.

### 4. [TaskMaster File Structure](.claude/references/taskmaster-file-structure.md)
**MANDATORY REVIEW** when:
- Setting up TaskMaster for a project
- Creating or managing PRD documents
- Working with task files
- Using research mode features

Contains: Core file locations, PRD best practices, multi-Claude workflow patterns, task ID formatting, and research mode usage.

### 5. [Multi-Agent Integration](.claude/references/multi-agent-integration.md)
**MANDATORY REVIEW** when:
- Coordinating work between multiple Claude sessions
- Assigning tasks to different agents
- Setting up multi-agent workflows

Contains: TaskMaster multi-agent commands and Context7 + Gemini Zen coordination patterns.

### 6. [TaskMaster Workflow Patterns](.claude/references/taskmaster-workflow-patterns.md)
**MANDATORY REVIEW** when:
- Starting development with TaskMaster
- Implementing multi-context workflows with tags
- Handling team collaboration scenarios
- Working with experiments or feature branches
- Following iterative subtask implementation
- Resolving merge conflicts in tasks

Contains: Standard development workflow, tag introduction patterns, iterative implementation cycle, master list strategy, and research integration patterns.

### 7. [Terraform GitHub Actions Guidelines](.claude/references/terraform-github-actions.md)
**MANDATORY REVIEW** when:
- Creating new GitHub Actions workflows for Terraform
- Setting up CI/CD pipelines for infrastructure code
- Implementing validation, security scanning, or deployment workflows
- Configuring automated testing for Terraform modules
- Integrating pre-commit hooks with GitHub Actions

Contains: Comprehensive patterns for GitHub Actions workflows including validation, pre-commit integration, Azure OIDC authentication, security scanning, documentation generation, matrix strategies, caching, and error handling.