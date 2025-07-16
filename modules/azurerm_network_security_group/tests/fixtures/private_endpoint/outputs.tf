output "network_security_group_id" {
  description = "The ID of the created Network Security Group"
  value       = module.network_security_group.id
}

output "network_security_group_name" {
  description = "The name of the created Network Security Group"
  value       = module.network_security_group.name
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.network_security_group.private_endpoints
}

# Create module.json and .releaserc.js
print_info "Creating module.json and .releaserc.js..."
if [[ -x "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules-nsg/scripts/create-module-json.sh" ]]; then
    "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules-nsg/scripts/create-module-json.sh" "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules-nsg/modules/azurerm_network_security_group" "Network Security Group" "network-security-group" "NSG"
else
    print_warning "scripts/create-module-json.sh not found or not executable."
fi

