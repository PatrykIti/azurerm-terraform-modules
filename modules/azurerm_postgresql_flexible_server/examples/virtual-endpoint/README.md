# PostgreSQL Flexible Server Virtual Endpoint Example

This example demonstrates creating a virtual endpoint between a primary server
and its replica.

## Features

- Primary server deployment.
- Replica server deployment.
- Virtual endpoint configured from the replica module (using primary server ID).

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
