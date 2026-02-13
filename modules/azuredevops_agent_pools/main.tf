# Azure DevOps Agent Pools

resource "azuredevops_agent_pool" "agent_pool" {
  name           = var.name
  auto_provision = var.auto_provision
  auto_update    = var.auto_update
  pool_type      = var.pool_type
}
