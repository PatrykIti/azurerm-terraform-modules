# Secure Application Insights Workbook Example

This example demonstrates a security-focused Application Insights Workbook configuration.

## Features

- User-assigned identity for the workbook
- RBAC assignment granting least-privilege access to the source resource
- Log Analytics workspace as the source

## Key Configuration

This example implements least-privilege access to the workbook source data.

## Security Considerations

- Identity has only Reader access to the source workspace
- Workbook data source is explicitly scoped

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
