# Test complex scenarios for the Route Table module

mock_provider "azurerm" {
  mock_resource "azurerm_route_table" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt"
      name                          = "test-rt"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      bgp_route_propagation_enabled = false
      subnets                       = []
      tags                          = {}
    }
  }
  
  mock_resource "azurerm_route" {
    defaults = {
      id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/routeTables/test-rt/routes/test-route"
      name                   = "test-route"
      resource_group_name    = "test-rg"
      route_table_name       = "test-rt"
      address_prefix         = "10.0.0.0/16"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    }
  }
}

variables {
  name                = "test-rt-complex"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Test hub-spoke firewall pattern
run "hub_spoke_firewall_pattern" {
  command = plan

  variables {
    bgp_route_propagation_enabled = false
    routes = [
      {
        name                   = "default-to-firewall"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.4"
      },
      {
        name           = "local-vnet-direct"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      {
        name           = "to-on-premises"
        address_prefix = "192.168.0.0/16"
        next_hop_type  = "VirtualNetworkGateway"
      }
    ]
    tags = {
      Pattern     = "Hub-Spoke"
      Purpose     = "Firewall-Inspection"
      Environment = "Production"
    }
  }

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == false
    error_message = "BGP propagation should be disabled for hub-spoke pattern"
  }

  assert {
    condition     = length(azurerm_route.routes) == 3
    error_message = "Hub-spoke pattern should have 3 routes"
  }

  assert {
    condition     = azurerm_route.routes["default-to-firewall"].next_hop_type == "VirtualAppliance"
    error_message = "Default route should go to firewall"
  }
}

# Test DMZ pattern with multiple security zones
run "dmz_security_zones_pattern" {
  command = plan

  variables {
    bgp_route_propagation_enabled = true
    routes = [
      {
        name           = "internet-direct"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      },
      {
        name           = "block-private-ranges-1"
        address_prefix = "10.0.0.0/8"
        next_hop_type  = "None"
      },
      {
        name           = "block-private-ranges-2"
        address_prefix = "172.16.0.0/12"
        next_hop_type  = "None"
      },
      {
        name           = "block-private-ranges-3"
        address_prefix = "192.168.0.0/16"
        next_hop_type  = "None"
      }
    ]
    tags = {
      Pattern       = "DMZ"
      SecurityLevel = "High"
      Purpose       = "Internet-Facing"
    }
  }

  assert {
    condition     = length(azurerm_route.routes) == 4
    error_message = "DMZ pattern should have 4 routes"
  }

  assert {
    condition     = azurerm_route.routes["internet-direct"].next_hop_type == "Internet"
    error_message = "DMZ should have direct internet access"
  }

  assert {
    condition     = azurerm_route.routes["block-private-ranges-1"].next_hop_type == "None"
    error_message = "Private ranges should be blocked in DMZ"
  }
}

# Test forced tunneling pattern
run "forced_tunneling_pattern" {
  command = plan

  variables {
    bgp_route_propagation_enabled = false
    routes = [
      {
        name                   = "force-all-to-nva"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.1.4"
      }
    ]
    tags = {
      Pattern            = "Forced-Tunneling"
      ComplianceRequired = "true"
      DataClassification = "Confidential"
    }
  }

  assert {
    condition     = length(azurerm_route.routes) == 1
    error_message = "Forced tunneling should have single default route"
  }

  assert {
    condition     = azurerm_route.routes["force-all-to-nva"].address_prefix == "0.0.0.0/0"
    error_message = "Forced tunneling should route all traffic"
  }

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == false
    error_message = "BGP should be disabled for forced tunneling"
  }
}

# Test multi-region disaster recovery pattern
run "multi_region_dr_pattern" {
  command = plan

  variables {
    bgp_route_propagation_enabled = true
    routes = [
      {
        name           = "primary-region"
        address_prefix = "10.0.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      {
        name           = "dr-region-west"
        address_prefix = "10.1.0.0/16"
        next_hop_type  = "VirtualNetworkGateway"
      },
      {
        name           = "dr-region-east"
        address_prefix = "10.2.0.0/16"
        next_hop_type  = "VirtualNetworkGateway"
      },
      {
        name                   = "shared-services"
        address_prefix         = "10.100.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.100"
      }
    ]
    tags = {
      Pattern         = "Multi-Region-DR"
      PrimaryRegion   = "North Europe"
      SecondaryRegion = "West Europe"
      TertiaryRegion  = "UK South"
    }
  }

  assert {
    condition     = length(azurerm_route.routes) == 4
    error_message = "Multi-region DR should have routes for all regions"
  }

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == true
    error_message = "BGP should be enabled for multi-region connectivity"
  }
}

# Test zero trust network pattern
run "zero_trust_network_pattern" {
  command = plan

  variables {
    bgp_route_propagation_enabled = false
    routes = [
      {
        name                   = "all-to-inspection"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.10"
      },
      {
        name           = "deny-lateral-movement-1"
        address_prefix = "10.0.1.0/24"
        next_hop_type  = "None"
      },
      {
        name           = "deny-lateral-movement-2"
        address_prefix = "10.0.2.0/24"
        next_hop_type  = "None"
      },
      {
        name           = "deny-lateral-movement-3"
        address_prefix = "10.0.3.0/24"
        next_hop_type  = "None"
      },
      {
        name                   = "allow-specific-service"
        address_prefix         = "10.0.100.5/32"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.0.0.11"
      }
    ]
    tags = {
      Pattern           = "Zero-Trust"
      SecurityFramework = "NIST"
      MicroSegmentation = "Enabled"
    }
  }

  assert {
    condition     = length(azurerm_route.routes) == 5
    error_message = "Zero trust pattern should have granular routing rules"
  }

  assert {
    condition     = azurerm_route_table.route_table.bgp_route_propagation_enabled == false
    error_message = "BGP should be disabled for zero trust pattern"
  }
}