# Azure DevOps Wiki Module Documentation

## Overview

This module manages a single Azure DevOps wiki and optional strict-child wiki pages.

## Managed Resources

- `azuredevops_wiki`
- `azuredevops_wiki_page`

## Usage Notes

- The module creates exactly one wiki per instance.
- `wiki_pages` use stable map keys to keep Terraform addresses deterministic.
- Pages are always attached to the wiki created by this module.

## Inputs (Highlights)

- Required: `project_id`, `wiki`
- Optional: `wiki_pages`

## Outputs (Highlights)

- `wiki_id`, `wiki_name`, `wiki_remote_url`, `wiki_url`
- `wiki_page_ids` (keyed by stable page key)

## Import Existing Resources

See [IMPORT.md](./IMPORT.md) for import blocks and IDs.
