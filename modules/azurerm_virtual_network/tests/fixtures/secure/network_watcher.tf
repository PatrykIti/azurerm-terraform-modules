# Network Watcher configuration
# Azure allows only ONE Network Watcher per region per subscription
# We need to check if it exists and use it, or create new if it doesn't

# Use external data source to check for existing Network Watcher
data "external" "network_watcher_check" {
  program = ["bash", "-c", <<-EOT
    # Check if Network Watcher exists in the region
    NW_LIST=$(az network watcher list --query "[?location=='${var.location}']" -o json 2>/dev/null || echo '[]')
    
    # If we found any Network Watchers, return the first one
    if [ "$(echo "$NW_LIST" | jq 'length')" -gt "0" ]; then
      echo "$NW_LIST" | jq '.[0] | {name: .name, resourceGroup: .resourceGroup}'
    else
      # Return empty values to indicate no Network Watcher exists
      echo '{"name": "", "resourceGroup": ""}'
    fi
  EOT
  ]
}

locals {
  # Check if we found an existing Network Watcher
  network_watcher_exists = data.external.network_watcher_check.result.name != ""

  # Final values to use
  network_watcher_name = local.network_watcher_exists ? data.external.network_watcher_check.result.name : azurerm_network_watcher.test[0].name
  network_watcher_rg   = local.network_watcher_exists ? data.external.network_watcher_check.result.resourceGroup : azurerm_network_watcher.test[0].resource_group_name
}

# Create resource group for Network Watcher only if needed
resource "azurerm_resource_group" "network_watcher" {
  count    = local.network_watcher_exists ? 0 : 1
  name     = "rg-nw-test-${var.random_suffix}"
  location = var.location

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
}

# Create Network Watcher only if it doesn't exist in the region
resource "azurerm_network_watcher" "test" {
  count               = local.network_watcher_exists ? 0 : 1
  name                = "nw-test-${var.random_suffix}"
  location            = azurerm_resource_group.network_watcher[0].location
  resource_group_name = azurerm_resource_group.network_watcher[0].name

  tags = {
    Environment = "Test"
    Module      = "azurerm_virtual_network"
    Test        = "Secure"
  }
}