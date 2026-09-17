output "route_table_id" {
  description = "The ID of the created Route Table."
  value       = module.route_table_validation.id
}

output "route_table_name" {
  description = "The name of the created Route Table."
  value       = module.route_table_validation.name
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.test.name
}

output "test_description" {
  description = "Description of the negative test cases available."
  value = {
    test_case_1  = "Invalid route table name - too long (exceeds 80 chars)"
    test_case_2  = "Invalid route table name - contains invalid characters"
    test_case_3  = "Invalid route - missing IP for VirtualAppliance"
    test_case_4  = "Invalid route - IP provided for non-VirtualAppliance"
    test_case_5  = "Invalid route - invalid next_hop_type"
    test_case_6  = "Invalid route - invalid IP address format"
    test_case_7  = "Invalid route - invalid CIDR notation"
    test_case_8  = "Invalid route - duplicate route names"
    instructions = "Uncomment one test case at a time to test validation"
  }
}