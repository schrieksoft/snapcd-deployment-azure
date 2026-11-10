// Ids of the Modules that exist only with key_vault_enabled, null without it.
locals {
  snapcd_server_infra_id        = one(snapcd_module.snapcd_server_infra[*].id)
  snapcd_server_infra_config_id = one(snapcd_module.snapcd_server_infra_config[*].id)
  snapcd_runner_infra_id        = one(snapcd_module.snapcd_runner_infra[*].id)
  snapcd_runner_infra_config_id = one(snapcd_module.snapcd_runner_infra_config[*].id)
  snapcd_agent_infra_id         = one(snapcd_module.snapcd_agent_infra[*].id)
}
