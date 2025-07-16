output "subnet_id" {
  description = "The ID of the created Subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the created Subnet"
  value       = module.subnet.name
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.subnet.private_endpoints
}

# Create module.json and .releaserc.js
print_info "Creating module.json and .releaserc.js..."
if [[ -x "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/scripts/create-module-json.sh" ]]; then
    "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/scripts/create-module-json.sh" "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/modules/azurerm_subnet" "Subnet" "subnet" "SN"
else
    print_warning "scripts/create-module-json.sh not found or not executable."
fi

