# PostgreSQL Flexible Server Entra ID Authentication Example

This example demonstrates enabling Microsoft Entra ID authentication and
assigning an Azure AD administrator to the PostgreSQL Flexible Server.

## Features

- Entra ID authentication enabled alongside password auth.
- Azure AD administrator assignment.

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
