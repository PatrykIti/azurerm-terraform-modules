# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Terraform module development guide and template repository for creating professional, scalable Terraform modules for Azure (azurerm provider). It serves as a knowledge base consolidating best practices from production modules and provides comprehensive guidance for teams developing Azure Terraform modules.

## Common Development Commands

### Terraform Validation and Formatting
```bash
# Initialize Terraform (without backend for local validation)
terraform init -backend=false

# Validate Terraform configuration
terraform validate

# Check formatting (recursive)
terraform fmt -check -recursive

# Auto-format Terraform files
terraform fmt -recursive

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Testing with Terratest (Go)
```bash
# Navigate to tests directory
cd tests

# Initialize Go module
go mod init test
go mod tidy

# Run tests with 30-minute timeout
go test -v -timeout 30m ./...
```

### Documentation Generation
```bash
# Install terraform-docs (if not already installed)
curl -sSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-linux-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs

# Generate module documentation
./terraform-docs markdown . > README.md
```

### Semantic Versioning
```bash
# Install semantic-release tools
npm install -g semantic-release @semantic-release/git @semantic-release/changelog

# Run semantic release
semantic-release
```

### Security Scanning
```bash
# Run Checkov for Terraform security analysis
checkov -d . --framework terraform
```

## Architecture and Structure

### Standard Module Directory Structure
```
terraform-azurerm-<resource-name>/
├── .azuredevops/                 # CI/CD pipelines
│   ├── semanticversion.yml       # Automatic versioning
│   ├── sonarqube.yml            # Code quality analysis
│   └── terraformdocs.yml        # Documentation generation
├── examples/                     # Usage examples
│   ├── simple/                  # Basic example
│   └── complete/                # Advanced example
├── modules/                     # Sub-modules (optional)
├── tests/                       # Automated tests (Terratest)
├── main.tf                      # Main implementation
├── variables.tf                 # Input variable definitions
├── outputs.tf                   # Output definitions
├── versions.tf                  # Version requirements
├── README.md                    # Module documentation
├── CHANGELOG.md                 # Change history
└── CONTRIBUTING.md              # Contribution guidelines
```

### Key Documentation Files
- `_docs/terraform-module-best-practices-guide.md` - Comprehensive best practices guide (Polish)
- `_docs/terraform-module-examples.md` - Practical module implementation examples
- `_docs/repos_analyze.md` - Analysis of existing production Terraform modules

## Development Guidelines

### Variable Definition Patterns
- Use `optional()` function for optional object attributes with defaults
- Implement comprehensive validation with helpful error messages
- Group related configurations into objects
- Set secure defaults (e.g., `https_only = true`, `minimum_tls_version = "1.2"`)

### Resource Implementation
- Use count/for_each for conditional resource creation
- Implement dynamic blocks for flexible configurations
- Follow security-by-default principles
- Always include diagnostic settings for Azure resources

### Testing Strategy
- Write Terratest tests for module validation
- Test both simple and complex configurations
- Include negative test cases for validation rules

### Documentation Standards
- Use terraform-docs for auto-generated documentation
- Include usage examples for common scenarios
- Document all variables, outputs, and requirements
- Maintain CHANGELOG.md with semantic versioning

## Conventional Commit Format
```
feat: Add support for private endpoints
fix: Fix IP address validation
docs: Update usage examples
refactor: Simplify dynamic blocks logic
chore: Update azurerm provider version

BREAKING CHANGE: Renamed variable 'enable_logs' to 'enable_diagnostic_settings'
```

## CI/CD Integration
The repository uses Azure DevOps pipelines for:
- Automated documentation generation
- Code quality analysis with SonarQube
- Semantic versioning and releases
- Terraform validation and testing

## Important Notes
- This is primarily a documentation and template repository
- Actual Terraform module implementations should follow the patterns documented here
- All modules should support enterprise features: diagnostics, monitoring, private endpoints
- Focus on reusability, security, and maintainability

## MCP Tools Usage Rules (MANDATORY)

### Task Triage (FIRST STEP)
Before engaging the full workflow, assess task complexity:
- **Trivial tasks** (typos, simple fixes): Handle directly or single consultation
- **Complex tasks/features**: Engage full workflow starting with Context7 MCP
- **Unclear scope**: Start with Context7 to gather information

### Critical Thinking Rule for Claude (ORCHESTRATOR)
**FUNDAMENTAL PRINCIPLE**: As the orchestrator, you (Claude) must:
- **Analyze all inputs with "cold head" objectivity** - nie przyjmuj niczego na wiarę
- **Question and validate** suggestions from all tools, especially Gemini Zen
- **Apply critical thinking** - what works in theory may fail in practice
- **Consider context** - solution must fit THIS project, not generic best practices
- **Make independent decisions** - tools provide input, YOU decide implementation

Gemini Zen is NOT a deity - it's a thinking partner. Analyze its suggestions critically:
- Does this make sense for our specific tech stack?
- Is this over-engineered for our needs?
- Are there simpler alternatives?
- What are the trade-offs?

### Context Object Format
Pass structured briefings between tools to maintain state and ensure no context is lost:
```json
{
  "task_id": "identifier",
  "problem_statement": "clear description",
  "context7_findings": {
    "relevant_docs": [],
    "code_examples": [],
    "related_files": []
  },
  "gemini_zen_analysis": {
    "assessment": "",
    "recommendations": [],
    "concerns": []
  },
  "task_master_plan": [],
  "feedback_state": {
    "status": "proceed|feedback_required|completed",
    "from_step": "string",
    "to_step": "string",
    "request": "specific feedback request"
  }
}
```

### Tool-Specific Guidelines

#### Context7 MCP
**When to use:**
- ALWAYS use Context7 MCP to verify technical stack details and documentation
- Use when encountering errors or wandering without clear direction - check documentation examples to clarify issues
- ALWAYS use Context7 MCP BEFORE using web search
- Pass Context7 findings to Gemini Zen for solution refinement

**How to use:**
1. Search for the specific library/framework documentation
2. Focus on code examples and implementation patterns
3. Extract relevant snippets for the current problem
4. Share findings with Gemini Zen for analysis

#### Gemini Zen
**When to use:**
- ALWAYS use for analysis, debugging, and validation
- Use to ensure a given area follows best practices
- Pass Context7 documentation to Gemini Zen for brainstorming and verification

**How to use:**
1. Share Context7 documentation findings with Gemini Zen
2. Request analysis for YAGNI/SOLID/DRY principles and design patterns
3. Ask for critical perspective and alternative approaches
4. Use as a sounding board for technical decisions

**IMPORTANT:** You (Claude) are the orchestrator and final decision maker. Gemini Zen provides:
- Fresh perspective from a different angle
- Suggestions and critical analysis
- Alternative viewpoints you might not see
But YOU make the final decisions about project correctness after analyzing Gemini Zen's input critically.

#### TaskMaster AI
**When to use:**
- ALWAYS use for breaking down epics/user stories/tasks in detail
- Use AFTER initial analysis and discussion with Gemini Zen
- Follow Scrum best practices for task decomposition
- Parse PRD documents to generate initial task structure
- Expand complex tasks into subtasks based on complexity analysis

**How to use:**
1. Complete technical analysis with Context7 and Gemini Zen first
2. Create detailed task breakdowns with clear acceptance criteria
3. Ensure tasks are atomic and estimable
4. Include technical implementation details from prior analysis

**Essential TaskMaster Commands:**
```bash
# Initial setup (only once per project)
task-master init
task-master parse-prd .taskmaster/docs/prd.txt

# Daily workflow
task-master next                          # Get next available task
task-master show <id>                     # View task details
task-master set-status --id=<id> --status=done

# Task management
task-master expand --id=<id> --research   # Break task into subtasks
task-master update-subtask --id=<id> --prompt="implementation notes"
task-master analyze-complexity --research # Analyze all tasks
```

**Task Status Values:**
- `pending` - Ready to work on
- `in-progress` - Currently being worked on
- `done` - Completed and verified
- `blocked` - Waiting on dependencies
- `deferred` - Postponed

**Development Loop with TaskMaster:**
1. `task-master next` - Find next task
2. `task-master show <id>` - Review requirements
3. `task-master set-status --id=<id> --status=in-progress`
4. Implement the feature/fix
5. `task-master update-subtask --id=<id> --prompt="what worked/challenges"`
6. `task-master set-status --id=<id> --status=done`

**Scrum Methodology Rules for TaskMaster:**
- **Epic Structure**: Group related tasks into epics (major features/components)
- **User Stories**: Write tasks as user stories where applicable ("As a... I want... So that...")
- **Story Points**: Estimate complexity using Fibonacci sequence (1, 2, 3, 5, 8, 13)
- **Sprint Planning**: Organize tasks into 2-week sprints based on velocity
- **Definition of Done**: Each task must have clear acceptance criteria
- **Task Hierarchy**: Epic → User Story → Task → Subtask
- **Priority Levels**: Use MoSCoW method (Must have, Should have, Could have, Won't have)
- **Daily Updates**: When updating tasks, include: What was done, What will be done, Any blockers

### Workflow Integration
1. **Problem Identification** → Context7 MCP (documentation)
2. **Analysis & Validation** → Gemini Zen (with Context7 findings)
3. **Task Planning** → TaskMaster AI (after technical clarity)
4. **Implementation** → You (Claude) orchestrate based on all inputs

These tools are complementary - use them in sequence for maximum effectiveness.

### Workflow with Feedback Loops

#### 1. Problem Identification → Context7 MCP
- Gather documentation and examples
- If insufficient, refine query and retry
- Default to Context7 for project-specific information
- ALWAYS prefer Context7 over web search for known technologies

#### 2. Analysis & Validation → Gemini Zen
- Analyze with Context7 findings
- **Feedback**: If missing context, return to step 1
- Web search allowed for external/novel problems (new libraries, uncommon errors)
- CRITICALLY EVALUATE all suggestions - don't accept blindly

#### 3. Task Planning → TaskMaster AI
- Break down validated approach
- **Feedback**: If reveals flaws, return to step 2
- Follow Scrum best practices
- Ensure tasks align with project constraints

#### 4. Implementation → Claude orchestrates
- Execute based on all inputs
- Document decisions and rationale
- Apply critical thinking to all tool outputs
- Make final decisions based on project context

### Feedback Loop Scenarios

#### Scenario 1: Analysis → Problem ID (Gemini Zen to Context7)
**Task**: "Improve performance of `process_large_file` function"
- **Step 1**: Context7 gathers source code
- **Step 2**: Gemini Zen discovers external microservice dependency
- **Feedback Trigger**: Insufficient context about external service
- **Action**: Return to Step 1 with refined request: "Find API contract and performance metrics for DataEnrichmentService"

#### Scenario 2: Planning → Analysis (TaskMaster to Gemini Zen)
**Task**: "Implement user profile image uploads"
- **Step 2**: Gemini Zen proposes S3 + pre-signed URLs solution
- **Step 3**: TaskMaster identifies missing security/validation tasks
- **Feedback Trigger**: Flaw in validated approach
- **Action**: Return to Step 2: "Solution incomplete - add image validation and security requirements"

### Decision Authority
**ABSOLUTE RULE**: Claude is the orchestrator and final decision maker. 

Tools provide:
- Context7: Authoritative documentation (trust but verify)
- Gemini Zen: Analysis and alternatives (evaluate critically)
- TaskMaster: Structured planning (adjust to project needs)

But Claude:
- Synthesizes all inputs with critical thinking
- Questions everything - especially complex solutions
- Makes final implementation decisions
- Takes responsibility for choices
- Prioritizes project success over theoretical perfection

## Task Master File Structure

### Core Files
- `.taskmaster/tasks/tasks.json` - Main task database (never edit manually)
- `.taskmaster/docs/prd.txt` - Product Requirements Document
- `.taskmaster/config.json` - AI model configuration
- `.taskmaster/tasks/*.md` - Individual task files (auto-generated)

### PRD Best Practices
When creating PRD for TaskMaster:
1. Be specific about technical requirements
2. Include user stories with clear acceptance criteria
3. Specify technology constraints (Next.js 15+, HeroUI, etc.)
4. Define MVP scope vs future enhancements
5. Include performance and security requirements

### Multi-Claude Workflows
For complex projects, use multiple Claude sessions:
```bash
# Terminal 1: Main implementation
cd project && claude

# Terminal 2: Testing and validation  
cd project && claude

# Terminal 3: Documentation updates
cd project && claude
```

### Task ID Format
- Main tasks: `1`, `2`, `3`, etc.
- Subtasks: `1.1`, `1.2`, `2.1`, etc.
- Reference in commits: `git commit -m "feat: implement auth (task 1.2)"`

### Research Mode
Always use `--research` flag for:
- Complex technical decisions
- Architecture planning
- Performance optimization strategies
- Security implementations

Example: `task-master expand --id=1 --research`