# azurerm_service_plan Module Security

## Overview

This document describes the security-relevant controls supported by the
`azurerm_service_plan` module and the boundaries of what an App Service Plan
can secure on its own.

## Security Scope

An App Service Plan controls shared hosting capacity, worker placement,
availability-zone balancing, and App Service Environment placement. It does not
configure application-level TLS, authentication, networking restrictions, or
secrets for the apps that run on top of the plan.

## Security Features

### 1) Isolation and Placement

- **App Service Environment support**: Set `service_plan.app_service_environment_id`
  with an isolated SKU to place the plan inside an App Service Environment v3.
- **Availability Zones**: Enable `service_plan.zone_balancing_enabled = true`
  with a supported SKU and `worker_count > 1` to spread capacity across zones.

### 2) Deterministic Scaling Controls

- **Fixed workers**: Set `service_plan.worker_count` for dedicated plans when
  you need deterministic capacity.
- **Per-site scaling**: Use `service_plan.per_site_scaling_enabled` when hosted
  apps require independent scale behavior.
- **Elastic Premium**: Use `service_plan.maximum_elastic_worker_count` for
  Elastic Premium plans, or Premium autoscale with explicit enablement.

### 3) Monitoring and Auditability

- **Diagnostic settings**: Configure `diagnostic_settings` to stream supported
  App Service Plan logs and metrics to Log Analytics, Storage, Event Hub, or a
  partner solution.
- **Tags**: Use resource tags for ownership, environment classification, and
  policy-based governance.

## Secure Configuration Example

A hardened operational baseline is provided in `examples/secure`, which shows:
- Premium plan capacity with zonal balancing
- Centralized diagnostics to Log Analytics
- Explicit production-style tagging

## Security Hardening Checklist

Before deploying to production:

- [ ] Use an isolated ASE-backed SKU when strict network isolation is required
- [ ] Enable zone balancing on supported SKUs with more than one worker
- [ ] Configure diagnostic settings and retain metrics/logs centrally
- [ ] Apply tags for ownership, environment, and compliance classification
- [ ] Keep app-level security controls in the modules that manage the apps

## Common Security Mistakes to Avoid

1) **Assuming the service plan secures hosted apps**
   ```hcl
   # Avoid assuming plan-level settings replace app-level TLS/auth controls.
   service_plan = {
     os_type  = "Linux"
     sku_name = "P1v3"
   }
   ```

2) **Using ASE placement with a non-isolated SKU**
   ```hcl
   # Avoid mixing App Service Environment placement with non-isolated SKUs.
   service_plan = {
     sku_name                   = "P1v3"
     app_service_environment_id = "/subscriptions/.../hostingEnvironments/example-ase"
   }
   ```

3) **Enabling zone balancing without enough workers**
   ```hcl
   # Avoid enabling zone balancing with only one worker.
   service_plan = {
     sku_name               = "P1v3"
     worker_count           = 1
     zone_balancing_enabled = true
   }
   ```

---

**Module Version**: vUnreleased
