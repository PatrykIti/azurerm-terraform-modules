# PostgreSQL Flexible Server Replica Example

This example demonstrates creating a read replica using `create_mode = Replica`.

## Features

- Primary server deployment.
- Replica server using `source_server_id` from the primary server.

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
