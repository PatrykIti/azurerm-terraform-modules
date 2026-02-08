# TASK-049: Private Endpoint Variables Hardening and Validation Alignment

**Priority:** High  
**Category:** Compliance / Audit Remediation  
**Estimated Effort:** Medium  
**Module:** `modules/azurerm_private_endpoint`  
**Status:** ✅ Done (2026-02-08)

---

## Overview

Harden `variables.tf` validation model for `azurerm_private_endpoint` to enforce input correctness earlier and align with checklist expectations.

## Current Gaps

1. `subnet_id` only checks non-empty string; Azure resource ID format is not validated.
2. `ip_configurations.private_ip_address` lacks IP format validation.
3. Optional string fields can still accept whitespace-only values in some paths.
4. Private DNS zone ID lists are validated for pattern but not uniqueness/non-empty trimming.

## Scope

### In scope

- `modules/azurerm_private_endpoint/variables.tf`
- unit tests covering variable validation
- docs reflecting updated validation behavior

### Out of scope

- API redesign to grouped top-level objects (tracked as potential follow-up if needed).

## Docs to Update

### In-module

- `modules/azurerm_private_endpoint/README.md`
- `modules/azurerm_private_endpoint/docs/README.md` (if validation examples are documented)

### Outside module

- `docs/_TASKS/README.md`

## Acceptance Criteria

1. `subnet_id` must match Azure subnet resource ID format.
2. `ip_configurations.private_ip_address` must validate as a valid IP address string.
3. Optional string fields used in connection/IP config/DNS group paths reject whitespace-only values when set.
4. `private_dns_zone_ids` validation includes non-empty values and uniqueness.
5. Unit tests cover newly added validation failures.

## Implementation Checklist

- [x] Add subnet resource ID regex validation for `subnet_id`.
- [x] Add IP format validation for `ip_configurations.private_ip_address`.
- [x] Tighten optional string validations (`custom_network_interface_name`, connection names/fields, DNS group IDs).
- [x] Add uniqueness + trim checks for `private_dns_zone_ids`.
- [x] Extend unit tests for new negative validation paths.
- [x] Regenerate docs and run `terraform validate` + `terraform test -test-directory=tests/unit`.
