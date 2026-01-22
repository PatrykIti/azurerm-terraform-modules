# Secure PostgreSQL Flexible Server Example

This example demonstrates a hardened PostgreSQL Flexible Server deployment with
private networking, Microsoft Entra ID authentication, and customer-managed keys.

## Features

- Private network access using a delegated subnet and private DNS zone.
- Microsoft Entra ID (Azure AD) authentication with an administrator assignment.
- Customer-managed key encryption using a user-assigned identity.
- Geo-redundant backups enabled.

## Usage

```bash
terraform init
terraform plan \
  -var="aad_admin_object_id=<object-id>" \
  -var="aad_admin_principal_name=<principal-name>"
terraform apply \
  -var="aad_admin_object_id=<object-id>" \
  -var="aad_admin_principal_name=<principal-name>"
```

## Cleanup

```bash
terraform destroy \
  -var="aad_admin_object_id=<object-id>" \
  -var="aad_admin_principal_name=<principal-name>"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
