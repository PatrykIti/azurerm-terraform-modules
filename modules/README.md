<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
# Basic Route Table Example

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-route-table-basic-example"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "subnet-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Basic Route Table
module "route_table" {
  source = "../../"

  name                = "rt-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Simple routes configuration
  routes = [
    {
      name           = "to-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    },
    {
      name           = "local-vnet"
      address_prefix = "10.0.0.0/16"
      next_hop_type  = "VnetLocal"
    }
  ]

  # Associate with subnet
  subnet_ids_to_associate = {
    (azurerm_subnet.example.id) = azurerm_subnet.example.id
  }

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
```

## Examples

<!-- This section is managed by automation. Do not edit manually. -->
<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic deployment of an Azure Route Table with simple route configuration.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of Route Tables with all available features and advanced routing scenarios.
- [Private Endpoint](examples/private-endpoint) - This example demonstrates a Route Table configuration with private endpoint connectivity for enhanced security and network isolation.
- [Secure](examples/secure) - This example demonstrates a maximum-security Route Table configuration suitable for highly sensitive data and regulated environments.
<!-- END_EXAMPLES -->

## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

## Security Considerations

Refer to the [SECURITY.md](SECURITY.md) file for detailed security information.
<!-- END_TF_DOCS -->