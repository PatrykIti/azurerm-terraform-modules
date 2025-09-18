# Negative Route Table Test Cases

This fixture contains multiple test cases designed to validate error handling and input validation.

## Purpose

This fixture helps ensure the module properly validates inputs and provides meaningful error messages for invalid configurations.

## Test Cases

### 1. Invalid Route Table Name - Too Long
- Tests name validation for length (max 80 characters)
- Expected: Validation error for exceeding character limit

### 2. Invalid Route Table Name - Invalid Characters
- Tests name validation for allowed characters
- Expected: Validation error for special characters

### 3. Missing IP for VirtualAppliance
- Tests route validation when next_hop_type is VirtualAppliance
- Expected: Validation error for missing required IP address

### 4. IP Provided for Non-VirtualAppliance
- Tests route validation when IP is provided for wrong next_hop_type
- Expected: Validation error for unexpected IP address

### 5. Invalid Next Hop Type
- Tests route validation for allowed next_hop_type values
- Expected: Validation error for invalid hop type

### 6. Invalid IP Address Format
- Tests IP address format validation
- Expected: Validation error for malformed IP address

### 7. Invalid CIDR Notation
- Tests address_prefix CIDR validation
- Expected: Validation error for invalid CIDR

### 8. Duplicate Route Names
- Tests unique route name validation within a route table
- Expected: Validation error for duplicate names

## Usage

1. Open `main.tf`
2. Uncomment ONE test case at a time
3. Comment out the valid configuration at the bottom
4. Run terraform plan to see the validation error

```bash
terraform init
terraform plan -var="random_suffix=test123"
```

## Important Notes

- Only one test case should be active at a time
- The valid configuration at the bottom allows testing the fixture setup
- Each test case is designed to fail with a specific validation error
- This helps ensure the module provides proper input validation

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->