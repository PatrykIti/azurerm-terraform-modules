# Basic Network Security Group Example

This example demonstrates a basic Network Security Group configuration with simple inbound and outbound security rules.

## Features

- Creates an NSG with basic security rules
- Demonstrates common rule patterns (SSH, HTTP, HTTPS)
- Shows both inbound and outbound rule configuration
- Uses rule descriptions for documentation
- Creates a dedicated resource group

## Security Rules

This example creates the following security rules:

### Inbound Rules
- **Allow SSH** (Priority 100): Allows SSH access from a specified IP address
- **Allow HTTP** (Priority 110): Allows HTTP traffic from the Internet
- **Allow HTTPS** (Priority 120): Allows HTTPS traffic from the Internet

### Outbound Rules
- **Allow All Outbound** (Priority 4096): Allows all outbound traffic

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
<!-- This section will be populated by terraform-docs if configured -->
<!-- END_TF_DOCS -->