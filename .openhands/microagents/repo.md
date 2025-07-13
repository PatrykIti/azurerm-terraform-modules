# Azure Terraform Modules Repository

## Repository Overview

This repository contains a collection of production-ready Terraform modules for Microsoft Azure infrastructure deployment. It follows HashiCorp best practices and enterprise security standards to provide reusable, secure, and scalable infrastructure components for Azure cloud environments.

## Repository Structure

```
azurerm-terraform-modules/
├── modules/                     # Individual Terraform modules
│   └── azurerm_<resource>/     # Module for specific Azure resource
│       ├── main.tf             # Main resource definitions
│       ├── variables.tf        # Input variables
│       ├── outputs.tf          # Output values
│       ├── versions.tf         # Provider requirements
│       ├── .releaserc.js       # Semantic release configuration
│       ├── examples/           # Usage examples
│       ├── tests/              # Unit and integration tests
│       └── README.md           # Module documentation
├── docs/                       # Shared documentation
├── scripts/                    # Automation scripts
├── .github/                    # GitHub Actions workflows
│   ├── workflows/              # CI/CD pipelines
│   └── actions/                # Reusable composite actions
├── .claude/                    # AI development guidelines
│   └── references/             # Development reference docs
└── .taskmaster/                # TaskMaster configuration
```

## Key Documentation Files

- **PROJECT.md**: Complete project specification including goals, architecture, and roadmap
- **docs/TERRAFORM_BEST_PRACTICES_GUIDE.md**: Comprehensive guide for Terraform module development
- **docs/TERRAFORM_TESTING_GUIDE.md**: Testing strategies for Terraform modules
- **docs/WORKFLOWS.md**: Documentation of GitHub Actions workflow architecture
- **docs/SECURITY.md**: Security policies and compliance requirements
- **.claude/references/**: Contains various reference guides for development

## Module Structure

Each module follows a standardized structure:
- **Flat module design**: No nested modules for simplicity
- **Single responsibility**: Each module manages one Azure resource type
- **Composable**: Modules can be combined for complex architectures
- **Self-contained**: All module dependencies are explicit

## Release Process

The repository uses semantic-release for automated versioning and releases:

1. Each module has its own `.releaserc.js` configuration
2. Releases are triggered by conventional commit messages with specific scopes
3. The `release-changed-modules.yml` workflow detects which modules to release based on commit scopes
4. Multiple modules can be released at once using comma-separated scopes in commit messages
5. Releases are executed sequentially to avoid conflicts in root README.md updates
6. Each module has its own version tag prefix (e.g., `SAv1.0.0` for Storage Account)

## Workflow Commands

- **Module CI**: Automatically runs on PR or push to validate modules
- **Module Release**: Triggered by conventional commits to main branch
- **Documentation Generation**: Automated using terraform-docs

## Conventional Commits

The repository uses conventional commits for automated versioning:

- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- Scopes: Module names (e.g., storage-account, virtual-network)
- Multiple scopes: `feat(virtual-network,subnet,routes): add networking features`

## Current Modules

1. **Storage Account** (SAv1.0.0)
   - Comprehensive Azure Storage with enterprise features
   - Support for Data Lake Gen2, SFTP, private endpoints
   - Advanced lifecycle management and security policies

## Planned Modules

- **Virtual Network**: Advanced networking with security features
- **Key Vault**: Enterprise secret management
- **Application Gateway**: Layer 7 load balancing with WAF
- **SQL Database**: Managed database with security features
- **App Service**: Web application hosting platform

## Development Guidelines

1. Follow the Terraform best practices guide
2. Use conventional commits with appropriate module scopes
3. Create comprehensive examples for each module
4. Implement security best practices by default
5. Write tests for all module functionality
6. Document all module inputs, outputs, and usage