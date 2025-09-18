# Basic Subnet Example

This example demonstrates the minimal configuration required to create a subnet within an Azure Virtual Network.

## What this example creates

- Resource Group
- Virtual Network with a single address space
- Subnet with basic configuration and default network policies

## Use Case

This example is perfect for:
- Simple subnet deployment scenarios
- Learning how to use the subnet module
- Development and testing environments
- Basic network segmentation needs

## Features Demonstrated

- Basic subnet creation
- Default network policy configuration
- Integration with existing Virtual Network
- Simple address prefix assignment

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Clean up when done
terraform destroy
```

## Configuration

The example uses the following default values:
- Virtual Network: `10.0.0.0/16`
- Subnet: `10.0.1.0/24`
- Location: `East US`

You can customize these values by providing your own `terraform.tfvars` file or by overriding the variables when running `terraform apply`.

## Example terraform.tfvars

```hcl
location              = "West Europe"
resource_group_name   = "my-subnet-rg"
virtual_network_name  = "my-vnet"
subnet_name          = "my-subnet"
```