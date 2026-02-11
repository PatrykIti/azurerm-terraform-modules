# Contributing to azurerm_bastion_host Module

Thank you for your interest in contributing to this Terraform module! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct, which promotes a respectful and inclusive environment for all contributors.

## How to Contribute

### Reporting Issues

1. Check if the issue already exists in the GitHub issues
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce (if applicable)
   - Expected vs actual behavior
   - Terraform and provider versions
   - Relevant configuration examples

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following our guidelines
4. Write or update tests as needed
5. Update documentation
6. Commit using conventional commits: `feat(bastion-host): add new feature`
7. Push to your fork and submit a pull request

## Development Guidelines

### Code Standards

1. Follow [Terraform Best Practices](../../docs/TERRAFORM_BEST_PRACTICES_GUIDE.md)
2. Use meaningful variable and resource names
3. Add descriptions to all variables and outputs
4. Include validation rules where appropriate
5. Follow the existing code style and patterns

### Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) with module scope:

```bash
feat(bastion-host): add support for new feature
fix(bastion-host): correct validation logic
docs(bastion-host): update README examples
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code restructuring
- `perf`: Performance improvements
- `test`: Test additions or modifications
- `chore`: Maintenance tasks

### Testing

1. All changes must include tests
2. Run tests locally before submitting PR:
   ```bash
   cd tests
   make test
   ```
3. Ensure all tests pass
4. Add new test cases for new functionality

### Documentation

1. Update README.md if adding new features
2. Update examples if behavior changes
3. Keep CHANGELOG.md entries during development (will be automated on release)
4. Update variable descriptions for clarity

## Pull Request Process

1. **PR Title**: Use conventional commit format
2. **Description**: Clearly describe what changes you made and why
3. **Testing**: Confirm all tests pass
4. **Documentation**: Ensure docs are updated
5. **Review**: Address reviewer feedback promptly

### PR Checklist

- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] Conventional commit messages used
- [ ] No sensitive data in code
- [ ] Examples work correctly
- [ ] Breaking changes documented

## Release Process

Releases are automated using semantic-release:
1. Merge PR to main branch
2. Automated release based on commit types
3. Version determined by conventional commits
4. CHANGELOG updated automatically

## Getting Help

- Review existing documentation
- Check GitHub issues and discussions
- Ask questions in PR comments
- Contact maintainers if needed

## Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes when applicable
- Project documentation

Thank you for contributing to make this module better!
