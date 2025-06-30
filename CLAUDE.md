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

# Task Master AI - Claude Code Integration Guide

## Essential Commands

### Core Workflow Commands

```bash
# Project Setup
task-master init                                    # Initialize Task Master in current project
task-master parse-prd .taskmaster/docs/prd.txt      # Generate tasks from PRD document
task-master models --setup                        # Configure AI models interactively

# Daily Development Workflow
task-master list                                   # Show all tasks with status
task-master next                                   # Get next available task to work on
task-master show <id>                             # View detailed task information (e.g., task-master show 1.2)
task-master set-status --id=<id> --status=done    # Mark task complete

# Task Management
task-master add-task --prompt="description" --research        # Add new task with AI assistance
task-master expand --id=<id> --research --force              # Break task into subtasks
task-master update-task --id=<id> --prompt="changes"         # Update specific task
task-master update --from=<id> --prompt="changes"            # Update multiple tasks from ID onwards
task-master update-subtask --id=<id> --prompt="notes"        # Add implementation notes to subtask

# Analysis & Planning
task-master analyze-complexity --research          # Analyze task complexity
task-master complexity-report                      # View complexity analysis
task-master expand --all --research               # Expand all eligible tasks

# Dependencies & Organization
task-master add-dependency --id=<id> --depends-on=<id>       # Add task dependency
task-master move --from=<id> --to=<id>                       # Reorganize task hierarchy
task-master validate-dependencies                            # Check for dependency issues
task-master generate                                         # Update task markdown files (usually auto-called)
```

## Key Files & Project Structure

### Core Files

- `.taskmaster/tasks/tasks.json` - Main task data file (auto-managed)
- `.taskmaster/config.json` - AI model configuration (use `task-master models` to modify)
- `.taskmaster/docs/prd.txt` - Product Requirements Document for parsing
- `.taskmaster/tasks/*.txt` - Individual task files (auto-generated from tasks.json)
- `.env` - API keys for CLI usage

### Claude Code Integration Files

- `CLAUDE.md` - Auto-loaded context for Claude Code (this file)
- `.claude/settings.json` - Claude Code tool allowlist and preferences
- `.claude/commands/` - Custom slash commands for repeated workflows
- `.mcp.json` - MCP server configuration (project-specific)

### Directory Structure

```
project/
├── .taskmaster/
│   ├── tasks/              # Task files directory
│   │   ├── tasks.json      # Main task database
│   │   ├── task-1.md      # Individual task files
│   │   └── task-2.md
│   ├── docs/              # Documentation directory
│   │   ├── prd.txt        # Product requirements
│   ├── reports/           # Analysis reports directory
│   │   └── task-complexity-report.json
│   ├── templates/         # Template files
│   │   └── example_prd.txt  # Example PRD template
│   └── config.json        # AI models & settings
├── .claude/
│   ├── settings.json      # Claude Code configuration
│   └── commands/         # Custom slash commands
├── .env                  # API keys
├── .mcp.json            # MCP configuration
└── CLAUDE.md            # This file - auto-loaded by Claude Code
```

## MCP Integration

Task Master provides an MCP server that Claude Code can connect to. Configure in `.mcp.json`:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your_key_here",
        "PERPLEXITY_API_KEY": "your_key_here",
        "OPENAI_API_KEY": "OPENAI_API_KEY_HERE",
        "GOOGLE_API_KEY": "GOOGLE_API_KEY_HERE",
        "XAI_API_KEY": "XAI_API_KEY_HERE",
        "OPENROUTER_API_KEY": "OPENROUTER_API_KEY_HERE",
        "MISTRAL_API_KEY": "MISTRAL_API_KEY_HERE",
        "AZURE_OPENAI_API_KEY": "AZURE_OPENAI_API_KEY_HERE",
        "OLLAMA_API_KEY": "OLLAMA_API_KEY_HERE"
      }
    }
  }
}
```

### Essential MCP Tools

```javascript
help; // = shows available taskmaster commands
// Project setup
initialize_project; // = task-master init
parse_prd; // = task-master parse-prd

// Daily workflow
get_tasks; // = task-master list
next_task; // = task-master next
get_task; // = task-master show <id>
set_task_status; // = task-master set-status

// Task management
add_task; // = task-master add-task
expand_task; // = task-master expand
update_task; // = task-master update-task
update_subtask; // = task-master update-subtask
update; // = task-master update

// Analysis
analyze_project_complexity; // = task-master analyze-complexity
complexity_report; // = task-master complexity-report
```

## Claude Code Workflow Integration

### Standard Development Workflow

#### 1. Project Initialization

```bash
# Initialize Task Master
task-master init

# Create or obtain PRD, then parse it
task-master parse-prd .taskmaster/docs/prd.txt

# Analyze complexity and expand tasks
task-master analyze-complexity --research
task-master expand --all --research
```

If tasks already exist, another PRD can be parsed (with new information only!) using parse-prd with --append flag. This will add the generated tasks to the existing list of tasks..

#### 2. Daily Development Loop

```bash
# Start each session
task-master next                           # Find next available task
task-master show <id>                     # Review task details

# During implementation, check in code context into the tasks and subtasks
task-master update-subtask --id=<id> --prompt="implementation notes..."

# Complete tasks
task-master set-status --id=<id> --status=done
```

#### 3. Multi-Claude Workflows

For complex projects, use multiple Claude Code sessions:

```bash
# Terminal 1: Main implementation
cd project && claude

# Terminal 2: Testing and validation
cd project-test-worktree && claude

# Terminal 3: Documentation updates
cd project-docs-worktree && claude
```

### Custom Slash Commands

Create `.claude/commands/taskmaster-next.md`:

```markdown
Find the next available Task Master task and show its details.

Steps:

1. Run `task-master next` to get the next task
2. If a task is available, run `task-master show <id>` for full details
3. Provide a summary of what needs to be implemented
4. Suggest the first implementation step
```

Create `.claude/commands/taskmaster-complete.md`:

```markdown
Complete a Task Master task: $ARGUMENTS

Steps:

1. Review the current task with `task-master show $ARGUMENTS`
2. Verify all implementation is complete
3. Run any tests related to this task
4. Mark as complete: `task-master set-status --id=$ARGUMENTS --status=done`
5. Show the next available task with `task-master next`
```

## Tool Allowlist Recommendations

Add to `.claude/settings.json`:

```json
{
  "allowedTools": [
    "Edit",
    "Bash(task-master *)",
    "Bash(git commit:*)",
    "Bash(git add:*)",
    "Bash(npm run *)",
    "mcp__task_master_ai__*"
  ]
}
```

## Configuration & Setup

### API Keys Required

At least **one** of these API keys must be configured:

- `ANTHROPIC_API_KEY` (Claude models) - **Recommended**
- `PERPLEXITY_API_KEY` (Research features) - **Highly recommended**
- `OPENAI_API_KEY` (GPT models)
- `GOOGLE_API_KEY` (Gemini models)
- `MISTRAL_API_KEY` (Mistral models)
- `OPENROUTER_API_KEY` (Multiple models)
- `XAI_API_KEY` (Grok models)

An API key is required for any provider used across any of the 3 roles defined in the `models` command.

### Model Configuration

```bash
# Interactive setup (recommended)
task-master models --setup

# Set specific models
task-master models --set-main claude-3-5-sonnet-20241022
task-master models --set-research perplexity-llama-3.1-sonar-large-128k-online
task-master models --set-fallback gpt-4o-mini
```

## Task Structure & IDs

### Task ID Format

- Main tasks: `1`, `2`, `3`, etc.
- Subtasks: `1.1`, `1.2`, `2.1`, etc.
- Sub-subtasks: `1.1.1`, `1.1.2`, etc.

### Task Status Values

- `pending` - Ready to work on
- `in-progress` - Currently being worked on
- `done` - Completed and verified
- `deferred` - Postponed
- `cancelled` - No longer needed
- `blocked` - Waiting on external factors

### Task Fields

```json
{
  "id": "1.2",
  "title": "Implement user authentication",
  "description": "Set up JWT-based auth system",
  "status": "pending",
  "priority": "high",
  "dependencies": ["1.1"],
  "details": "Use bcrypt for hashing, JWT for tokens...",
  "testStrategy": "Unit tests for auth functions, integration tests for login flow",
  "subtasks": []
}
```

## Claude Code Best Practices with Task Master

### Context Management

- Use `/clear` between different tasks to maintain focus
- This CLAUDE.md file is automatically loaded for context
- Use `task-master show <id>` to pull specific task context when needed

### Iterative Implementation

1. `task-master show <subtask-id>` - Understand requirements
2. Explore codebase and plan implementation
3. `task-master update-subtask --id=<id> --prompt="detailed plan"` - Log plan
4. `task-master set-status --id=<id> --status=in-progress` - Start work
5. Implement code following logged plan
6. `task-master update-subtask --id=<id> --prompt="what worked/didn't work"` - Log progress
7. `task-master set-status --id=<id> --status=done` - Complete task

### Complex Workflows with Checklists

For large migrations or multi-step processes:

1. Create a markdown PRD file describing the new changes: `touch task-migration-checklist.md` (prds can be .txt or .md)
2. Use Taskmaster to parse the new prd with `task-master parse-prd --append` (also available in MCP)
3. Use Taskmaster to expand the newly generated tasks into subtasks. Consdier using `analyze-complexity` with the correct --to and --from IDs (the new ids) to identify the ideal subtask amounts for each task. Then expand them.
4. Work through items systematically, checking them off as completed
5. Use `task-master update-subtask` to log progress on each task/subtask and/or updating/researching them before/during implementation if getting stuck

### Git Integration

Task Master works well with `gh` CLI:

```bash
# Create PR for completed task
gh pr create --title "Complete task 1.2: User authentication" --body "Implements JWT auth system as specified in task 1.2"

# Reference task in commits
git commit -m "feat: implement JWT auth (task 1.2)"
```

### Parallel Development with Git Worktrees

```bash
# Create worktrees for parallel task development
git worktree add ../project-auth feature/auth-system
git worktree add ../project-api feature/api-refactor

# Run Claude Code in each worktree
cd ../project-auth && claude    # Terminal 1: Auth work
cd ../project-api && claude     # Terminal 2: API work
```

## Troubleshooting

### AI Commands Failing

```bash
# Check API keys are configured
cat .env                           # For CLI usage

# Verify model configuration
task-master models

# Test with different model
task-master models --set-fallback gpt-4o-mini
```

### MCP Connection Issues

- Check `.mcp.json` configuration
- Verify Node.js installation
- Use `--mcp-debug` flag when starting Claude Code
- Use CLI as fallback if MCP unavailable

### Task File Sync Issues

```bash
# Regenerate task files from tasks.json
task-master generate

# Fix dependency issues
task-master fix-dependencies
```

DO NOT RE-INITIALIZE. That will not do anything beyond re-adding the same Taskmaster core files.

## Important Notes

### AI-Powered Operations

These commands make AI calls and may take up to a minute:

- `parse_prd` / `task-master parse-prd`
- `analyze_project_complexity` / `task-master analyze-complexity`
- `expand_task` / `task-master expand`
- `expand_all` / `task-master expand --all`
- `add_task` / `task-master add-task`
- `update` / `task-master update`
- `update_task` / `task-master update-task`
- `update_subtask` / `task-master update-subtask`

### File Management

- Never manually edit `tasks.json` - use commands instead
- Never manually edit `.taskmaster/config.json` - use `task-master models`
- Task markdown files in `tasks/` are auto-generated
- Run `task-master generate` after manual changes to tasks.json

### Claude Code Session Management

- Use `/clear` frequently to maintain focused context
- Create custom slash commands for repeated Task Master workflows
- Configure tool allowlist to streamline permissions
- Use headless mode for automation: `claude -p "task-master next"`

### Multi-Task Updates

- Use `update --from=<id>` to update multiple future tasks
- Use `update-task --id=<id>` for single task updates
- Use `update-subtask --id=<id>` for implementation logging

### Research Mode

- Add `--research` flag for research-based AI enhancement
- Requires a research model API key like Perplexity (`PERPLEXITY_API_KEY`) in environment
- Provides more informed task creation and updates
- Recommended for complex technical tasks

---

## Multi-Agent Development Workflow

### Agent Coordination Principles

This repository supports **parallel development** using multiple Claude Code sessions (agents), each specialized for different aspects of the project. This approach maximizes efficiency and allows for concurrent work on complex infrastructure modules.

### Agent Specialization Matrix

#### 🏗️ Module Development Agent
**Primary Responsibility**: Core Terraform module implementation
- **Focus Areas**: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- **Tools**: Context7 MCP for Terraform documentation, Gemini Zen for code review
- **Tasks**: Variable definitions, resource implementations, output structures
- **Coordination**: Communicates module interfaces to other agents

#### 🔄 Workflow/CI Agent  
**Primary Responsibility**: GitHub Actions and automation setup
- **Focus Areas**: `.github/workflows/`, automation scripts, release processes
- **Tools**: Context7 MCP for GitHub Actions docs, security scanning configs
- **Tasks**: CI/CD pipelines, security scanning, automated testing triggers
- **Coordination**: Ensures workflows match module structure from Module Agent

#### 📚 Documentation Agent
**Primary Responsibility**: Examples, README files, and user guides
- **Focus Areas**: `examples/`, `README.md`, documentation generation
- **Tools**: terraform-docs integration, markdown generation
- **Tasks**: Usage examples, module documentation, user guides
- **Coordination**: Uses module interfaces from Module Agent for accurate examples

#### 🧪 Testing Agent
**Primary Responsibility**: Terratest suites and validation
- **Focus Areas**: `tests/`, validation scripts, test scenarios
- **Tools**: Go/Terratest documentation, Azure testing patterns
- **Tasks**: Test suite implementation, validation scenarios, performance tests
- **Coordination**: Tests against module implementations from Module Agent

#### 🔒 Security Agent
**Primary Responsibility**: Security configurations and compliance
- **Focus Areas**: Security defaults, compliance frameworks, audit configs
- **Tools**: Azure security documentation, compliance frameworks
- **Tasks**: Security baselines, compliance validation, threat modeling
- **Coordination**: Reviews and enhances Module Agent implementations

### Parallel Workflow Coordination

#### Phase 1: Planning and Interface Definition
1. **Module Agent** defines core module structure and interfaces
2. **All Agents** review and agree on module contracts
3. **TaskMaster** creates detailed task breakdown for each agent

#### Phase 2: Parallel Development
```bash
# Terminal 1: Module Development
cd project && claude
task-master show 6.1  # Initialize Module Directory Structure
task-master set-status --id=6.1 --status=in-progress

# Terminal 2: Workflow/CI Development  
cd project && claude
task-master show 2    # Basic Validation Workflow
task-master set-status --id=2 --status=in-progress

# Terminal 3: Documentation Development
cd project && claude  
task-master show 4    # terraform-docs Generation
task-master set-status --id=4 --status=in-progress

# Terminal 4: Testing Framework
cd project && claude
task-master show 5    # Terratest Framework Setup
task-master set-status --id=5 --status=in-progress

# Terminal 5: Security Configuration
cd project && claude
task-master show 7    # Enterprise and Security Features
task-master set-status --id=7 --status=in-progress
```

#### Phase 3: Integration and Validation
1. **All Agents** complete their parallel tasks
2. **Integration testing** across all components
3. **Cross-agent review** and validation
4. **Final coordination** and release preparation

### Communication Protocols

#### Context Sharing
Each agent maintains awareness through:
- **TaskMaster updates**: `task-master update-subtask --id=X.Y --prompt="progress notes"`
- **Shared Context7**: Common documentation sources
- **Gemini Zen consultation**: Cross-validation of approaches
- **Git synchronization**: Regular commits with task references

#### Dependency Management
```bash
# Example: Testing Agent waits for Module Agent
task-master show 6.4  # Check if core resource implementation is complete
# Only proceed with test development when Module Agent marks 6.4 as done
```

#### Quality Gates
- **Module Agent**: All resources properly implemented and validated
- **Workflow Agent**: CI/CD passes all quality checks
- **Documentation Agent**: Examples work with actual module
- **Testing Agent**: All tests pass against module implementation
- **Security Agent**: Security scan results are clean

### Agent Interaction Patterns

#### Pattern 1: Sequential Dependencies
```
Module Agent (6.1-6.4) → Testing Agent (8.1-8.3)
Module Agent (6.7) → Documentation Agent (README examples)
```

#### Pattern 2: Parallel Independent Work
```
Workflow Agent (2.1-2.4) || Documentation Agent (examples/) || Security Agent (7.1-7.3)
```

#### Pattern 3: Cross-Agent Validation
```
Module Agent implements → Security Agent reviews → Module Agent adjusts
Documentation Agent creates examples → Testing Agent validates → Documentation Agent updates
```

### Coordination Tools and Commands

#### TaskMaster Coordination Commands
```bash
# Check what other agents are working on
task-master get-tasks --status=in-progress

# Update progress for coordination
task-master update-subtask --id=6.2 --prompt="Variable definitions complete, interface available for Testing Agent"

# Research coordination
task-master research --query="Azure Storage Account security best practices" --save-to=6.3
```

#### Context7 Shared Research
```bash
# All agents can access shared Terraform documentation
context7: terraform azurerm storage account latest provider documentation
context7: github actions workflow terraform validation best practices
context7: terratest azure testing patterns
```

#### Gemini Zen Cross-Validation
```bash
# Agent consultation pattern
gemini-zen: "Review this storage account module implementation for HashiCorp best practices"
gemini-zen: "Validate this CI/CD workflow against enterprise security requirements"
gemini-zen: "Assess test coverage completeness for this Azure module"
```

### Anti-Patterns to Avoid

#### ❌ Don't Do This
- **Duplicate Work**: Multiple agents implementing the same feature
- **Interface Conflicts**: Changing module interfaces without coordination
- **Resource Conflicts**: Multiple agents modifying the same files simultaneously
- **Dependency Deadlock**: Circular dependencies between agent tasks

#### ✅ Do This Instead
- **Clear Ownership**: Each agent owns specific files/directories
- **Interface Contracts**: Agree on module contracts before parallel work
- **Regular Sync**: Use TaskMaster for progress coordination
- **Conflict Resolution**: Use Git branching for experimental work

### Multi-Agent Success Metrics

#### Efficiency Gains
- **Parallel Development**: 4-5x faster than sequential development
- **Specialized Expertise**: Each agent focuses on their strengths
- **Reduced Context Switching**: Agents maintain focused context

#### Quality Improvements
- **Cross-Agent Review**: Multiple perspectives on each component
- **Specialized Validation**: Security, testing, and documentation experts
- **Comprehensive Coverage**: All aspects covered by specialized agents

#### Coordination Quality
- **Task Completion Rate**: >90% of parallel tasks complete on schedule
- **Integration Issues**: <5% of integration issues due to coordination failures
- **Rework Rate**: <10% rework due to interface mismatches

---

_This multi-agent workflow enables efficient, high-quality development of complex Terraform infrastructure modules._
