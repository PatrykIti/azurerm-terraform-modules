resource "azurerm_monitor_private_link_scoped_service" "scoped_service" {
  for_each = {
    for service in var.scoped_services : service.name => service
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.monitor_private_link_scope.name
  linked_resource_id  = each.value.linked_resource_id
}
