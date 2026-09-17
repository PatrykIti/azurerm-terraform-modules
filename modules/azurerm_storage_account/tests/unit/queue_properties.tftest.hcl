# Queue properties opt-in contract tests
#
# Proves the queue-properties resource is genuinely caller-controlled:
# omitted input creates no azurerm_storage_account_queue_properties resource,
# while an explicit queue_properties value creates exactly one.

mock_provider "azurerm" {}

variables {
  name                = "testsa123456"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

# Omitted queue_properties (default null) must create no queue-properties resource
run "queue_properties_omitted_creates_nothing" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account_queue_properties.queue_properties) == 0
    error_message = "Omitted queue_properties must create no queue-properties resource"
  }
}

# Explicit empty object must enable queue logging with the documented defaults
run "queue_properties_empty_object_enables_logging" {
  command = plan

  variables {
    queue_properties = {}
  }

  assert {
    condition     = length(azurerm_storage_account_queue_properties.queue_properties) == 1
    error_message = "Explicit queue_properties = {} must create exactly one queue-properties resource"
  }

  assert {
    condition     = var.queue_properties.logging.delete == true && var.queue_properties.logging.read == true && var.queue_properties.logging.write == true
    error_message = "Explicit queue_properties = {} must fill logging with the documented defaults"
  }
}

# Explicit logging values must be forwarded verbatim
run "queue_properties_explicit_logging_forwarded" {
  command = plan

  variables {
    queue_properties = {
      logging = {
        delete                = false
        read                  = false
        write                 = false
        version               = "2.0"
        retention_policy_days = 10
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_account_queue_properties.queue_properties) == 1
    error_message = "Explicit queue_properties.logging must create exactly one queue-properties resource"
  }

  assert {
    condition     = var.queue_properties.logging.version == "2.0" && var.queue_properties.logging.retention_policy_days == 10
    error_message = "Explicit logging values must be forwarded verbatim"
  }
}
