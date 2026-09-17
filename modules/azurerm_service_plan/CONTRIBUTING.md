# Contributing to azurerm_service_plan Module

Thank you for your interest in contributing to this Terraform module. This document provides module-specific contribution guidance.

## How to Contribute

### Reporting Issues

1. Check whether the issue already exists in GitHub
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected and actual behavior
   - Terraform and provider versions
   - Relevant configuration examples

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make changes following repository guides
4. Write or update tests
5. Update documentation
6. Commit using conventional commits: `feat(service-plan): add new feature`
7. Push and open a pull request

## Development Guidelines

### Code Standards

1. Follow [Terraform Best Practices](../../docs/TERRAFORM_BEST_PRACTICES_GUIDE.md)
2. Keep the module atomic around `azurerm_service_plan`
3. Add descriptions to all variables and outputs
4. Prefer structured object inputs and explicit validation rules
5. Keep diagnostic settings inline in this module

### Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) with module scope:

```bash
feat(service-plan): add elastic premium example
fix(service-plan): correct ASE isolated sku validation
docs(service-plan): update import documentation
```

### Testing

1. All changes must include test coverage where applicable
2. Run tests locally before submitting:
   ```bash
   cd tests
   make test
   ```
3. Ensure unit tests and example/fixture validation remain aligned

### Documentation

1. Update README.md if inputs, outputs, or examples change
2. Update examples if behavior changes
3. Keep `docs/README.md` and `docs/IMPORT.md` accurate
4. Regenerate docs when changing Terraform interfaces

## Pull Request Checklist

- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] Conventional commit messages used
- [ ] No secrets or sensitive values committed
- [ ] Examples remain runnable
- [ ] Breaking changes documented
