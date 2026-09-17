variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "northeurope"
}

variable "random_suffix" {
  description = "Random suffix for unique resource naming"
  type        = string
  default     = "00000000"
}

variable "app_settings" {
  description = "Application settings for the Function App"
  type        = map(string)
  default = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
  }
}

variable "module_tags" {
  description = "Tags applied to the module resources"
  type        = map(string)
  default = {
    Environment = "Test"
    TestType    = "Basic"
    CostCenter  = "Engineering"
    Owner       = "terratest"
  }
}
