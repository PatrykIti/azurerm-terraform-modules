# Secure Application Insights Workbook Example

This fixture demonstrates a security-focused Application Insights Workbook configuration.

## Features

- User-assigned identity for the workbook
- RBAC assignment for the source workspace
- Log Analytics workspace as the source resource

## Key Configuration

This fixture focuses on least-privilege access for workbook data sources.

## Security Considerations

- Identity has Reader access to the source workspace
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
