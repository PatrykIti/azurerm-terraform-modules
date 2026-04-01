resource "azurerm_service_plan" "service_plan" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type                         = var.service_plan.os_type
  sku_name                        = var.service_plan.sku_name
  app_service_environment_id      = var.service_plan.app_service_environment_id
  premium_plan_auto_scale_enabled = var.service_plan.premium_plan_auto_scale_enabled
  maximum_elastic_worker_count    = var.service_plan.maximum_elastic_worker_count
  worker_count                    = var.service_plan.worker_count
  per_site_scaling_enabled        = var.service_plan.per_site_scaling_enabled
  zone_balancing_enabled          = var.service_plan.zone_balancing_enabled

  dynamic "timeouts" {
    for_each = var.service_plan.timeouts != null ? [var.service_plan.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = !var.service_plan.zone_balancing_enabled || (
        var.service_plan.worker_count != null &&
        var.service_plan.worker_count > 1
      )
      error_message = "service_plan.worker_count must be greater than 1 when service_plan.zone_balancing_enabled is true."
    }

    precondition {
      condition = var.service_plan.app_service_environment_id == null || contains([
        "I1v2",
        "I1mv2",
        "I2v2",
        "I2mv2",
        "I3v2",
        "I3mv2",
        "I4v2",
        "I4mv2",
        "I5v2",
        "I5mv2",
        "I6v2",
      ], var.service_plan.sku_name)
      error_message = "service_plan.app_service_environment_id requires an Isolated v2 SKU supported by App Service Environment v3."
    }

    precondition {
      condition = var.service_plan.maximum_elastic_worker_count == null || (
        startswith(var.service_plan.sku_name, "EP") ||
        (startswith(var.service_plan.sku_name, "P") && var.service_plan.premium_plan_auto_scale_enabled)
      )
      error_message = "service_plan.maximum_elastic_worker_count requires an Elastic Premium SKU or a Premium SKU with premium_plan_auto_scale_enabled set to true."
    }
  }
}
