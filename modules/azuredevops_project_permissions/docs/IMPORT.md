# Import existing Azure DevOps Project Permissions into the module

The `azuredevops_project_permissions` resource **does not support import** in the provider, so existing project permissions cannot be imported into state.

## What to do instead

- Configure the desired permissions in Terraform and let the module manage them going forward.
- Use `replace = false` to merge permissions instead of overwriting existing group permissions.

## Related

- If you need to inspect current permissions, use the Azure DevOps UI or REST API before configuring Terraform.
