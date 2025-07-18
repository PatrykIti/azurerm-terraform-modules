# Negative Test Example for Network Security Group

This example demonstrates an intentionally invalid configuration for the Network Security Group module to test its input validation.

- Attempts to create an NSG with a security rule that has an invalid priority.
- This configuration is expected to fail during the `terraform plan` phase.
