# Terraform Azure DevOps Service Endpoints Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps service endpoints module for managing service connections and permissions.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "path/to/azuredevops_serviceendpoint"

  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = [
    {
      service_endpoint_name = "example-generic"
      server_url            = "https://example.endpoint.local"
      username              = "example-user"
      password              = "example-password"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating AzureRM and Docker registry service endpoints.
- [Complete](examples/complete) - This example demonstrates multiple service endpoint types with shared permissions.
- [Secure](examples/secure) - This example demonstrates a minimal service endpoint with restrictive permissions.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
