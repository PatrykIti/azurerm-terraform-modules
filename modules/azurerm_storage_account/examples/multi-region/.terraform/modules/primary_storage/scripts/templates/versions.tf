terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
      version = "4.35.0" # Pinned to ensure consistent behavior
    }
  }
}