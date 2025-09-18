# Terraform Azure Subnet Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

This module creates and manages Azure Subnets with advanced configuration options including service endpoints, delegations, and network policies. It's designed to provide comprehensive subnet management capabilities beyond the basic subnet creation included in virtual network modules.

> **Note**: Network Security Group and Route Table associations should be managed at the wrapper/composition level for maximum flexibility. See the examples for best practices on managing associations.

## Features

- **Service Endpoints**: Configure access to Azure services (Storage, SQL, KeyVault, etc.)
- **Subnet Delegation**: Delegate subnets to specific Azure services
- **Network Policies**: Control private endpoint and private link service policies
- **Service Endpoint Policies**: Apply policies to restrict service endpoint access
- **Private Endpoint Support**: Configure subnets specifically for private endpoints
- **Security-First Design**: Secure defaults with flexible overrides
- **Flexible Architecture**: Designed to work with external NSG and Route Table associations

## Usage

### Basic Example

```hcl
module "subnet" {
  source = "path/to/azurerm_subnet"

  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}
```

### Advanced Example with Security Features

```hcl
module "secure_subnet" {
  source = "path/to/azurerm_subnet"

  name                 = "secure-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  # Service endpoints
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault"
  ]

  # Service endpoint policies
  service_endpoint_policy_ids = [azurerm_subnet_service_endpoint_storage_policy.example.id]

  # Network policies
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true

  tags = {
    Environment   = "Production"
    SecurityLevel = "High"
  }
}

# Network Security Group Association - managed at wrapper level
resource "azurerm_subnet_network_security_group_association" "secure" {
  subnet_id                 = module.secure_subnet.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Route Table Association - managed at wrapper level
resource "azurerm_subnet_route_table_association" "secure" {
  subnet_id      = module.secure_subnet.id
  route_table_id = azurerm_route_table.example.id
}
```

### Private Endpoint Subnet Example

```hcl
module "private_endpoint_subnet" {
  source = "path/to/azurerm_subnet"

  name                 = "private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]

  # Required for private endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  tags = {
    Purpose = "PrivateEndpoints"
  }
}

# Optional NSG association for additional security - managed at wrapper level
resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = module.private_endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.pe.id
}
```

### Subnet with Delegation Example

```hcl
module "delegated_subnet" {
  source = "path/to/azurerm_subnet"

  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.4.0/24"]

  # Delegate to Azure Container Instances
  delegations = {
    aci = {
      name = "Microsoft.ContainerInstance/containerGroups"
      service_delegation = {
        name = "Microsoft.ContainerInstance/containerGroups"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action",
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }

  tags = {
    Service = "ContainerInstances"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [basic](examples/basic) - Basic subnet configuration with minimal inputs
- [complete](examples/complete) - Complete configuration showcasing all features
- [network-wrapper](examples/network-wrapper) - Recommended pattern for managing subnet associations at wrapper level
- [private-endpoint](examples/private-endpoint) - Subnet configuration for hosting private endpoints
- [secure](examples/secure) - Security-hardened subnet with NSG, route table, and service endpoint policies
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.43.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.43.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.43.0/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | The address prefixes to use for the subnet. This is a list of IPv4 or IPv6 address ranges. | `list(string)` | n/a | yes |
| <a name="input_delegations"></a> [delegations](#input\_delegations) | One or more delegation blocks for the subnet. | <pre>map(object({<br/>    name = string<br/>    service_delegation = object({<br/>      name    = string<br/>      actions = optional(list(string), [])<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the subnet. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_endpoint_network_policies_enabled"></a> [private\_endpoint\_network\_policies\_enabled](#input\_private\_endpoint\_network\_policies\_enabled) | Enable or Disable network policies for the private endpoint on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true. | `bool` | `true` | no |
| <a name="input_private_link_service_network_policies_enabled"></a> [private\_link\_service\_network\_policies\_enabled](#input\_private\_link\_service\_network\_policies\_enabled) | Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Virtual Network exists. | `string` | n/a | yes |
| <a name="input_service_endpoint_policy_ids"></a> [service\_endpoint\_policy\_ids](#input\_service\_endpoint\_policy\_ids) | The list of IDs of Service Endpoint Policies to associate with the subnet. | `list(string)` | `[]` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global and Microsoft.Web. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the subnet. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the Virtual Network where this subnet should be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_prefixes"></a> [address\_prefixes](#output\_address\_prefixes) | The address prefixes for the subnet |
| <a name="output_delegations"></a> [delegations](#output\_delegations) | The delegations configured on the subnet |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Subnet |
| <a name="output_name"></a> [name](#output\_name) | The name of the Subnet |
| <a name="output_private_endpoint_network_policies_enabled"></a> [private\_endpoint\_network\_policies\_enabled](#output\_private\_endpoint\_network\_policies\_enabled) | Whether network policies are enabled for private endpoints on this subnet |
| <a name="output_private_link_service_network_policies_enabled"></a> [private\_link\_service\_network\_policies\_enabled](#output\_private\_link\_service\_network\_policies\_enabled) | Whether network policies are enabled for private link service on this subnet |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group where the subnet exists |
| <a name="output_service_endpoint_policy_ids"></a> [service\_endpoint\_policy\_ids](#output\_service\_endpoint\_policy\_ids) | The list of Service Endpoint Policy IDs associated with the subnet |
| <a name="output_service_endpoints"></a> [service\_endpoints](#output\_service\_endpoints) | The list of Service endpoints enabled on this subnet |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the Virtual Network where the subnet exists |
<!-- END_TF_DOCS -->

## Security Considerations

This module implements several security best practices:

### Network Policies
- **Private Endpoint Network Policies**: Enabled by default for additional security
- **Private Link Service Network Policies**: Enabled by default
- Must be explicitly disabled for subnets hosting private endpoints

### Service Endpoints
- Provides secure connectivity to Azure services without internet exposure
- Supports service endpoint policies for additional access control
- Recommend using specific service endpoints based on actual requirements

### Network Security
- Supports NSG association for inbound/outbound traffic control
- Supports Route Table association for custom routing rules
- Examples demonstrate security-hardened configurations

### Best Practices
1. Always associate an NSG with production subnets
2. Use service endpoints instead of public endpoints when possible
3. Apply service endpoint policies to restrict access to specific resources
4. Use separate subnets for different workload types
5. Enable network policies unless hosting private endpoints

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Network isolation and access controls
- **ISO 27001:2022**: Information security management
- **PCI DSS v4.0**: Network segmentation for payment card data
- **GDPR**: Data protection through network isolation

## Known Issues and Limitations

1. **Service Endpoint Policies**: Currently only support storage account restrictions
2. **Delegation**: A subnet can only be delegated to one service
3. **Address Space**: Cannot overlap with other subnets in the same VNet
4. **Private Endpoints**: Require network policies to be disabled

## Contributing

Please see our [contribution guidelines](../../CONTRIBUTING.md) for details on how to contribute to this module.

## License

This module is licensed under the MIT License. See the [LICENSE](../../LICENSE.md) file for details.

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines