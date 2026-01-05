# 5. Module Documentation

Clear, comprehensive, and consistent documentation is crucial for making modules easy to understand, use, and contribute to. Each module MUST include the following documentation files.

## `README.md`

The `README.md` is the front page of the module. It should provide all the essential information a user needs to get started. The majority of this file is generated and updated automatically by `terraform-docs` using the `.terraform-docs.yml` configuration.

**How to regenerate:**
- From the module directory: `make docs` or `./generate-docs.sh`
- From the repository root (CI/release-safe): `./scripts/update-module-docs.sh <module_name>`

**Required Sections:**
- **Header**: A description of the module's purpose, pulled from `main.tf`.
- **Version marker**: `<!-- BEGIN_VERSION -->` / `<!-- END_VERSION -->` for automation updates.
- **Usage**: A simple, copy-pasteable usage example.
- **Examples list**: `<!-- BEGIN_EXAMPLES -->` / `<!-- END_EXAMPLES -->` markers for automation updates.
- **Module Documentation**: Static section linking to `docs/README.md` (if present) and `docs/IMPORT.md`.
- **Inputs/Outputs/Requirements/Providers/Resources**: Auto-generated inside `<!-- BEGIN_TF_DOCS -->`.
- **Notes**: Optional section for module-specific rules (for example, policy keying rules or provider-required defaults).

---

## `docs/README.md`

This file is optional but recommended for complex modules (Azure DevOps modules use it). Use it for guidance that does not belong in the auto-generated README, such as design notes, operational guidance, or additional usage patterns.

**Recommended Sections (Azure DevOps pattern):**
- **Overview**
- **Managed Resources**
- **Usage Notes**
- **Inputs (Grouped)**
- **Outputs (Highlights)**
- **Import Existing <Resource>**
- **Troubleshooting**
- **Related Docs**

---

## `docs/IMPORT.md`

This file documents how to import existing resources into the module using Terraform import blocks. The AKS module is the reference format, but other resources may require variations that must be documented.

**Required Sections:**
- **Prerequisites**: Terraform version, provider version, and required access.
- **Minimal module-only configuration**: Copy/pasteable module block.
- **Import blocks**: Exact resource addressing for the module outputs.
- **Verification**: `plan`/`state` checks and clean-up guidance.
- **Common errors**: Typical drift causes and fixes.
- **ID collection**: Provide provider-appropriate CLI commands (Azure CLI or Azure DevOps CLI) to fetch IDs used in import blocks.

**Source references**:
- Use the module `tag_prefix` from `module.json` when setting `source = "...?ref=<TAG_PREFIX><version>"`.
- Do **not** add extra `v` unless it is part of the `tag_prefix` (e.g., `AKSv`).

---

## `CONTRIBUTING.md`

This file provides guidelines for developers who want to contribute to the module. It should set expectations for code standards, commit messages, testing, and the pull request process.

**Template (`CONTRIBUTING.md`):**
```markdown
# Contributing to <MODULE_TITLE> Module

Thank you for your interest in contributing!

## How to Contribute

- Report issues with clear descriptions.
- Submit changes via pull requests from a forked repository.

## Development Guidelines

- Follow the main [Terraform Best Practices Guide](../../docs/TERRAFORM_BEST_PRACTICES_GUIDE.md).
- Use conventional commits with the module scope: `feat(<commit_scope>): description`.
- All changes must be accompanied by tests. Run `make test` locally before submitting.
- Update documentation by running `make docs`.

## Pull Request Process

- Ensure all tests and checks are passing.
- Provide a clear description of the changes.
- Address reviewer feedback promptly.
```

---

## `SECURITY.md`

This file is dedicated to the security aspects of the module. It is a critical document for users who need to understand the security implications of using the module.

**Required Sections:**
- **Overview**: A summary of the module's security posture.
- **Security Features**: Detail specific security controls implemented (e.g., encryption, network rules, private endpoints, identity management).
- **Secure Configuration Example**: Provide a code example of the module configured for maximum security.
- **Security Hardening Checklist**: A list of items for users to check before deploying to production.
- **Common Security Mistakes to Avoid**: Highlight common misconfigurations that could lead to security vulnerabilities.
- **Compliance Mapping**: (Optional) Map the module's features to compliance controls like SOC 2 or ISO 27001.

---

## `VERSIONING.md`

This document explains how the module is versioned. Since our repository uses `semantic-release` with a custom tag format, this file is important for clarity.

**Required Sections:**
- **Version Format**: Explain the module's tag format (e.g., `AKSv{major}.{minor}.{patch}`).
- **Automated Version Determination**: Describe how commit types (`feat`, `fix`, `BREAKING CHANGE`) translate into version bumps.
- **Automated Release Process**: Briefly outline the steps that happen when a PR is merged to `main`.
- **How to Use Module Versions**: Show users how to reference a specific module version in their Terraform code using the `ref` attribute.
- **Best Practices for Commits**: Emphasize the importance of using the correct commit scope.
```

This structured approach to documentation ensures that users and contributors have all the information they need in a predictable and accessible format.
