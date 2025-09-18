# Basic Route Table Example

This example demonstrates a basic deployment of an Azure Route Table with simple route configuration.

## Features

- Basic route table with essential routes
- Simple subnet association
- Minimal configuration for getting started

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Key Configuration

- Creates a route table with two basic routes:
  - Default route to Internet
  - Local VNet route
- Associates the route table with a subnet
- Uses default BGP route propagation settings

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->