# Secure App Service Plan Example

This example demonstrates an operationally hardened App Service Plan baseline
with centralized diagnostics and explicit production-oriented tagging.

## Features

- Creates a Standard Windows App Service Plan
- Uses explicit worker capacity for deterministic hosting
- Streams supported logs and metrics to Log Analytics
- Applies explicit production-oriented tags

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
