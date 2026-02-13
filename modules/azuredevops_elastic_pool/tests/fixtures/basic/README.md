# Basic Azure DevOps Elastic Pool Fixture

This fixture validates the minimum required configuration for `azuredevops_elastic_pool`.

## Coverage

- Creates one elastic pool with required fields only
- Uses randomized pool name suffix for test isolation
- Verifies module output `elastic_pool_id`

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
