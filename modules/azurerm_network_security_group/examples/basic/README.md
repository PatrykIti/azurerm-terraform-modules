# Basic Network Security Group Example

This example demonstrates a basic Network Security Group configuration with simple inbound and outbound security rules.

## Features

- Creates an NSG with basic security rules
- Demonstrates common rule patterns (RDP, HTTP, HTTPS)
- Shows both inbound and outbound rule configuration
- Uses rule descriptions for documentation
- Creates a dedicated resource group

## Security Rules

This example creates the following security rules:

### Inbound Rules
- **Allow RDP** (Priority 100): Allows RDP access from internal networks (10.0.0.0/8)
- **Allow HTTP** (Priority 110): Allows HTTP traffic from anywhere
- **Allow HTTPS** (Priority 120): Allows HTTPS traffic from anywhere

### Outbound Rules
- **Deny All Outbound** (Priority 4096): Denies all outbound traffic (demonstrating restrictive outbound rules)

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
