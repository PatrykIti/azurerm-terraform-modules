# Core Subnet Variables
variable "name" {
  description = "The name of the subnet. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 80
    error_message = "Subnet name must be between 1 and 80 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group where the Virtual Network exists."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network where this subnet should be created."
  type        = string
}

variable "address_prefixes" {
  description = "The address prefixes to use for the subnet. This is a list of IPv4 or IPv6 address ranges."
  type        = list(string)

  validation {
    condition = alltrue([
      for prefix in var.address_prefixes : can(cidrhost(prefix, 0))
    ])
    error_message = "Each address prefix must be a valid CIDR block (e.g., '10.0.1.0/24' for IPv4 or '2001:db8::/64' for IPv6)."
  }

  validation {
    condition     = length(var.address_prefixes) > 0
    error_message = "At least one address prefix must be specified."
  }
}


# Service Endpoints
variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global and Microsoft.Web."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for endpoint in var.service_endpoints : contains([
        "Microsoft.AzureActiveDirectory",
        "Microsoft.AzureCosmosDB",
        "Microsoft.ContainerRegistry",
        "Microsoft.EventHub",
        "Microsoft.KeyVault",
        "Microsoft.ServiceBus",
        "Microsoft.Sql",
        "Microsoft.Storage",
        "Microsoft.Storage.Global",
        "Microsoft.Web"
      ], endpoint)
    ])
    error_message = "Invalid service endpoint. Please check the list of valid service endpoints."
  }
}

# Service Endpoint Policies
variable "service_endpoint_policy_ids" {
  description = "The list of IDs of Service Endpoint Policies to associate with the subnet."
  type        = list(string)
  default     = []
}

# Subnet Delegation
variable "delegations" {
  description = "One or more delegation blocks for the subnet."
  type = map(object({
    name = string
    service_delegation = object({
      name    = string
      actions = optional(list(string), [])
    })
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.delegations : contains([
        "Microsoft.ApiManagement/service",
        "Microsoft.AzureCosmosDB/clusters",
        "Microsoft.BareMetal/AzureVMware",
        "Microsoft.BareMetal/CrayServers",
        "Microsoft.Batch/batchAccounts",
        "Microsoft.ContainerInstance/containerGroups",
        "Microsoft.ContainerService/managedClusters",
        "Microsoft.Databricks/workspaces",
        "Microsoft.DBforMySQL/flexibleServers",
        "Microsoft.DBforMySQL/serversv2",
        "Microsoft.DBforPostgreSQL/flexibleServers",
        "Microsoft.DBforPostgreSQL/serversv2",
        "Microsoft.DBforPostgreSQL/singleServers",
        "Microsoft.HardwareSecurityModules/dedicatedHSMs",
        "Microsoft.Kusto/clusters",
        "Microsoft.Logic/integrationServiceEnvironments",
        "Microsoft.MachineLearningServices/workspaces",
        "Microsoft.Netapp/volumes",
        "Microsoft.Network/managedResolvers",
        "Microsoft.Orbital/orbitalGateways",
        "Microsoft.PowerPlatform/vnetaccesslinks",
        "Microsoft.ServiceFabricMesh/networks",
        "Microsoft.Sql/managedInstances",
        "Microsoft.Sql/servers",
        "Microsoft.StoragePool/diskPools",
        "Microsoft.StreamAnalytics/streamingJobs",
        "Microsoft.Synapse/workspaces",
        "Microsoft.Web/hostingEnvironments",
        "Microsoft.Web/serverFarms",
        "NGINX.NGINXPLUS/nginxDeployments",
        "PaloAltoNetworks.Cloudngfw/firewalls"
      ], v.service_delegation.name)
    ])
    error_message = "Invalid service delegation name. Please check the list of valid service delegations."
  }
}

# Network Policies
variable "private_endpoint_network_policies_enabled" {
  description = "Enable or Disable network policies for the private endpoint on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true."
  type        = bool
  default     = true
}

variable "private_link_service_network_policies_enabled" {
  description = "Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true."
  type        = bool
  default     = true
}

variable "associations" {
  description = <<-EOT
    List of parameters to associate other resources to Subnet:
      nat_gateway_id - ID of NAT gateway to associate with
      network_security_group_id - D of network security group to associate with
      route_table_id - ID of route table to associate with
  EOT
  type = object({
    nat_gateway = optional(object({
      id = string
    }), null)
    network_security_group = optional(object({
      id = string
    }), null)
    route_table = optional(object({
      id = string
    }), null)
  })
  default = null
}

