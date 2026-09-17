# Basic App Service Plan Test Fixture

This fixture deploys a minimal App Service Plan using the module under test.

## Features

- Creates a dedicated resource group
- Deploys a basic Windows App Service Plan
- Uses dynamic names for Terratest isolation

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
<!-- END_TF_DOCS -->
