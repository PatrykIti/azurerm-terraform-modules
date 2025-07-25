# Network Wrapper Advanced Example

This example demonstrates an advanced pattern for managing route table subnet associations using object iteration with null handling. This approach allows for dynamic subnet creation and association while avoiding the Terraform "for_each with unknown values" error.

## Key Features

1. **Object Pattern with Null Handling**: Uses `try()` function to handle cases where subnet IDs might not be known at plan time
2. **Conditional Associations**: Each subnet can individually control whether it needs route table and/or NSG associations
3. **Dynamic Subnet Creation**: Subnets are created from a map variable, making it easy to add/remove subnets
4. **Safe Iteration**: The for_each uses an object pattern that safely handles unknown values

## How It Works

The key to this pattern is in the association resources:

```hcl
resource "azurerm_subnet_route_table_association" "associations" {
  for_each = {
    for subnet_key, subnet_config in var.subnets :
    subnet_key => {
      subnet_id      = try(azurerm_subnet.subnets[subnet_key].id, null)
      route_table_id = module.route_table.id
    }
    if subnet_config.associate_route_table == true && try(azurerm_subnet.subnets[subnet_key].id, null) != null
  }

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
```

This pattern:
- Creates an object for each subnet that needs association
- Uses `try()` to safely access the subnet ID (returns null if not available)
- Filters out any entries where the subnet ID is null
- Allows Terraform to properly handle the dependency chain

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Customization

You can easily customize the subnet configuration by modifying the `subnets` variable:

```hcl
subnets = {
  "snet-custom" = {
    address_prefix        = "10.0.5.0/24"
    associate_route_table = true
    associate_nsg        = false
  }
}
```

## Benefits

1. **No Two-Step Apply**: Works correctly even when creating all resources from scratch
2. **Flexible Configuration**: Each subnet can have different association requirements
3. **Clean Code**: Associations are managed in a single place with clear logic
4. **Scalable**: Easy to add more subnets without changing the association logic

## Clean Up

```bash
terraform destroy
```