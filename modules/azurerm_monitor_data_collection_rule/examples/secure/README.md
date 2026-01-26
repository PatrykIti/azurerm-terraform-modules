# Secure Monitor Data Collection Rule Example

This example demonstrates a DCR configured to use a dedicated Data Collection Endpoint with public access disabled on the endpoint.

## Features

- Uses a separate DCE module with public access disabled
- Collects Windows event logs to Log Analytics

## Security Considerations

- Ensure private connectivity to the DCE (out of scope for this module)
- Use managed identities and least-privilege RBAC

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
