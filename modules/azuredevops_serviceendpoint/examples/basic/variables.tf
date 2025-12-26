variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "azurerm_endpoint_name" {
  description = "AzureRM service endpoint name."
  type        = string
  default     = "ado-azurerm-basic"
}

variable "azurerm_spn_tenantid" {
  description = "Tenant ID for the AzureRM service principal."
  type        = string
}

variable "azurerm_spn_client_id" {
  description = "Client ID for the AzureRM service principal."
  type        = string
}

variable "azurerm_spn_client_secret" {
  description = "Client secret for the AzureRM service principal."
  type        = string
  sensitive   = true
}

variable "azurerm_subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "azurerm_subscription_name" {
  description = "Azure subscription name."
  type        = string
}

variable "docker_endpoint_name" {
  description = "Docker registry service endpoint name."
  type        = string
  default     = "ado-docker-basic"
}

variable "docker_registry" {
  description = "Docker registry URL."
  type        = string
  default     = "https://index.docker.io/v1/"
}

variable "docker_username" {
  description = "Docker registry username."
  type        = string
}

variable "docker_email" {
  description = "Docker registry email."
  type        = string
}

variable "docker_password" {
  description = "Docker registry password."
  type        = string
  sensitive   = true
}

variable "docker_registry_type" {
  description = "Docker registry type."
  type        = string
  default     = "DockerHub"
}
