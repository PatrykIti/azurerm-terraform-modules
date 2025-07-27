# Basic Route Table Example

This example demonstrates a basic Route Table configuration using secure defaults and minimal setup.

## Features

- Creates a basic Route Table with standard configuration
- Uses secure defaults following Azure best practices
- Creates a dedicated resource group
- BGP route propagation enabled by default (secure default)
- Demonstrates basic module usage patterns
- Uses variables for configuration flexibility

## Key Configuration

This example uses secure defaults and demonstrates:
- Basic resource creation with minimal configuration
- Using variables for easy configuration customization
- Following security best practices by default
- No custom routes (allows system routes only)
- BGP route propagation enabled for automatic routing updates

## Usage

```bash
terraform init
terraform plan -var="random_suffix=test123"
terraform apply -var="random_suffix=test123"
```

## Cleanup

```bash
terraform destroy -var="random_suffix=test123"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
