# Network Wrapper Example

This example demonstrates the recommended pattern for managing subnet associations at the wrapper/composition level. This approach provides maximum flexibility and follows the established patterns in this repository.

## Key Benefits

1. **Flexibility**: Subnets can be created independently of their security configurations
2. **Reusability**: NSGs and Route Tables can be shared across multiple subnets
3. **Maintainability**: Security configurations can be updated without modifying subnet definitions
4. **Environment-specific**: Different environments can use different security configurations without changing subnet modules

## Architecture

This example creates:
- 1 Virtual Network with 3 subnets (app, data, management)
- 2 Network Security Groups (app tier, data tier)
- 2 Route Tables (direct internet access for app, forced through firewall for data)
- Appropriate associations managed at the wrapper level

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Pattern Explanation

Instead of embedding NSG and Route Table IDs within the subnet module:

```hcl
# ❌ Don't do this - inflexible approach
module "subnet" {
  source = "../../"
  
  name                      = "my-subnet"
  network_security_group_id = azurerm_network_security_group.example.id
  route_table_id           = azurerm_route_table.example.id
}
```

Manage associations separately:

```hcl
# ✅ Do this - flexible approach
module "subnet" {
  source = "../../"
  
  name = "my-subnet"
  # ... other subnet-specific configuration
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = module.subnet.id
  network_security_group_id = azurerm_network_security_group.example.id
}
```

This pattern allows:
- Dynamic association/disassociation based on conditions
- Sharing security resources across multiple subnets
- Different security configurations per environment
- Easier testing and validation