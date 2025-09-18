variable "random_suffix" {
  type        = string
  description = "A random suffix passed from the test to ensure unique resource names."
}

variable "location" {
  type        = string
  description = "The Azure region for the resources."
  default     = "northeurope"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources."
  default = {
    Environment = "Test"
    Scenario    = "Simple"
  }
}
