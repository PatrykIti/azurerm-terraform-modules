# Terraform Module Examples - Praktyczne Przykłady

Ten dokument zawiera praktyczne przykłady tworzenia modułów Terraform na podstawie analizy najlepszych praktyk z repozytoriów CDS.

## Przykład 1: Prosty moduł Storage Account

### Struktura modułu

```
terraform-azurerm-simple-storage/
├── examples/
│   ├── simple/
│   │   └── main.tf
│   └── complete/
│       └── main.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

### variables.tf

```hcl
variable "name" {
  description = "Nazwa konta storage (3-24 znaki, tylko małe litery i cyfry)"
  type        = string
  
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24
    error_message = "Nazwa musi mieć długość między 3 a 24 znaki."
  }
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "Nazwa może zawierać tylko małe litery i cyfry."
  }
}

variable "resource_group_name" {
  description = "Nazwa resource group"
  type        = string
}

variable "location" {
  description = "Lokalizacja zasobów"
  type        = string
  
  validation {
    condition     = contains(["North Europe", "West Europe"], var.location)
    error_message = "Dozwolone lokalizacje to: North Europe, West Europe."
  }
}

variable "account_tier" {
  description = "Tier konta storage"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier musi być: Standard lub Premium."
  }
}

variable "account_replication_type" {
  description = "Typ replikacji"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Nieprawidłowy typ replikacji."
  }
}

variable "containers" {
  description = "Lista kontenerów do utworzenia"
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
  
  validation {
    condition = alltrue([
      for container in var.containers : 
        contains(["private", "blob", "container"], container.container_access_type)
    ])
    error_message = "container_access_type musi być: private, blob lub container."
  }
}

variable "network_rules" {
  description = <<-EOT
    Konfiguracja reguł sieciowych:
      • ip_rules - Lista dozwolonych adresów IP
      • subnet_ids - Lista dozwolonych subnet IDs
      • default_action - Domyślna akcja (Allow/Deny)
  EOT
  type = object({
    ip_rules       = optional(list(string), [])
    subnet_ids     = optional(list(string), [])
    default_action = optional(string, "Allow")
  })
  default = {}
}

variable "enable_secure_transfer" {
  description = "Czy wymagać bezpiecznego transferu (HTTPS)"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimalna wersja TLS"
  type        = string
  default     = "TLS1_2"
  
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Dozwolone wartości: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "tags" {
  description = "Mapa tagów do przypisania do zasobów"
  type        = map(string)
  default     = {}
}
```

### main.tf

```hcl
# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  
  # Ustawienia bezpieczeństwa
  enable_https_traffic_only = var.enable_secure_transfer
  min_tls_version          = var.min_tls_version
  
  # Szyfrowanie
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
  }
  
  # Reguły sieciowe
  dynamic "network_rules" {
    for_each = length(var.network_rules.ip_rules) > 0 || length(var.network_rules.subnet_ids) > 0 ? [1] : []
    
    content {
      default_action             = var.network_rules.default_action
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.subnet_ids
      bypass                     = ["AzureServices"]
    }
  }
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      tags["created_date"],
      tags["created_by"]
    ]
  }
}

# Kontenery
resource "azurerm_storage_container" "containers" {
  for_each = { for c in var.containers : c.name => c }
  
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = each.value.container_access_type
}

# Generowanie SAS token
data "azurerm_storage_account_sas" "main" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = true
  
  resource_types {
    service   = true
    container = true
    object    = true
  }
  
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  
  start  = timestamp()
  expiry = timeadd(timestamp(), "8760h") # 1 rok
  
  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
    tag     = true
    filter  = true
  }
}
```

### outputs.tf

```hcl
output "id" {
  description = "ID konta storage"
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "Nazwa konta storage"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "sas_token" {
  description = "SAS token dla dostępu do storage"
  value       = data.azurerm_storage_account_sas.main.sas
  sensitive   = true
}

output "container_ids" {
  description = "Mapa nazw kontenerów do ich ID"
  value       = { for k, v in azurerm_storage_container.containers : k => v.id }
}
```

### versions.tf

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75.0"
    }
  }
}
```

### examples/simple/main.tf

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-storage-example"
  location = "North Europe"
}

module "storage" {
  source = "../../"
  
  name                = "stgexample${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

output "storage_account_name" {
  value = module.storage.name
}

output "storage_account_endpoint" {
  value = module.storage.primary_blob_endpoint
}
```

### examples/complete/main.tf

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-storage-complete"
  location = "North Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-storage"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  
  service_endpoints = ["Microsoft.Storage"]
}

module "storage" {
  source = "../../"
  
  name                     = "stgcomplete${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  account_tier            = "Premium"
  account_replication_type = "ZRS"
  
  # Kontenery
  containers = [
    {
      name                  = "data"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
    },
    {
      name                  = "backups"
      container_access_type = "private"
    }
  ]
  
  # Reguły sieciowe
  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]  # Przykładowy IP
    subnet_ids     = [azurerm_subnet.example.id]
  }
  
  # Tagi
  tags = {
    Environment = "Production"
    Project     = "CompleteExample"
    CostCenter  = "IT-123"
    Owner       = "team@example.com"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Outputs
output "storage_account_name" {
  value = module.storage.name
}

output "storage_containers" {
  value = module.storage.container_ids
}

output "storage_endpoint" {
  value = module.storage.primary_blob_endpoint
}
```

## Przykład 2: Zaawansowany moduł Virtual Network

### Struktura modułu z sub-modułami

```
terraform-azurerm-advanced-vnet/
├── modules/
│   ├── subnet/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── network-security-group/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── route-table/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── examples/
│   ├── simple/
│   └── hub-spoke/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

### Główny moduł - variables.tf

```hcl
variable "name" {
  description = "Nazwa Virtual Network"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-._]+$", var.name))
    error_message = "Nazwa musi zaczynać się od litery i może zawierać litery, cyfry, myślniki, kropki i podkreślenia."
  }
}

variable "resource_group_name" {
  description = "Nazwa resource group"
  type        = string
}

variable "location" {
  description = "Lokalizacja zasobów"
  type        = string
}

variable "address_space" {
  description = "Przestrzeń adresowa VNET (CIDR)"
  type        = list(string)
  
  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "Każdy wpis w address_space musi być prawidłowym CIDR."
  }
}

variable "dns_servers" {
  description = "Lista custom DNS servers"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip in var.dns_servers : can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", ip))
    ])
    error_message = "Każdy DNS server musi być prawidłowym adresem IP."
  }
}

variable "subnets" {
  description = "Konfiguracja subnetów"
  type = list(object({
    name                                      = string
    address_prefixes                          = list(string)
    service_endpoints                         = optional(list(string), [])
    private_endpoint_network_policies_enabled = optional(bool, false)
    private_link_service_network_policies_enabled = optional(bool, false)
    
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }), null)
    
    network_security_group = optional(object({
      name = string
      rules = list(object({
        name                       = string
        description               = optional(string)
        priority                  = number
        direction                 = string
        access                    = string
        protocol                  = string
        source_port_range         = optional(string)
        source_port_ranges        = optional(list(string))
        destination_port_range    = optional(string)
        destination_port_ranges   = optional(list(string))
        source_address_prefix     = optional(string)
        source_address_prefixes   = optional(list(string))
        destination_address_prefix = optional(string)
        destination_address_prefixes = optional(list(string))
      }))
    }), null)
    
    route_table = optional(object({
      name = string
      routes = list(object({
        name                   = string
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = optional(string)
      }))
    }), null)
  }))
  
  validation {
    condition = alltrue([
      for subnet in var.subnets : alltrue([
        for prefix in subnet.address_prefixes : can(cidrhost(prefix, 0))
      ])
    ])
    error_message = "Każdy address_prefix w subnets musi być prawidłowym CIDR."
  }
}

variable "enable_ddos_protection" {
  description = "Czy włączyć DDoS Protection"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "ID DDoS Protection Plan (wymagane gdy enable_ddos_protection = true)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tagi do przypisania do zasobów"
  type        = map(string)
  default     = {}
}
```

### Główny moduł - main.tf

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  
  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

# Network Security Groups
module "network_security_group" {
  source = "./modules/network-security-group"
  
  for_each = {
    for subnet in var.subnets : subnet.name => subnet.network_security_group
    if subnet.network_security_group != null
  }
  
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = each.value.rules
  tags                = var.tags
}

# Route Tables
module "route_table" {
  source = "./modules/route-table"
  
  for_each = {
    for subnet in var.subnets : subnet.name => subnet.route_table
    if subnet.route_table != null
  }
  
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  routes              = each.value.routes
  tags                = var.tags
}

# Subnets
module "subnet" {
  source = "./modules/subnet"
  
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }
  
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  
  service_endpoints                         = each.value.service_endpoints
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  
  delegation = each.value.delegation
  
  network_security_group_id = each.value.network_security_group != null ? 
    module.network_security_group[each.key].id : null
    
  route_table_id = each.value.route_table != null ? 
    module.route_table[each.key].id : null
}
```

### Sub-moduł subnet - main.tf

```hcl
resource "azurerm_subnet" "main" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes
  
  service_endpoints                         = var.service_endpoints
  private_endpoint_network_policies_enabled = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  
  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []
    
    content {
      name = delegation.value.name
      
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Przypisanie NSG do subnetu
resource "azurerm_subnet_network_security_group_association" "main" {
  count = var.network_security_group_id != null ? 1 : 0
  
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = var.network_security_group_id
}

# Przypisanie Route Table do subnetu
resource "azurerm_subnet_route_table_association" "main" {
  count = var.route_table_id != null ? 1 : 0
  
  subnet_id      = azurerm_subnet.main.id
  route_table_id = var.route_table_id
}
```

### Przykład użycia - Hub-Spoke

```hcl
# examples/hub-spoke/main.tf
provider "azurerm" {
  features {}
}

locals {
  hub_location = "North Europe"
  tags = {
    Environment = "Production"
    Pattern     = "Hub-Spoke"
    Project     = "NetworkingExample"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-networking"
  location = local.hub_location
  tags     = local.tags
}

resource "azurerm_resource_group" "spokes" {
  for_each = toset(["prod", "dev", "shared"])
  
  name     = "rg-spoke-${each.key}"
  location = local.hub_location
  tags     = local.tags
}

# Hub VNET
module "hub_vnet" {
  source = "../../"
  
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name             = "GatewaySubnet"  # Specjalna nazwa dla Gateway
      address_prefixes = ["10.0.1.0/27"]
    },
    {
      name             = "AzureFirewallSubnet"  # Specjalna nazwa dla Firewall
      address_prefixes = ["10.0.2.0/24"]
    },
    {
      name             = "management"
      address_prefixes = ["10.0.3.0/24"]
      
      network_security_group = {
        name = "nsg-hub-management"
        rules = [
          {
            name                       = "AllowRDPFromBastion"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "3389"
            source_address_prefix      = "10.0.4.0/24"  # Bastion subnet
            destination_address_prefix = "*"
          },
          {
            name                       = "AllowSSHFromBastion"
            priority                   = 110
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "22"
            source_address_prefix      = "10.0.4.0/24"  # Bastion subnet
            destination_address_prefix = "*"
          }
        ]
      }
    },
    {
      name             = "AzureBastionSubnet"  # Specjalna nazwa dla Bastion
      address_prefixes = ["10.0.4.0/24"]
    }
  ]
  
  tags = local.tags
}

# Spoke VNETs
module "spoke_vnets" {
  source = "../../"
  
  for_each = {
    prod = {
      address_space = ["10.1.0.0/16"]
      subnets = [
        {
          name             = "web"
          address_prefixes = ["10.1.1.0/24"]
          service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
          
          network_security_group = {
            name = "nsg-prod-web"
            rules = [
              {
                name                       = "AllowHTTPSFromInternet"
                priority                   = 100
                direction                  = "Inbound"
                access                     = "Allow"
                protocol                   = "Tcp"
                source_port_range          = "*"
                destination_port_range     = "443"
                source_address_prefix      = "Internet"
                destination_address_prefix = "*"
              }
            ]
          }
        },
        {
          name             = "app"
          address_prefixes = ["10.1.2.0/24"]
          
          route_table = {
            name = "rt-prod-app"
            routes = [
              {
                name                   = "ToFirewall"
                address_prefix         = "0.0.0.0/0"
                next_hop_type          = "VirtualAppliance"
                next_hop_in_ip_address = "10.0.2.4"  # Firewall IP
              }
            ]
          }
        },
        {
          name             = "db"
          address_prefixes = ["10.1.3.0/24"]
          private_endpoint_network_policies_enabled = true
        }
      ]
    }
    
    dev = {
      address_space = ["10.2.0.0/16"]
      subnets = [
        {
          name             = "default"
          address_prefixes = ["10.2.1.0/24"]
        }
      ]
    }
    
    shared = {
      address_space = ["10.3.0.0/16"]
      subnets = [
        {
          name             = "services"
          address_prefixes = ["10.3.1.0/24"]
          service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
        }
      ]
    }
  }
  
  name                = "vnet-spoke-${each.key}"
  resource_group_name = azurerm_resource_group.spokes[each.key].name
  location            = azurerm_resource_group.spokes[each.key].location
  address_space       = each.value.address_space
  subnets            = each.value.subnets
  
  tags = merge(local.tags, {
    Spoke = each.key
  })
}

# Peering Hub -> Spokes
resource "azurerm_virtual_network_peering" "hub_to_spokes" {
  for_each = module.spoke_vnets
  
  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = each.value.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# Peering Spokes -> Hub
resource "azurerm_virtual_network_peering" "spokes_to_hub" {
  for_each = module.spoke_vnets
  
  name                      = "peer-${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.spokes[each.key].name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = module.hub_vnet.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false  # Zmień na true po utworzeniu Gateway
}

# Outputs
output "hub_vnet_id" {
  value = module.hub_vnet.id
}

output "spoke_vnet_ids" {
  value = { for k, v in module.spoke_vnets : k => v.id }
}

output "all_subnet_ids" {
  value = merge(
    { for k, v in module.hub_vnet.subnet_ids : "hub-${k}" => v },
    { 
      for spoke_key, spoke_module in module.spoke_vnets : 
        spoke_key => spoke_module.subnet_ids
    }
  )
}
```

## Przykład 3: Moduł z integracją Key Vault i Diagnostic Settings

### Moduł App Service z pełną konfiguracją

```hcl
# terraform-azurerm-secure-app-service/main.tf

# Generowanie bezpiecznego hasła
resource "random_password" "sql_admin" {
  count = var.create_sql_database ? 1 : 0
  
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

# Przechowywanie hasła w Key Vault
resource "azurerm_key_vault_secret" "sql_password" {
  count = var.create_sql_database ? 1 : 0
  
  name         = "${var.name}-sql-admin-password"
  value        = random_password.sql_admin[0].result
  key_vault_id = var.key_vault_id
  
  content_type = "password"
  
  lifecycle {
    ignore_changes = [value]
  }
}

# SQL Server (opcjonalny)
resource "azurerm_mssql_server" "main" {
  count = var.create_sql_database ? 1 : 0
  
  name                         = "${var.name}-sql"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin[0].result
  
  minimum_tls_version = "1.2"
  
  public_network_access_enabled = false
  
  azuread_administrator {
    login_username = var.sql_ad_admin_login
    object_id      = var.sql_ad_admin_object_id
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  count = var.create_sql_database ? 1 : 0
  
  name           = "${var.name}-db"
  server_id      = azurerm_mssql_server.main[0].id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = var.database_max_size_gb
  read_scale     = var.database_read_scale
  sku_name       = var.database_sku
  zone_redundant = var.database_zone_redundant
  
  threat_detection_policy {
    state                      = "Enabled"
    email_addresses           = var.security_alert_emails
    retention_days            = 30
    storage_endpoint          = var.threat_detection_storage_endpoint
    storage_account_access_key = var.threat_detection_storage_key
  }
  
  tags = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.app_service_plan_sku
  
  tags = var.tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  count = var.os_type == "Linux" ? 1 : 0
  
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  
  https_only = true
  
  site_config {
    always_on                = var.always_on
    ftps_state              = "Disabled"
    http2_enabled           = true
    minimum_tls_version     = "1.2"
    vnet_route_all_enabled  = true
    
    # Health check
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 5
    
    # IP Restrictions
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      
      content {
        name       = ip_restriction.value.name
        action     = ip_restriction.value.action
        ip_address = ip_restriction.value.ip_address
        priority   = ip_restriction.value.priority
      }
    }
    
    # Application stack
    application_stack {
      docker_image     = var.docker_image
      docker_image_tag = var.docker_image_tag
    }
    
    # CORS
    cors {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = var.cors_support_credentials
    }
  }
  
  # App Settings
  app_settings = merge(
    var.app_settings,
    {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = var.application_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_connection_string
      "DOCKER_REGISTRY_SERVER_URL"           = var.docker_registry_url
      "DOCKER_REGISTRY_SERVER_USERNAME"      = var.docker_registry_username
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE"  = "false"
    },
    var.create_sql_database ? {
      "SQL_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_connection_string[0].id})"
    } : {}
  )
  
  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
  
  # Managed Identity
  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? var.user_assigned_identity_ids : null
  }
  
  # Backup
  dynamic "backup" {
    for_each = var.enable_backup ? [1] : []
    
    content {
      name                = "${var.name}-backup"
      enabled             = true
      storage_account_url = var.backup_storage_account_url
      
      schedule {
        frequency_interval       = var.backup_frequency_interval
        frequency_unit          = var.backup_frequency_unit
        retention_period_days   = var.backup_retention_days
        start_time              = var.backup_start_time
      }
    }
  }
  
  # Logs
  logs {
    detailed_error_messages = var.enable_detailed_error_messages
    failed_request_tracing  = var.enable_failed_request_tracing
    
    application_logs {
      file_system_level = var.application_logs_file_system_level
      
      azure_blob_storage {
        level             = var.application_logs_blob_level
        retention_in_days = var.application_logs_retention_days
        sas_url          = var.application_logs_sas_url
      }
    }
    
    http_logs {
      azure_blob_storage {
        retention_in_days = var.http_logs_retention_days
        sas_url          = var.http_logs_sas_url
      }
    }
  }
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_REGISTRY_SERVER_PASSWORD"],
      tags["deployment_id"]
    ]
  }
}

# Private Endpoint dla App Service
resource "azurerm_private_endpoint" "app_service" {
  count = var.enable_private_endpoint ? 1 : 0
  
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  
  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_linux_web_app.main[0].id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  
  tags = var.tags
}

# Key Vault Access Policy dla App Service
resource "azurerm_key_vault_access_policy" "app_service" {
  count = var.identity_type != "None" ? 1 : 0
  
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].identity[0].principal_id : azurerm_windows_web_app.main[0].identity[0].principal_id
  
  secret_permissions = [
    "Get",
    "List"
  ]
}

# Connection String w Key Vault
resource "azurerm_key_vault_secret" "sql_connection_string" {
  count = var.create_sql_database ? 1 : 0
  
  name  = "${var.name}-sql-connection-string"
  value = "Server=tcp:${azurerm_mssql_server.main[0].fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main[0].name};Persist Security Info=False;User ID=${azurerm_mssql_server.main[0].administrator_login};Password=${random_password.sql_admin[0].result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  
  key_vault_id = var.key_vault_id
  content_type = "connection-string"
  
  lifecycle {
    ignore_changes = [value]
  }
}

# Diagnostic Settings dla App Service
module "app_service_diagnostics" {
  source = "../terraform-azurerm-diagnostic-settings"
  
  count = var.enable_diagnostics ? 1 : 0
  
  target_resource_id         = azurerm_linux_web_app.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  logs = [
    {
      category = "AppServiceHTTPLogs"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    },
    {
      category = "AppServiceConsoleLogs"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    },
    {
      category = "AppServiceAppLogs"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    },
    {
      category = "AppServiceAuditLogs"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 90
      }
    }
  ]
  
  metrics = [
    {
      category = "AllMetrics"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    }
  ]
}

# Diagnostic Settings dla SQL Database
module "sql_diagnostics" {
  source = "../terraform-azurerm-diagnostic-settings"
  
  count = var.create_sql_database && var.enable_diagnostics ? 1 : 0
  
  target_resource_id         = azurerm_mssql_database.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  logs = [
    {
      category = "SQLSecurityAuditEvents"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 90
      }
    },
    {
      category = "QueryStoreRuntimeStatistics"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    }
  ]
  
  metrics = [
    {
      category = "AllMetrics"
      enabled  = true
      retention_policy = {
        enabled = true
        days    = 30
      }
    }
  ]
}

# Alerting
resource "azurerm_monitor_metric_alert" "high_cpu" {
  count = var.enable_monitoring_alerts ? 1 : 0
  
  name                = "${var.name}-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_web_app.main[0].id]
  description         = "Alert when CPU usage is too high"
  
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  
  window_size        = "PT5M"
  frequency          = "PT1M"
  severity           = 2
  
  action {
    action_group_id = var.action_group_id
  }
  
  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "high_memory" {
  count = var.enable_monitoring_alerts ? 1 : 0
  
  name                = "${var.name}-high-memory"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_web_app.main[0].id]
  description         = "Alert when memory usage is too high"
  
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }
  
  window_size        = "PT5M"
  frequency          = "PT1M"
  severity           = 2
  
  action {
    action_group_id = var.action_group_id
  }
  
  tags = var.tags
}

# Auto-scaling
resource "azurerm_monitor_autoscale_setting" "main" {
  count = var.enable_autoscaling ? 1 : 0
  
  name                = "${var.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id
  
  profile {
    name = "default"
    
    capacity {
      default = var.autoscale_default_instances
      minimum = var.autoscale_minimum_instances
      maximum = var.autoscale_maximum_instances
    }
    
    # Scale out rule
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }
      
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
    
    # Scale in rule
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }
      
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
  
  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrators = true
      custom_emails                         = var.autoscale_notification_emails
    }
  }
  
  tags = var.tags
}

data "azurerm_client_config" "current" {}
```

## Podsumowanie

Te przykłady pokazują praktyczne zastosowanie najlepszych praktyk:

1. **Struktura modułu** - czytelna organizacja plików
2. **Walidacja zmiennych** - kompleksowa z pomocnymi błędami
3. **Bezpieczeństwo** - domyślnie bezpieczne ustawienia
4. **Elastyczność** - użycie optional() i dynamic blocks
5. **Integracje** - Key Vault, Diagnostic Settings, Private Endpoints
6. **Monitoring** - alerty i autoskalowanie
7. **Lifecycle management** - ignorowanie automatycznych zmian

Każdy przykład można dostosować do własnych potrzeb, zachowując przedstawione wzorce i praktyki.