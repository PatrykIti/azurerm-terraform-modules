# azuredevops_group_entitlement Module Security

## Overview

This document describes security considerations for Azure DevOps group entitlements managed by Terraform.

## Security Guidance

- Apply least-privilege license assignments for group entitlements.
- Prefer explicit keys to keep entitlement identity stable in Terraform state.
- Restrict who can modify entitlement configuration in CI/CD pipelines.

## Security Configuration Example

```hcl
module "azuredevops_group_entitlement" {
  source = "./modules/azuredevops_group_entitlement"

  group_entitlement = {
    key                  = "security-reviewers"
    display_name         = "ADO Security Reviewers"
    account_license_type = "stakeholder"
    licensing_source     = "account"
  }
}
```

## Security Hardening Checklist

- [ ] Use minimum required `account_license_type` for the target group.
- [ ] Control write access to Terraform states containing entitlement IDs.
- [ ] Protect pipelines applying entitlement changes.
