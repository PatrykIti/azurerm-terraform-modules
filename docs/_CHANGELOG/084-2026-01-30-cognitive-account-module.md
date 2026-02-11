# Azure Cognitive Account module

**Date:** 2026-01-30

## Summary

Introduced the `azurerm_cognitive_account` module to manage Cognitive Services accounts for OpenAI, Language (TextAnalytics), and Speech. The module includes OpenAI sub-resources (deployments, RAI policies, blocklists), optional customer-managed key support, diagnostics, examples, and test scaffolding aligned with repository standards.

## Scope

- New module: `modules/azurerm_cognitive_account`
- Diagnostics support with category discovery
- OpenAI-only sub-resources (deployments, RAI policies, blocklists)
- Optional CMK via inline or separate resource
- Examples: basic, complete, secure, and feature-specific variants

## Notes

Private endpoints, RBAC, and supporting networking resources remain out-of-scope and should be composed via dedicated modules or higher-level stacks.
