# Terraform Azure DevOps Security Role Assignment Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **0.1.0**
<!-- END_VERSION -->

## Description

Manages Azure DevOps security role assignments for groups, users, or service principals.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_securityrole_assignment" {
  source = "path/to/azuredevops_securityrole_assignment"

  securityrole_assignments = [
    {
      key         = "project-reader"
      scope       = "project"
      resource_id = "00000000-0000-0000-0000-000000000000"
      role_name   = "Reader"
      identity_id = "11111111-1111-1111-1111-111111111111"
    }
  ]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - Minimal security role assignment.
- [Complete](examples/complete) - Multiple assignments with explicit keys.
- [Secure](examples/secure) - Security-focused assignment using stakeholder-like scope.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps security role assignments into the module

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_securityrole_assignment.securityrole_assignment](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/securityrole_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity_id"></a> [identity\_id](#input\_identity\_id) | Identity descriptor/ID to assign the role to. | `string` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | Target resource ID for the security role assignment (e.g., project ID). | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Role name to assign (e.g., Reader, Contributor). | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | Scope for the Azure DevOps security role assignment (for example, project). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityrole_assignment_id"></a> [securityrole\_assignment\_id](#output\_securityrole\_assignment\_id) | The security role assignment ID. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
