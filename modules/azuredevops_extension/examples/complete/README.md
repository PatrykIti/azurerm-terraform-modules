# Complete Azure DevOps Extension Example

This example demonstrates installing multiple Azure DevOps Marketplace extensions with version pinning.

## Features

- Multiple extensions installed at the organization level
- Optional version pins per extension

## Key Configuration

Update the `extensions` list with your Marketplace publisher and extension IDs.
The module uses `for_each` to install each extension.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_extension"></a> [azuredevops\_extension](#module\_azuredevops\_extension) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extensions"></a> [extensions](#input\_extensions) | List of extensions to install. | <pre>list(object({<br/>    publisher_id = string<br/>    extension_id = string<br/>    version      = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "extension_id": "extension-one",<br/>    "publisher_id": "publisher-one"<br/>  },<br/>  {<br/>    "extension_id": "extension-two",<br/>    "publisher_id": "publisher-two",<br/>    "version": "1.2.3"<br/>  }<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_extension_ids"></a> [extension\_ids](#output\_extension\_ids) | Map of extension IDs keyed by publisher/extension. |
<!-- END_TF_DOCS -->
