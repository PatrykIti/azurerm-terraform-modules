terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}
