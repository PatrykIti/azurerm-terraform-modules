# Filename: 099-2026-02-15-ado-release-tag-normalization-task-closure.md

# 099. Azure DevOps release tag normalization task closure

**Date:** 2026-02-15  
**Type:** Maintenance / Documentation  
**Scope:** `README.md`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-039

---

## Key Changes

- Closed `TASK-ADO-039` from board/documentation perspective to unblock PR/release flow.
- Normalized root `README.md` references for 7 affected Azure DevOps modules from legacy non-`v` concrete tags to `v`-prefix tracking:
  - badges now use filters `ADOPIv*`, `ADOSEv*`, `ADOSHv*`, `ADOTv*`, `ADOVGv*`, `ADOWIv*`, `ADOWKv*`,
  - module table versions now reference `*v*` convention and release page links.
- Updated task board status/counters and moved `TASK-ADO-039` to **Done**.
- Preserved traceability note that release workflow execution is performed by maintainer in release flow.

## Evidence Snapshot

- Current tag state before new release run: legacy tags only (`ADOPI1.0.0`, `ADOSE1.0.0`, `ADOSH1.0.0`, `ADOT1.0.0`, `ADOVG1.0.0`, `ADOWI1.0.0`, `ADOWK1.0.0`).
- Module tag prefixes in `module.json` remain normalized to `...v` and are ready for release workflow publication.
