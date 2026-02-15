# azuredevops_environments Module Security

## Overview

This module manages Azure DevOps environments and checks. Secure defaults are focused on explicit deployment gates.

## Security Controls in Module

- Approval checks (`check_approvals`)
- Branch control checks (`check_branch_controls`)
- Business hours checks (`check_business_hours`)
- Exclusive lock checks (`check_exclusive_locks`)
- Required template checks (`check_required_templates`)
- REST API checks (`check_rest_apis`)

## Scope Rules

- Root `check_*` inputs protect the environment resource.
- Nested checks in `kubernetes_resources[*].checks` protect the backing service endpoint.
- The module does not expose arbitrary check targets.

## Secure Example

Use `examples/secure` as the hardened baseline configuration for production-like environments.

## Hardening Checklist

- [ ] Require approvals for sensitive environments.
- [ ] Use exclusive locks to prevent concurrent deployments.
- [ ] Restrict branches for protected environments/resources.
- [ ] Limit deployment windows with business hours.
- [ ] Enforce required templates for governance.

## References

- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals
- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments
