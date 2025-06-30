# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a multi-module Terraform repository for creating professional, scalable Terraform modules for Azure (azurerm provider). Unlike traditional single-module repositories, this repo follows a monorepo approach where each Azure resource type has its own module directory with independent versioning. Each module directory (e.g., `azurerm_storage_account`, `azurerm_virtual_network`) contains its own complete module structure and GitHub Actions workflow for independent releases.

### Multi-Module Repository Benefits
- **Centralized Development**: All Azure modules in one place for easier maintenance and cross-module consistency
- **Independent Versioning**: Each module can be versioned independently (e.g., `SAv1.0.0` for Storage Account, `VNv2.1.0` for Virtual Network)
- **Shared Standards**: Common tooling, documentation patterns, and CI/CD workflows across all modules
- **Open Source Ready**: Structured for public consumption with clear module boundaries and documentation

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

### Multi-Module Repository Structure
```
azurerm-terraform-modules/
├── .github/
│   ├── workflows/
│   │   ├── module-storage-account.yml    # CI/CD for storage account module
│   │   ├── module-virtual-network.yml    # CI/CD for virtual network module
│   │   └── shared-workflows.yml          # Reusable workflow components
│   └── ISSUE_TEMPLATE/
├── docs/                                  # Shared documentation
│   ├── CONTRIBUTING.md                    # Global contribution guidelines
│   ├── SECURITY.md                       # Security policy
│   └── module-standards.md               # Module development standards
├── scripts/                               # Shared automation scripts
│   ├── validate-module.sh                # Module validation script
│   ├── generate-docs.sh                  # Documentation generation
│   └── tag-release.sh                    # Release tagging script
├── azurerm_storage_account/               # Storage Account module
│   ├── .github/
│   │   └── workflows/
│   │       └── release.yml               # Module-specific release workflow
│   ├── examples/
│   │   ├── simple/                       # Basic usage example
│   │   └── complete/                     # Advanced usage example
│   ├── modules/                          # Sub-modules (optional)
│   │   ├── private_endpoint/
│   │   └── diagnostics/
│   ├── tests/                            # Terratest tests
│   ├── main.tf                           # Main implementation
│   ├── variables.tf                      # Input variables
│   ├── outputs.tf                        # Output definitions
│   ├── versions.tf                       # Provider requirements
│   ├── README.md                         # Module-specific documentation
│   └── CHANGELOG.md                      # Module version history
├── azurerm_virtual_network/               # Virtual Network module
│   ├── .github/
│   │   └── workflows/
│   │       └── release.yml
│   ├── examples/
│   ├── tests/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── README.md
│   └── CHANGELOG.md
├── azurerm_key_vault/                     # Key Vault module
├── azurerm_application_gateway/           # Application Gateway module
├── .gitignore                             # Repository-wide gitignore
├── README.md                              # Repository overview
└── CLAUDE.md                              # This file
```

### Module Versioning Strategy
Each module follows semantic versioning with a descriptive prefix:
- **Storage Account**: `SAv1.0.0`, `SAv1.1.0`, `SAv2.0.0`
- **Virtual Network**: `VNv1.0.0`, `VNv1.1.0`, `VNv2.0.0`  
- **Key Vault**: `KVv1.0.0`, `KVv1.1.0`, `KVv2.0.0`
- **Application Gateway**: `AGv1.0.0`, `AGv1.1.0`, `AGv2.0.0`

This approach allows:
- Independent module evolution and release cycles
- Clear identification of which module version is being used
- Simplified dependency management for consumers
- Easy rollback to previous module versions

### Key Documentation Files
- `_docs/terraform-module-best-practices-guide.md` - Comprehensive best practices guide (Polish)
- `_docs/terraform-module-examples.md` - Practical module implementation examples
- `_docs/repos_analyze.md` - Analysis of existing production Terraform modules

## Development Guidelines

### HashiCorp Best Practices

#### Module Structure and Composition
- **Flat Module Tree**: Maintain a flat module structure to avoid deep nesting and complexity
- **Module Composition**: Use module composition over inheritance - combine multiple focused modules rather than creating one large module
- **Single Responsibility**: Each module should have a clear, single purpose (e.g., storage account, virtual network)
- **Dependency Inversion**: Use data sources to reference existing resources instead of tight coupling between modules

#### Variable Definition Patterns
- **Use `optional()` function**: For optional object attributes with sensible defaults
```hcl
variable "storage_account_config" {
  type = object({
    account_tier             = string
    account_replication_type = string
    enable_https_traffic     = optional(bool, true)
    min_tls_version         = optional(string, "TLS1_2")
    network_rules = optional(object({
      default_action = optional(string, "Allow")
      ip_rules       = optional(list(string), [])
      subnet_ids     = optional(list(string), [])
    }), {})
  })
}
```
- **Comprehensive Validation**: Implement validation rules with clear error messages
- **Group Related Configurations**: Use object types to group related settings
- **Secure Defaults**: Always set secure defaults (e.g., `https_only = true`, `minimum_tls_version = "TLS1_2"`)

#### Resource Implementation Best Practices
- **Conditional Resource Creation**: Use `count` or `for_each` for optional resources
```hcl
resource "azurerm_storage_account_network_rules" "this" {
  count = var.network_rules != null ? 1 : 0
  # ...
}
```
- **Dynamic Blocks**: Use dynamic blocks for flexible, repeatable configurations
- **Provider Configuration**: Declare required provider versions without defining provider blocks
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
```
- **Security by Default**: Implement secure defaults for all resources
- **Enterprise Features**: Always include support for diagnostic settings, private endpoints, and monitoring

#### Module Input/Output Patterns
- **Minimal Required Inputs**: Only require inputs that have no sensible defaults
- **Structured Outputs**: Export structured objects rather than individual attributes
```hcl
output "storage_account" {
  description = "Storage account configuration and attributes"
  value = {
    id                   = azurerm_storage_account.this.id
    name                 = azurerm_storage_account.this.name
    primary_blob_endpoint = azurerm_storage_account.this.primary_blob_endpoint
    # ... other relevant attributes
  }
}
```
- **Sensitive Output Handling**: Mark sensitive outputs appropriately

#### Testing Strategy
- **Terratest Framework**: Use Terratest for comprehensive module testing
- **Test Pyramid**: Include unit tests (validation), integration tests (examples), and end-to-end tests
- **Negative Testing**: Test validation rules and error conditions
- **Example-Based Testing**: Every example should have corresponding tests
- **Multi-Environment Testing**: Test across different Azure regions and configurations

#### Documentation Standards
- **Auto-Generated Docs**: Use terraform-docs for consistent documentation generation
```bash
terraform-docs markdown table . > README.md
```
- **Usage Examples**: Provide both simple and complete usage examples
- **Variable Documentation**: Document purpose, type, default, and validation rules for every variable
- **Output Documentation**: Explain what each output provides and when to use it
- **Changelog Maintenance**: Follow semantic versioning in CHANGELOG.md

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

### GitHub Actions Workflows
The repository uses GitHub Actions for automated CI/CD:

#### Shared Workflows (.github/workflows/)
- **`shared-workflows.yml`**: Reusable workflow components for validation, testing, and documentation
- **`module-validation.yml`**: Common validation steps (terraform fmt, validate, tflint, checkov)
- **`terratest-runner.yml`**: Standardized Terratest execution

#### Module-Specific Workflows
Each module has its own `.github/workflows/release.yml`:
```yaml
name: Release Storage Account Module
on:
  push:
    paths:
      - 'azurerm_storage_account/**'
    branches: [main]
  pull_request:
    paths:
      - 'azurerm_storage_account/**'

jobs:
  validate:
    uses: ./.github/workflows/module-validation.yml
    with:
      module_path: azurerm_storage_account
      
  test:
    uses: ./.github/workflows/terratest-runner.yml
    with:
      module_path: azurerm_storage_account
      
  release:
    if: github.event_name == 'push'
    needs: [validate, test]
    runs-on: ubuntu-latest
    steps:
      - name: Create Release
        uses: actions/create-release@v1
        with:
          tag_name: SAv${{ github.run_number }}
          release_name: Storage Account Module v${{ github.run_number }}
```

#### Automation Features
- **Path-based triggering**: Only affected modules trigger their CI/CD
- **Independent releases**: Each module can be released separately
- **Semantic versioning**: Automated version tagging with module prefixes
- **Quality gates**: Mandatory validation, security scanning, and testing
- **Documentation generation**: Auto-update README.md with terraform-docs

## Important Notes
- This is a multi-module repository with independent versioning per module
- Each module directory contains a complete, production-ready Terraform module
- All modules follow HashiCorp best practices and Azure security standards
- Modules support enterprise features: diagnostics, monitoring, private endpoints
- Focus on reusability, security, and maintainability
- Open source repository designed for community consumption and contribution

## Repository Standards

### Naming Conventions
- **Module Directories**: Use Azure resource type naming (e.g., `azurerm_storage_account`)
- **Version Tags**: Use abbreviated prefixes (e.g., `SAv1.0.0`, `VNv2.1.0`)
- **Branch Names**: Use conventional naming (`feature/sa-private-endpoints`, `fix/vn-subnet-validation`)
- **Variable Names**: Use clear, descriptive names with Azure naming conventions

### Code Quality Standards
- **Terraform Format**: All code must pass `terraform fmt -check`
- **Validation**: All configurations must pass `terraform validate`
- **Security Scanning**: All modules must pass Checkov security analysis
- **Linting**: All modules must pass tflint validation
- **Testing**: All modules must have Terratest tests with >80% coverage

### Documentation Requirements
- **README.md**: Each module must have comprehensive documentation
- **CHANGELOG.md**: Track all changes with semantic versioning
- **examples/**: Provide both simple and complete usage examples
- **terraform-docs**: Auto-generated documentation must be current

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