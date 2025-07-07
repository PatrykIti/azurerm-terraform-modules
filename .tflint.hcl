# TFLint configuration file for Terraform Azure modules repository

# Enable the azurerm plugin
plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Enable the terraform plugin for core Terraform rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Core Terraform rules configuration
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
  style   = "flexible"
}

rule "terraform_naming_convention" {
  enabled = true
  
  # Custom naming formats
  format = "snake_case"
  
  # Resource naming convention
  resource {
    format = "snake_case"
  }
  
  # Variable naming convention
  variable {
    format = "snake_case"
  }
  
  # Output naming convention
  output {
    format = "snake_case"
  }
  
  # Local naming convention
  locals {
    format = "snake_case"
  }
  
  # Module naming convention
  module {
    format = "snake_case"
  }
  
  # Data source naming convention
  data {
    format = "snake_case"
  }
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_module_version" {
  enabled = true
}

# Azure-specific rules
rule "azurerm_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "ManagedBy", "Project"]
  
  # Exclude certain resource types that don't support tags
  exclude = [
    "azurerm_role_assignment",
    "azurerm_role_definition",
    "azurerm_policy_assignment",
    "azurerm_management_lock",
    "azurerm_resource_group"
  ]
}

# Additional Azure best practice rules
rule "azurerm_network_security_group_separate_resource" {
  enabled = true
}

rule "azurerm_storage_account_public_access_disabled" {
  enabled = true
}

# Configuration for module-specific overrides
config {
  # Allow module developers to override certain rules in their module directories
  module = true
}