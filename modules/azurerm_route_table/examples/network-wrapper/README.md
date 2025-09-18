# Network Wrapper Example

This example demonstrates the recommended pattern for managing route table subnet associations at the network wrapper level. This approach solves the Terraform limitation where subnet IDs are not known at plan time when creating resources from scratch.

## Architecture

This example creates a complete network infrastructure with:
- Virtual Network
- Multiple Subnets (app, data, gateway)
- Network Security Group
- Route Table with custom routes
- Subnet associations managed at the wrapper level

## Benefits of the Wrapper Pattern

1. **No Circular Dependencies**: By managing associations at the wrapper level, we avoid the "for_each with unknown values" error
2. **Clear Separation of Concerns**: Each module focuses on its core responsibility
3. **Flexible Association Management**: Easy to add or remove subnet associations
4. **Better Error Handling**: Terraform can properly plan the resource creation order

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Clean Up

```bash
terraform destroy
```

## Key Points

- The route table module only creates the route table and routes
- Subnet associations are created directly in the wrapper using `azurerm_subnet_route_table_association`
- This pattern works well when you have control over the entire network infrastructure
- For scenarios where subnets are created elsewhere, consider using data sources to reference existing subnets