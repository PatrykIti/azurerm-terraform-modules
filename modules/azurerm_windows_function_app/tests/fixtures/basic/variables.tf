variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "module_tags" {
  description = "Tags applied to the module under test"
  type        = map(string)
  default = {
    Environment = "Test"
    TestType    = "Basic"
    Owner       = "terratest"
  }
}

variable "app_settings" {
  description = "Additional app settings for the Function App"
  type        = map(string)
  default     = {}
}
