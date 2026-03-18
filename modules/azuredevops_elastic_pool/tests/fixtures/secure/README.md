# Secure Azure DevOps Elastic Pool Fixture

This fixture validates a conservative security posture for `azuredevops_elastic_pool`.

## Coverage

- Uses `desired_idle = 0` and low `max_capacity`
- Enables `recycle_after_each_use` for stronger isolation
- Disables `auto_provision` and `auto_update`
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
