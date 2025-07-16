# Azure Terraform Modules Repository Reference

This file contains essential information about the azurerm-terraform-modules repository that is automatically loaded for every task.

## 🎯 Repository Overview

- **Purpose**: Production-ready Terraform modules for Azure infrastructure
- **Standards**: Follows HashiCorp best practices and enterprise security standards
- **Architecture**: Monorepo structure with independent module versioning
- **Project Management**: GitHub Project "AzureRM Terraform Modules" (Project #2)
- **Philosophy**: "Nothing manual in the repo" - everything is automated

## 📁 Repository Structure

```
azurerm-terraform-modules/
├── modules/                     # Terraform modules (each independently versioned)
│   ├── azurerm_storage_account/ # Storage Account module
│   └── azurerm_virtual_network/ # Virtual Network module
├── docs/                        # Shared documentation
│   ├── TERRAFORM_BEST_PRACTICES_GUIDE.md
│   ├── TERRAFORM_TESTING_GUIDE.md
│   ├── TERRAFORM_NEW_MODULE_GUIDE.md
│   ├── WORKFLOWS.md
│   └── SECURITY.md
├── scripts/                     # Automation scripts
│   ├── templates/              # Module templates
│   └── tools/                  # Helper scripts
├── examples/                    # Cross-module examples
├── tests/                       # Shared test utilities
├── security-policies/           # Custom security policies
├── .github/
│   ├── workflows/              # GitHub Actions workflows
│   └── actions/                # Composite actions
├── .claude/references/          # AI development guides
└── CLAUDE.md                   # Main development guide
```

## 📚 Critical Documentation Map

### Primary References
1. **CLAUDE.md** - Master reference document listing all guidelines and documentation
2. **docs/TERRAFORM_BEST_PRACTICES_GUIDE.md** - Module development standards, naming conventions, security practices
3. **docs/TERRAFORM_NEW_MODULE_GUIDE.md** - Step-by-step guide for creating new modules
4. **docs/TERRAFORM_TESTING_GUIDE.md** - Testing pyramid, Terratest patterns, native tests
5. **docs/WORKFLOWS.md** - Actual GitHub Actions implementation in this repo
6. **docs/SECURITY.md** - Security policies, compliance (SOC 2, ISO 27001, GDPR, PCI DSS)

### Workflow & Automation References
- **.claude/references/terraform-github-actions.md** - General GitHub Actions patterns
- **.claude/references/github-actions-monorepo-guidelines.md** - Monorepo architecture patterns
- **.claude/references/semantic-release-guide.md** - Automated versioning setup
- **.claude/references/documentation-guide.md** - terraform-docs configuration

### MCP Tools References (if using AI tools)
- **.claude/references/mcp-tools-usage.md** - Context7, Gemini Zen, TaskMaster usage
- **.claude/references/taskmaster-commands.md** - Task management commands
- **.claude/references/workflow-integration.md** - Tool coordination patterns

## 🛠️ Common Commands & Workflows

### Module Development
```bash
# Testing (run from module directory)
make test                        # Run all tests
make test-unit                   # Run unit tests only
make test-integration            # Run integration tests

# Documentation
terraform-docs markdown . > README.md  # Generate docs (usually automated)
terraform fmt -recursive .             # Format code
terraform validate                     # Validate configuration

# Pre-commit hooks
pre-commit install                     # Install hooks
pre-commit run --all-files            # Run all checks
```

### GitHub Project Management
```bash
gh project list --owner PatrykIti     # List projects
gh project item-list 2                # List items in project #2
gh issue create --project 2           # Create issue in project
```

### Git Workflow
```bash
# Branch naming
feature/module-name-description       # New features
fix/module-name-issue                # Bug fixes
docs/update-module-documentation     # Documentation updates

# Commit messages (conventional commits for semantic-release)
feat(storage-account): add encryption support
fix(virtual-network): correct subnet calculation
docs(storage-account): update examples
test(virtual-network): add integration tests
```

## 📋 Module Structure Template

Every Terraform module MUST follow this structure:
```
modules/azurerm_<service_name>/
├── main.tf                      # Main resource definitions
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── versions.tf                  # Provider requirements
├── README.md                    # Auto-generated documentation
├── .terraform-docs.yml          # Documentation config
├── Makefile                     # Test commands
├── examples/
│   ├── basic/                   # Minimal example
│   ├── complete/                # All features example
│   └── secure/                  # Security-focused example
└── tests/
    ├── unit/                    # Native Terraform tests
    └── integration/             # Terratest Go tests
```

## 🔄 CI/CD Workflows

### Primary Workflows
1. **module-ci.yml** - Validates, tests, and scans modules on PR
2. **module-release.yml** - Semantic versioning and GitHub releases
3. **pr-validation.yml** - Comprehensive PR checks
4. **release-changed-modules.yml** - Releases only modified modules

### Workflow Triggers
- Pull Requests: Validation, testing, security scanning
- Push to main: Automatic versioning and release
- Manual: Documentation updates, maintenance tasks

## 🔐 Security & Compliance

### Security Principles
- **Defense in Depth**: Multiple security layers
- **Least Privilege**: Minimal required permissions
- **Zero Trust**: Verify everything, trust nothing
- **Encryption by Default**: All data encrypted at rest and in transit

### Compliance Standards
- SOC 2 Type II
- ISO 27001
- GDPR
- PCI DSS

### Security Requirements for Modules
- Private endpoints preferred over public
- Managed identities over keys
- Network restrictions by default
- Audit logging enabled
- Encryption with customer-managed keys support

## 🚀 Development Best Practices

### Module Development Rules
1. **Naming Convention**: `azurerm_<service>_<resource>` (e.g., `azurerm_storage_account`)
2. **Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)
3. **Documentation**: Auto-generated with terraform-docs
4. **Testing**: Unit tests required, integration tests for complex modules
5. **Examples**: Minimum three examples (basic, complete, secure)
6. **Security**: Security-by-default configuration

### Code Quality Standards
- Resource naming: Use `var.naming_prefix` and `var.naming_suffix`
- Tags: Always include `var.tags` with defaults
- Outputs: Expose all resource IDs and important attributes
- Variables: Use `validation` blocks for complex inputs
- Providers: Pin to specific versions in `versions.tf`

### Testing Requirements
1. **Static Analysis**: `terraform fmt`, `terraform validate`, `tflint`
2. **Unit Tests**: Native Terraform tests with mocks
3. **Integration Tests**: Terratest for real resource deployment
4. **Security Scanning**: Checkov, tfsec, Trivy
5. **Cost Estimation**: Infracost for PR comments

## 📝 Quick Reference Checklists

### New Module Checklist
- [ ] Follow module structure template
- [ ] Implement all required files
- [ ] Create three examples minimum
- [ ] Write comprehensive tests
- [ ] Configure .terraform-docs.yml
- [ ] Add module to CI/CD matrix
- [ ] Update root README.md
- [ ] Follow security-by-default

### PR Checklist
- [ ] Conventional commit messages
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Security scan clean
- [ ] Examples working
- [ ] CHANGELOG entry (auto-generated)

## 🔍 Troubleshooting

### Common Issues
1. **Module not detected by CI**: Check `.github/workflows/module-ci.yml` matrix
2. **Documentation not updating**: Verify terraform-docs markers in README
3. **Release not triggering**: Ensure conventional commit format
4. **Tests failing**: Check Azure credentials and permissions
5. **Security scan failures**: Review security policies in `security-policies/`

### Getting Help
- Check CLAUDE.md for comprehensive references
- Review relevant documentation in docs/
- Use GitHub Project for issue tracking
- Follow troubleshooting guides in specific documentation

## 🎯 Key Principles to Remember

1. **Automation First**: If it can be automated, it should be
2. **Security by Default**: Secure configurations out of the box
3. **Documentation as Code**: Auto-generated from source
4. **Test Everything**: No code without tests
5. **Modular Design**: Small, focused, reusable modules
6. **Version Independence**: Each module versions separately
7. **Compliance Ready**: Meet enterprise standards

## 📖 Extended Documentation Reference

### When to Consult CLAUDE.md

This repo.md file contains the most frequently needed information for daily development tasks. However, for more detailed or specialized topics not covered here, **ALWAYS consult CLAUDE.md**, which contains:

1. **Complete documentation index** with mandatory review conditions
2. **Detailed MCP tools usage rules** and TaskMaster integration
3. **Multi-agent workflow patterns** and coordination
4. **Advanced workflow scenarios** and edge cases
5. **Specific tool configuration details** and troubleshooting

### Full Documentation Hierarchy

```
repo.md (this file)           # Quick reference, common tasks, essential info
    └── CLAUDE.md             # Complete reference index, all documentation links
        └── docs/*.md         # Detailed guides for specific topics
        └── .claude/references/*.md  # Specialized workflow and tool guides
```

### Key Files for Deep Dives

- **CLAUDE.md** - Master index of ALL documentation with "MANDATORY REVIEW" conditions
- **PROJECT.md** - Complete project specification (if exists)
- **docs/TERRAFORM_BEST_PRACTICES_GUIDE.md** - Comprehensive Terraform standards
- **docs/TERRAFORM_NEW_MODULE_GUIDE.md** - Detailed module creation process
- **docs/WORKFLOWS.md** - Complete GitHub Actions implementation details
- **.claude/references/** - Specialized guides for tools and workflows

### When in Doubt

If you encounter a scenario not covered in this repo.md:
1. First check **CLAUDE.md** for relevant documentation references
2. Look for "MANDATORY REVIEW" conditions that match your task
3. Consult the specific documentation files referenced
4. Follow the detailed guidelines provided in those documents

Remember: This repo.md is a quick reference guide. CLAUDE.md is the authoritative source for all documentation references and mandatory guidelines.

---
*This file is automatically loaded for every task in this repository. Keep it updated with essential information that aids in development and maintenance.*