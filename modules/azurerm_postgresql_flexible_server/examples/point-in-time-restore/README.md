# PostgreSQL Flexible Server Point-in-Time Restore Example

This example demonstrates how to restore a PostgreSQL Flexible Server to a
specific point in time. You must provide an existing source server ID and a
valid restore timestamp.

## Features

- Point-in-time restore using `create_mode`.

## Usage

```bash
terraform init
terraform plan \
  -var="source_server_id=<server-id>" \
  -var="restore_time_utc=2024-01-01T00:00:00Z"
terraform apply \
  -var="source_server_id=<server-id>" \
  -var="restore_time_utc=2024-01-01T00:00:00Z"
```

## Cleanup

```bash
terraform destroy \
  -var="source_server_id=<server-id>" \
  -var="restore_time_utc=2024-01-01T00:00:00Z"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
