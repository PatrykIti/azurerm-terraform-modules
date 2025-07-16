output "route_table_id" {
  description = "The ID of the created Route Table"
  value       = module.route_table.id
}

output "route_table_name" {
  description = "The name of the created Route Table"
  value       = module.route_table.name
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.route_table.private_endpoints
}

# Create module.json and .releaserc.js
print_info "Creating module.json and .releaserc.js..."
if [[ -x "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/scripts/create-module-json.sh" ]]; then
    "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/scripts/create-module-json.sh" "/Users/pciechanski/Documents/_moje_projekty/terraform_modules/azurerm-terraform-modules/modules/azurerm_route_table" "Route Table" "route-table" "RT"
else
    print_warning "scripts/create-module-json.sh not found or not executable."
fi

