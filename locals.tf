locals {
  stack_name = "demo"
  name       = "platform"
  source_url = "git@github.com:schrieksoft/snapcd-deployment-azure.git"

  public_gateway_domain_name_label = "snapcd"

  // Charts from oci://ghcr.io/schrieksoft/charts, used for the Server, Runner and Agent.
  snapcd_chart_version = "0.1.12"

  before_hook_base = <<EOT
EOT
  
  snapcd_server_infra_id        = one(snapcd_module.snapcd_server_infra[*].id)
  snapcd_server_infra_config_id = one(snapcd_module.snapcd_server_infra_config[*].id)
  snapcd_runner_infra_id        = one(snapcd_module.snapcd_runner_infra[*].id)
  snapcd_runner_infra_config_id = one(snapcd_module.snapcd_runner_infra_config[*].id)
  snapcd_agent_infra_id         = one(snapcd_module.snapcd_agent_infra[*].id)
  
}
