# Complete Azure DevOps Elastic Pool Fixture

This fixture validates optional tuning fields exposed by `azuredevops_elastic_pool`.

## Coverage

- Configures capacity controls (`desired_idle`, `max_capacity`)
- Configures lifecycle options (`recycle_after_each_use`, `time_to_live_minutes`)
- Configures automation options (`auto_provision`, `auto_update`, `agent_interactive_ui`)
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
