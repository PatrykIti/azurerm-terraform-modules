variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "zip_deploy_file" {
  description = "Path to the ZIP package to deploy."
  type        = string
  default     = "./function.zip"
}
