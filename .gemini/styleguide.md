# Gemini Code Assist Styleguide: Azure Terraform Modules

## 1. General Principles

- **Be an Enabler**: Your primary goal is to help developers improve their contributions. Frame feedback constructively. When you find an issue, explain *why* it's an issue and suggest a correct implementation.
- **Precision is Key**: Reference specific file names and line numbers. Provide corrected code snippets for direct application.
- **Focus on the Diff**: Confine your review to the changes introduced in the pull request. Do not comment on pre-existing code unless the new changes interact with it in a problematic way.
- **Acknowledge Trade-offs**: If a suggestion involves a trade-off (e.g., cost vs. security), state it clearly.

## 2. Core Review Instructions

These rules govern your behavior as a reviewer.

- **Scope Adherence**: The changes in a PR should align with the commit messages and PR description. Flag any apparent scope creep. For example, if a PR is titled `feat(storage-account): add new feature`, changes to the `virtual-network` module should be questioned.
- **File Modifications**:
    - **Prefer Editing**: Question the creation of new files if the logic could be cleanly integrated into existing standard files (`main.tf`, `variables.tf`, `outputs.tf`).
    - **No Unsolicited Documentation**: Do not suggest creating new documentation files (`.md`) unless they are part of the standard module structure (e.g., `README.md`) or the PR's goal is to add documentation.

## 3. Repository Documentation Structure

### 3.1. Key Documentation Files
Before reviewing, familiarize yourself with these repository documents:

- **`/docs/WORKFLOWS.md`**: Describes all GitHub Actions workflows, CI/CD processes, and how to add new modules
- **`/docs/TERRAFORM_TESTING_GUIDE.md`**: Testing strategies, Terratest examples, and test requirements
- **`/docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`**: Module development standards and conventions
- **`/docs/SECURITY.md`**: Security guidelines and vulnerability reporting
- **`/CONTRIBUTING.md`**: General contribution guidelines
- **`/modules/<module-name>/CONTRIBUTING.md`**: Module-specific contribution guidelines

### 3.2. How to Use Documentation in Reviews

- **Reference Specific Guidelines**: When suggesting changes, cite the relevant section from these documents. Example: "Per TERRAFORM_BEST_PRACTICES_GUIDE.md section 4.2, variables should use snake_case naming."
- **Check for Compliance**: Verify that changes follow the patterns and practices outlined in these guides
- **Don't Duplicate**: If a guideline exists in the documentation, reference it rather than explaining it from scratch

## 4. Terraform Module Standards

All modules in this repository must adhere to a consistent structure and set of conventions.

### 4.1. Module Structure
A module directory (`modules/<module-name>/`) must contain:
- `main.tf`: Core resource definitions
- `variables.tf`: All input variables
- `outputs.tf`: All outputs from the module
- `versions.tf`: Provider version constraints
- `README.md`: Module documentation with injected sections
- `.releaserc.js`: Semantic release configuration
- `.terraform-docs.yml`: Documentation generation config
- `.github/module-config.yml`: Module metadata

Required subdirectories:
- `examples/`: At minimum `basic/`, `complete/`, and `secure/` examples
- `tests/`: Terratest files (`*_test.go`)
- `docs/`: Additional module documentation

### 4.2. Provider and Backend Configuration
- **No `provider` blocks**: Modules must not contain `provider` blocks. Provider configuration is the responsibility of the root/calling module.
- **No backend configuration**: Modules must not contain backend configuration in `terraform` blocks.
- **Version constraints only**: The `versions.tf` should only contain `required_version` and `required_providers` constraints.

## 5. Code Quality and Conventions

### 5.1. Formatting
- **`terraform fmt`**: All `.tf` files must be formatted. If you detect unformatted code, flag it and suggest running `terraform fmt -recursive`.

### 5.2. Naming and Style
- **Resource Naming**: Use descriptive names. For single resources, `main` or the resource type is acceptable (e.g., `storage_account`).
- **`for_each` over `count`**: For creating multiple instances of a resource based on a collection, `for_each` is strongly preferred over `count`.
- **Locals**: Use `locals` to simplify complex expressions and improve readability. Local variable names should use `snake_case`.
- **Consistent Prefixes**: Resources should follow the module's naming pattern (check existing resources).

### 5.3. Variables (`variables.tf`)
- **Type and Description**: Every variable must have an explicit `type` and a meaningful `description`.
- **Avoid `any` type**: Use specific types like `string`, `number`, `list(string)`, or `object({...})`.
- **Secure Defaults**: Security-related variables must default to the most secure option.
- **Nullable Pattern**: For required variables without logical defaults, use `default = null`.
- **Validation Rules**: Add `validation` blocks for variables with specific constraints.

### 5.4. Outputs (`outputs.tf`)
- **Description**: Every output must have a `description`.
- **Sensitive Data**: Mark outputs containing sensitive information with `sensitive = true`.
- **Consistent Naming**: Output names should follow the pattern: `<resource>_<attribute>` (e.g., `storage_account_id`).

## 6. Security by Default

Modules must be secure by default. Review for these patterns:

### 6.1. Storage Accounts
- `allow_nested_items_to_be_public = false`
- `shared_access_key_enabled = false` (unless explicitly needed)
- `min_tls_version = "TLS1_2"`
- `https_traffic_only_enabled = true`
- `public_network_access_enabled = false` (for production scenarios)

### 6.2. Network Security
- No overly permissive rules (`source_address_prefix = "*"` for sensitive ports)
- Private endpoints preferred over public access
- Network ACLs should default to `Deny`

### 6.3. Encryption
- `infrastructure_encryption_enabled = true` where supported
- Customer-managed keys (CMK) support should be available

### 6.4. General Security
- No hardcoded secrets or credentials
- No default passwords
- Audit logging enabled by default where applicable

## 7. Documentation Standards

### 7.1. README.md Structure
The README must contain these injected sections in order:
1. `<!-- BEGIN_VERSION -->` ... `<!-- END_VERSION -->`
2. `<!-- BEGIN_EXAMPLES -->` ... `<!-- END_EXAMPLES -->`
3. `<!-- BEGIN_TF_DOCS -->` ... `<!-- END_TF_DOCS -->`

### 7.2. Documentation Updates
- **Never suggest manual edits** between the marker sections
- **Correct command**: If docs are outdated, suggest: `cd modules/<module-name> && terraform-docs .`
- **Wrong command**: Never suggest `terraform-docs markdown table --output-file README.md` (this overwrites the entire file)

### 7.3. Version Updates
- Module versions follow pattern: `<PREFIX>v<SEMVER>` (e.g., `SAv1.0.0` for storage account)
- Version in README should match the latest Git tag for the module
- Semantic versioning rules apply based on change type

## 8. Testing Requirements

### 8.1. Test Coverage
- All modules must have tests in `tests/` directory
- Minimum test file: `<module>_test.go`
- Tests should cover basic, secure, and edge cases

### 8.2. Example Validation
- Examples must be self-contained and deployable
- Each example needs its own README.md explaining the use case
- Examples should reference the module using relative paths during development

## 9. Commit and PR Standards

### 9.1. Commit Messages
All commits must follow Conventional Commits:
- Format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- Scope: Module name (e.g., `storage-account`, `virtual-network`)
- Breaking changes: Include `BREAKING CHANGE:` in commit body

### 9.2. PR Guidelines
- PR title should follow same format as commit messages
- Changes should be scoped to a single module when possible
- Include examples of how to test the changes

## 10. CI/CD Integration

### 10.1. Workflow Awareness
The repository uses these workflows:
- `module-ci.yml`: Runs validate, test, and security scans
- `pr-validation.yml`: Checks formatting, linting, and documentation
- `module-release.yml`: Handles semantic versioning and releases

### 10.2. What to Check
- Changes should not break existing CI/CD workflows
- New modules need to be added to workflow filters
- Module-runner action handles all module-specific CI tasks

## 11. Common Issues to Flag

### 11.1. Anti-patterns
- Using `terraform-docs markdown table --output-file` (destroys README structure)
- Creating module-specific GitHub Actions (use module-runner instead)
- Hardcoding module versions in examples (use relative paths)
- Missing security defaults
- Incomplete examples

### 11.2. Quick Fixes
When you spot these issues, provide the exact fix:
- Outdated docs: `cd modules/<module> && terraform-docs .`
- Unformatted code: `terraform fmt -recursive modules/<module>`
- Missing example: Point to existing module examples as templates

## 12. Review Checklist

For each PR, verify:
- [ ] Commit messages follow conventional format
- [ ] Code is formatted with `terraform fmt`
- [ ] Variables have types and descriptions
- [ ] Security defaults are in place
- [ ] Documentation markers are preserved
- [ ] Examples are complete and follow patterns
- [ ] No hardcoded secrets or credentials
- [ ] Changes align with repository standards in `/docs/`

Remember: Your goal is to help maintain high-quality, secure, and consistent Terraform modules. Be helpful, be specific, and always provide actionable feedback with examples.