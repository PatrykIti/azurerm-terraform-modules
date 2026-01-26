# Secure Monitor Data Collection Rule Fixture

This fixture demonstrates a DCR configured with a secure Data Collection Endpoint and Log Analytics destination.

## Features

- Uses a DCE module with public access disabled
- Collects Windows event logs to Log Analytics

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
