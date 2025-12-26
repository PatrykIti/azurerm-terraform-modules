provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "../../"

  project_id = var.project_id

  webhooks = [
    {
      key = "build-completed"
      url = var.webhook_url
      build_completed = {
        definition_name = var.pipeline_name
        build_status    = "Succeeded"
      }
    }
  ]

  storage_queue_hooks = [
    {
      key          = "queue-run-completed"
      account_name = var.account_name
      account_key  = var.account_key
      queue_name   = var.queue_name
      visi_timeout = 30
      run_state_changed_event = {
        run_state_filter  = "Completed"
        run_result_filter = "Succeeded"
      }
    }
  ]
}
