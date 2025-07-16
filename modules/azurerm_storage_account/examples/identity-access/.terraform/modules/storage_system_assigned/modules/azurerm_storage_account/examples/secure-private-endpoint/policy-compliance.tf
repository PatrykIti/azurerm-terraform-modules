# ==============================================================================
# Azure Policy Compliance for Storage Security
# ==============================================================================

# Policy Assignment: Storage Account Encryption
resource "azurerm_resource_group_policy_assignment" "storage_encryption" {
  count                = var.enable_azure_policy_compliance ? 1 : 0
  name                 = "storage-encryption-policy"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25"
  display_name         = "Storage accounts should use customer-managed key for encryption"
  description          = "Enforce customer-managed keys for storage account encryption"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Policy Assignment: HTTPS Only
resource "azurerm_resource_group_policy_assignment" "https_only" {
  count                = var.enable_azure_policy_compliance ? 1 : 0
  name                 = "storage-https-only"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  display_name         = "Secure transfer to storage accounts should be enabled"
  description          = "Enforce HTTPS-only traffic to storage accounts"

  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
  })
}

# Policy Assignment: Network Restrictions
resource "azurerm_resource_group_policy_assignment" "network_restrictions" {
  count                = var.enable_azure_policy_compliance ? 1 : 0
  name                 = "storage-network-restrict"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a1a9cdf-e04d-429a-8416-3bfb72a1b26f"
  display_name         = "Storage accounts should restrict network access"
  description          = "Network access to storage accounts should be restricted"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Policy Assignment: Private Endpoint Usage
resource "azurerm_resource_group_policy_assignment" "private_endpoints" {
  count                = var.enable_azure_policy_compliance ? 1 : 0
  name                 = "storage-private-endpoints"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6edd7eda-6dd8-40f7-810d-67160c639cd9"
  display_name         = "Storage accounts should use private link"
  description          = "Enforce private endpoints for storage accounts"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Policy Assignment: Infrastructure Encryption
resource "azurerm_resource_group_policy_assignment" "infrastructure_encryption" {
  count                = var.enable_azure_policy_compliance ? 1 : 0
  name                 = "storage-infra-encryption"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4733ea7b-a883-42fe-8cac-97454c2a9e4a"
  display_name         = "Storage accounts should have infrastructure encryption"
  description          = "Enable infrastructure encryption for additional layer of encryption"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# ==============================================================================
# Custom Policy Definitions
# ==============================================================================

# Custom Policy: Enforce Minimum TLS Version
resource "azurerm_policy_definition" "min_tls_version" {
  count        = var.enable_azure_policy_compliance ? 1 : 0
  name         = "storage-min-tls-1-2"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Storage accounts should use minimum TLS version 1.2"
  description  = "Enforce minimum TLS version 1.2 for storage accounts"

  metadata = jsonencode({
    category = "Storage"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field = "Microsoft.Storage/storageAccounts/minimumTlsVersion"
          less  = "TLS1_2"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Assign Custom Policy
resource "azurerm_resource_group_policy_assignment" "min_tls" {
  count                = var.enable_azure_policy_compliance ? 1 : 0
  name                 = "enforce-min-tls"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = azurerm_policy_definition.min_tls_version[0].id
  display_name         = "Enforce minimum TLS version 1.2"
  description          = "Deny creation of storage accounts with TLS version less than 1.2"
}

# ==============================================================================
# Compliance Reporting
# ==============================================================================

# Log Analytics Query for Policy Compliance
resource "azurerm_log_analytics_saved_search" "policy_compliance" {
  count                      = var.enable_azure_policy_compliance ? 1 : 0
  name                       = "StoragePolicyCompliance"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  category                   = "Compliance"
  display_name               = "Storage Account Policy Compliance Status"
  query                      = <<-QUERY
    AzureActivity
    | where CategoryValue == "Policy"
    | where Resource = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.1.0"
    | where Properties contains "Microsoft.Storage/storageAccounts"
    | summarize ComplianceStatus = count() by PolicyAssignmentName = tostring(Properties.policyAssignmentName), ComplianceState = tostring(Properties.complianceState)
    | order by ComplianceState asc
  QUERY

  tags = var.tags
}