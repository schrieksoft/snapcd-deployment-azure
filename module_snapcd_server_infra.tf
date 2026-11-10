resource "snapcd_module" "snapcd_server_infra" {
  count                = var.key_vault_enabled ? 1 : 0
  name                 = "snapcd_server_infra"
  namespace_id         = snapcd_namespace.platform.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-server-infra"
  runner_id            = data.snapcd_runner.platform.id
}

resource "snapcd_module_input_from_output" "snapcd_server_infra" {
  for_each = { for obj in var.key_vault_enabled ? [
    {
      name             = "cluster_name"
      output_name      = "cluster_name"
      output_module_id = snapcd_module.cluster.id
    },
    {
      name             = "cluster_oidc_issuer_url"
      output_name      = "cluster_oidc_issuer_url"
      output_module_id = snapcd_module.cluster.id
    },
  ] : [] : obj.name => obj }

  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = local.snapcd_server_infra_id
}

resource "snapcd_module_input_from_output_set" "snapcd_server_infra" {
  for_each = { for obj in var.key_vault_enabled ? [
    {
      name             = "from_base"
      output_module_id = snapcd_module.base.id
    },
  ] : [] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = local.snapcd_server_infra_id
}
