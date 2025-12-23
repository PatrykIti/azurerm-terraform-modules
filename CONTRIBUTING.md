# Contributing to Azure Terraform Modules

Thank you for your interest in contributing to our Azure Terraform Modules repository! This guide will help you get started with contributing to any module in this repository.

## 🏗️ Repository Structure

```
azurerm-terraform-modules/
├── modules/                        # Individual Terraform modules
│   └── <module_name>/
│       ├── module.json            # Module metadata and configuration
│       ├── main.tf                # Main resource definitions
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       ├── versions.tf            # Provider requirements
│       ├── README.md              # Auto-generated documentation
│       ├── CONTRIBUTING.md        # Module-specific guidelines
│       ├── examples/              # Usage examples
│       └── tests/                 # Terratest files
├── .github/
│   ├── workflows/                 # Repository-wide workflows
│   │   ├── module-ci.yml         # Main CI dispatcher
│   │   ├── module-release.yml    # Release workflow
│   │   ├── module-docs.yml       # Documentation automation
│   │   ├── pr-validation.yml     # PR quality checks
│   │   └── repo-maintenance.yml  # Scheduled maintenance
│   └── actions/                   # Shared composite actions
│       ├── detect-modules/        # Module detection logic
│       └── terraform-setup/       # Terraform environment setup
├── docs/                          # Global documentation
│   ├── WORKFLOWS.md              # GitHub Actions documentation
│   ├── TERRAFORM_BEST_PRACTICES_GUIDE.md
│   └── TERRAFORM_TESTING_GUIDE.md
└── .claude/                       # Development guidelines
    └── references/                # Workflow patterns and guidelines
```

## 🚀 Getting Started

### Prerequisites

- Terraform >= 1.3.0
- Azure CLI configured with appropriate permissions
- Go >= 1.21 (for Terratest)
- Git
- GitHub account

### Required Tools

```bash
# macOS (using Homebrew)
brew install terraform terraform-docs tflint checkov

# Linux/Windows
# See individual tool documentation for installation
```

## 📋 Development Workflow

### 1. Fork and Clone

```bash
# Fork the repository on GitHub first
git clone https://github.com/YOUR_USERNAME/azurerm-terraform-modules.git
cd azurerm-terraform-modules
```

### 2. Create a Feature Branch

Follow our branch naming convention:
```bash
git checkout -b feature/module-name-description
# Examples:
# feature/storage-account-lifecycle-rules
# fix/virtual-network-subnet-delegation
# docs/key-vault-examples
```

### 3. Choose Your Contribution Type

#### 🆕 Adding a New Module

1. Create module directory: `modules/azurerm_<resource_name>/`
2. Copy the structure from an existing module as a template
3. Create module configuration: `module.json` with metadata
4. The workflows will automatically detect your module based on:
   - The presence of the module directory in `modules/`
   - The `module.json` file for release configuration
   - Standard Terraform module structure

See [docs/WORKFLOWS.md](docs/WORKFLOWS.md#adding-new-modules) for detailed instructions.

#### 🔧 Modifying Existing Modules

1. Check module-specific CONTRIBUTING.md (e.g., `modules/azurerm_storage_account/CONTRIBUTING.md`)
2. Follow module-specific patterns and conventions
3. Update tests and examples

#### 📚 Documentation Updates

1. Update relevant README.md files
2. Regenerate terraform-docs using module tooling (see checklist)
3. Update examples if needed

## 🎯 Coding Standards

### Terraform Best Practices

1. **Resource Naming**: Follow the pattern established in CLAUDE.md
   ```hcl
   resource "azurerm_storage_account" "storage_account" {
     # NOT "this" or "main" or "storage_account"
   }
   ```

2. **Variable Structure**: Use object types with secure defaults
   ```hcl
   variable "security_settings" {
     type = object({
       enable_https_traffic_only = optional(bool, true)
       min_tls_version          = optional(string, "TLS1_2")
     })
     default = {}
   }
   ```

3. **Iteration**: Use descriptive names in loops
   ```hcl
   for container in var.containers : # Good
   for c in var.containers :         # Bad
   ```

### Security First

- Always use secure defaults
- Never store secrets in code
- Enable encryption by default
- Use latest TLS versions
- Document security implications

## ✅ Pre-Submission Checklist

Before submitting your PR, ensure:

- [ ] All Terraform files are formatted: `terraform fmt -recursive`
- [ ] Module validates: `terraform init && terraform validate`
- [ ] TFLint passes: `tflint --init && tflint`
- [ ] Documentation is updated (module dir: `make docs` or `./generate-docs.sh`; repo root: `./scripts/update-module-docs.sh <module_name>`)
- [ ] Examples work correctly
- [ ] Tests pass (if applicable)
- [ ] CHANGELOG.md is updated (for feature changes)

## 🔄 Pull Request Process

### PR Title Format

Use conventional commits:
- `feat(storage-account): add lifecycle management support`
- `fix(virtual-network): correct subnet CIDR validation`
- `docs(key-vault): update access policy examples`
- `chore(deps): update azurerm provider to 4.36.0`
- `ci(workflows): update module detection logic`
- `test(storage-account): add integration tests`

### Automated CI/CD

When you create a PR, the following workflows will run automatically:

1. **PR Validation** (`pr-validation.yml`):
   - Validates PR title and commit messages
   - Checks Terraform formatting
   - Runs TFLint analysis
   - Verifies documentation is up-to-date
   - Quick security scan

2. **Module CI** (`module-ci.yml`):
   - Detects changed modules
   - Runs module-specific validation
   - Executes tests (if configured)
   - Performs security scanning
   - Posts summary comment on PR

### Review Process

1. **Automated Checks**: All CI/CD checks must pass
2. **Code Review**: At least one maintainer approval required
3. **Testing**: Evidence of testing required (automated or manual)
4. **Documentation**: Must be complete and accurate
5. **Security**: No security vulnerabilities introduced

## 🏷️ Release Process

### Module Versioning

Each module is versioned independently:
- **Tag Format**: `<module_name>/v<MAJOR>.<MINOR>.<PATCH>`
- **Example**: `azurerm_storage_account/v1.0.0`

### Version Guidelines

- **Major**: Breaking changes (incompatible API changes)
- **Minor**: New features (backwards compatible)
- **Patch**: Bug fixes and minor improvements

### Release Workflow

Releases are managed through the `module-release.yml` workflow:

1. Go to Actions → Module Release
2. Click "Run workflow"
3. Select:
   - Module to release
   - Version number
   - Release notes (optional)
4. Workflow will:
   - Validate version format
   - Run final validation
   - Update module-config.yml
   - Create git tag
   - Create GitHub release

## 🧪 Testing

### Local Testing

1. Navigate to module's example directory
2. Create `terraform.tfvars` with test values
3. Run standard Terraform workflow:
   ```bash
   terraform init
   terraform plan
   terraform apply
   terraform destroy
   ```

### Automated Testing

For modules with Terratest:
```bash
cd modules/<module_name>/tests
go test -v -timeout 30m
```

## 📞 Getting Help

### Documentation
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Azure Terraform Documentation](https://docs.microsoft.com/azure/developer/terraform/)
- [Module Development Guide](docs/TERRAFORM_BEST_PRACTICES_GUIDE.md)

### Communication
- **Issues**: For bugs and feature requests
- **Discussions**: For questions and ideas
- **PR Comments**: For code-specific discussions

## 🤝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Acknowledge contributions

## 🎉 Recognition

All contributors will be recognized in our releases and documentation. Thank you for helping improve our Terraform modules!

---

For module-specific contribution guidelines, see the CONTRIBUTING.md file within each module directory.
