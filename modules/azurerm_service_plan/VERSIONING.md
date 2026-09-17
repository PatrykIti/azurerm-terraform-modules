# Module Versioning Guide

This module uses **semantic-release** for fully automated version management based on conventional commits.

## Version Format

This module follows a custom semantic versioning format:

```
ASPv{major}.{minor}.{patch}
```

Where:
- `ASP` = azurerm_service_plan module identifier
- `v` = version prefix
- `{major}.{minor}.{patch}` = semantic version numbers (automatically determined)

### Examples:
- `ASPv1.0.0` - First stable release
- `ASPv1.1.0` - Minor feature addition (from `feat:` commits)
- `ASPv1.0.1` - Bug fix (from `fix:` commits)
- `ASPv2.0.0` - Breaking change (from `BREAKING CHANGE:` commits)

## Automated Version Determination

Version bumps are **automatically determined** by semantic-release based on commit messages:

### Major Version (Breaking Changes)
Triggered by:
- Commits with `BREAKING CHANGE:` in the footer
- Commits with `!` after the type (for example `feat!:` or `fix!:`)

```bash
feat(service-plan)!: change default scaling behavior

BREAKING CHANGE: worker_count handling has changed for premium plans.
```

### Minor Version (New Features)
Triggered by:
- Commits with type `feat:`

```bash
feat(service-plan): add Elastic Premium scaling support
feat(service-plan): add ASE-backed isolated plan support
```

### Patch Version (Bug Fixes)
Triggered by:
- Commits with types: `fix:`, `perf:`, `revert:`, `refactor:`, `docs:`

```bash
fix(service-plan): correct zone balancing validation
perf(service-plan): optimize diagnostic settings rendering
docs(service-plan): update README examples
```

### No Version (Ignored)
These commits do not trigger releases:
- `chore:`, `style:`, `test:`, `build:`, `ci:`

```bash
chore(service-plan): update example wording
test(service-plan): add unit tests for sku validation
```

## Automated Release Process

### Prerequisites
- All commits follow [Conventional Commits](https://www.conventionalcommits.org/) format
- Commits include module scope: `feat(service-plan): description`
- PR is merged to main branch

### Release Workflow

1. **Merge PR to main** with conventional commits
2. **Trigger Release Workflow** (manual via GitHub Actions)
3. **Semantic-release automatically**:
   - Analyzes commits since last release
   - Determines version bump type
   - Updates CHANGELOG.md
   - Updates module version in configs
   - Updates examples to use new version tag
   - Creates git tag (for example `ASPv1.2.0`)
   - Publishes GitHub release
   - Commits all changes

## Best Practices for Commits

### Always Include Module Scope
```bash
# Correct
feat(service-plan): add workflow standard sku example
fix(service-plan): validate isolated sku for ASE

# Wrong
feat: add workflow standard sku example
fix: validate isolated sku for ASE
```

## Release Automation Benefits

1. Zero manual version management
2. Consistent changelog generation
3. Module-local version history
4. Safe propagation of example source tags
