# Filename: 002-2025-12-23-module-scaffold-fix.md

# 002. Generator scaffoldu – naprawa i zgodnosc z AKS

**Date:** 2025-12-23  
**Type:** Fix / Enhancement  
**Scope:** `scripts/create-new-module.sh`, `scripts/templates/`, `docs/*`  
**Tasks:** TASK-003

---

## Key Changes

- **Scaffolding CLI:** added `--examples=<csv>` and `--with-private-endpoint`, with strict validation and defaults (`basic,complete,secure`).
- **Template safety:** fixed heredoc placement and ensured `module.json` is created deterministically (no shell code injected into `.tf`).
- **Metadata cleanup:** removed legacy `.github/module-config.yml` usage; `module.json` is the only release metadata.
- **Test scaffolding alignment:** templates now use `MODULE_PASCAL_PLACEHOLDER`, align fixtures with AKS (`basic/complete/secure/network/negative`), and skip private-endpoint tests if fixture is missing.
- **Missing test files added:** `run_tests_parallel.sh`, `run_tests_sequential.sh`, `test_env.sh`, `go.sum`, and `unit/*.tftest.hcl`.
- **Docs & validation updates:** updated module structure guide, CI/CD notes, workflow instructions, prompt docs, and `scripts/validate-structure.sh`.
