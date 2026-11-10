resource "snapcd_module" "snapcd_runner_app" {
  name                 = "snapcd_runner_app"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-runner-app"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_literal" "snapcd_runner_app" {
  for_each = { for obj in [
    {
      name          = "chart_version"
      literal_value = local.snapcd_chart_version
    },
  ] : obj.name => obj }

  name          = each.value.name
  literal_value = each.value.literal_value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.snapcd_runner_app.id
}

resource "snapcd_module_input_from_output" "snapcd_runner_app" {
  for_each = { for obj in concat([
    {
      name             = "cluster_host"
      output_name      = "cluster_host"
      output_module_id = snapcd_module.cluster.id
    },
    {
      name             = "cluster_ca_certificate"
      output_name      = "cluster_ca_certificate"
      output_module_id = snapcd_module.cluster.id
    },
    {
      name             = "cluster_token"
      output_name      = "cluster_token"
      output_module_id = snapcd_module.cluster.id
    },
    {
      name             = "server_url"
      output_name      = "snapcd_server_url_in_cluster"
      output_module_id = snapcd_module.snapcd_server_app.id
    },
    ], var.key_vault_enabled ? [] : [
    {
      name             = "snapcd_runner_client_secret"
      output_name      = "snapcd_runner_client_secret"
      output_module_id = snapcd_module.snapcd_server_app.id
    },
  ]) : obj.name => obj }

  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_runner_app.id
}

resource "snapcd_module_input_from_output_set" "snapcd_runner_app" {
  for_each = { for obj in var.key_vault_enabled ? [
    {
      name             = "from_snapcd_server_infra"
      output_module_id = local.snapcd_server_infra_id
    },
    {
      name             = "from_snapcd_server_infra_config"
      output_module_id = local.snapcd_server_infra_config_id
    },
    {
      name             = "from_snapcd_runner_infra"
      output_module_id = local.snapcd_runner_infra_id
    },
    {
      name             = "from_snapcd_runner_infra_config"
      output_module_id = local.snapcd_runner_infra_config_id
    },
  ] : [] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_runner_app.id
}
