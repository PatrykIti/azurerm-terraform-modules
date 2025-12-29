# Filename: 050-2025-12-29-makefile-tests-path-portability.md

# 050. Makefile tests path portability

**Date:** 2025-12-29  
**Type:** Fix / Maintenance  
**Scope:** `modules/*/Makefile`  
**Tasks:** —

---

## Key Changes

- Replaced hardcoded `tests` paths with Makefile-relative `TESTS_DIR` in module targets.
- Added `MAKEFILE_DIR`/`TESTS_DIR` variables to keep test invocations portable across working directories.
