resource "snapcd_module" "snapcd_runner_infra_config" {
  count                = var.key_vault_enabled ? 1 : 0
  name                 = "snapcd_runner_infra_config"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-runner-infra-config"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_output_set" "snapcd_runner_infra_config" {
  for_each = { for obj in var.key_vault_enabled ? [
    {
      name             = "from_snapcd_runner_infra"
      output_module_id = local.snapcd_runner_infra_id
    },
  ] : [] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = local.snapcd_runner_infra_config_id
}
