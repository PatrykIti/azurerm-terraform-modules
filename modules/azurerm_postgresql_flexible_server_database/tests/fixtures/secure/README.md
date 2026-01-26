# Secure PostgreSQL Flexible Server Database Example

This fixture demonstrates a private-networked PostgreSQL Flexible Server with a database created through the module.

## Features

- Private networking via delegated subnet and private DNS zone
- Database creation on a private server

## Key Configuration

This fixture focuses on private access to the hosting server.

## Security Considerations

- Public network access is disabled on the server
- Access is limited to the private subnet

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
