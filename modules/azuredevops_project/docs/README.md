# Azure DevOps Project Module Documentation

## Overview

This module manages the core Azure DevOps project and optional project-level
settings (pipeline settings, tags, dashboards). It is the base dependency for
most other Azure DevOps modules because it provides a stable `project_id`.

## Managed Resources

- `azuredevops_project`
- `azuredevops_project_pipeline_settings` (only when `pipeline_settings` is set)
- `azuredevops_project_tags` (only when `project_tags` is non-empty)
- `azuredevops_dashboard` (one per entry in `dashboards`)

## Usage Notes

- Project permissions are handled by `azuredevops_project_permissions`.
- Use `git::https://...//modules/azuredevops_project?ref=ADOPvX.Y.Z` for module source.
- Set `features = null` to leave feature flags unmanaged (avoid drift).
- Provide `pipeline_settings` only if Terraform should own those settings.
- Dashboard names must be unique; `refresh_interval` accepts 0 or 5.

## Inputs (Grouped)

### Core Project
- `name`, `description`, `visibility`, `version_control`, `work_item_template`

### Feature Flags
- `features` (map of `enabled`/`disabled` keyed by supported feature names)

### Pipeline Settings
- `pipeline_settings` (optional object; see `variables.tf` for fields)

### Tags
- `project_tags` (list of strings; empty list skips tag management)

### Dashboards
- `dashboards` (list of objects with `name`, optional `description`, optional `team_id`,
  optional `refresh_interval`)

## Outputs (Highlights)

- `project_id`, `project_name`, `project_visibility`
- `project_process_template_id`
- `project_pipeline_settings_id` (when managed)
- `project_tags` (when managed)
- `dashboard_ids`, `dashboard_owner_ids`

## Import Existing Project

See [IMPORT.md](./IMPORT.md) for step-by-step import using Terraform import blocks.

## Troubleshooting

- **Plan shows changes after import**: align `visibility`, `version_control`,
  `work_item_template`, and `features` with the existing project.
- **Feature flags drift**: set `features = null` or match current feature states.
- **Permission errors**: PAT must allow project administration and settings updates.

## Related Docs

- [README.md](../README.md) - module usage and inputs/outputs
- [IMPORT.md](./IMPORT.md) - import guide
- [VERSIONING.md](../VERSIONING.md) - tag format and release flow
- [SECURITY.md](../SECURITY.md) - security guidance
- [CONTRIBUTING.md](../CONTRIBUTING.md) - contribution rules
