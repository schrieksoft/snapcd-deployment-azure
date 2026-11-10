resource "snapcd_module" "snapcd_runner_infra_config" {
  name                 = "snapcd_runner_infra_config"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-runner-infra-config"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_literal" "snapcd_runner_infra_config" {
  for_each = { for obj in [
    {
      name          = "name"
      literal_value = var.snapcd_runner_name
      type          = "String"
    },
    {
      name          = "key_vault_enabled"
      literal_value = var.key_vault_enabled
      type          = "NotString"
    },
  ] : obj.name => obj }

  name          = each.value.name
  literal_value = each.value.literal_value
  type          = each.value.type
  input_kind    = "Param"
  module_id     = snapcd_module.snapcd_runner_infra_config.id
}

resource "snapcd_module_input_from_output_set" "snapcd_runner_infra_config" {
  for_each = { for obj in [
    {
      name             = "from_snapcd_runner_infra"
      output_module_id = snapcd_module.snapcd_runner_infra.id
    },
  ] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_runner_infra_config.id
}
