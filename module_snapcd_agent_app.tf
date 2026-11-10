resource "snapcd_module" "snapcd_agent_app" {
  name                 = "snapcd_agent_app"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-agent-app"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_literal" "snapcd_agent_app" {
  for_each = { for obj in [
    {
      name          = "name"
      literal_value = var.snapcd_agent_name
      type          = "String"
    },
    {
      name          = "chart_version"
      literal_value = local.snapcd_chart_version
      type          = "String"
    },
  ] : obj.name => obj }

  name          = each.value.name
  literal_value = each.value.literal_value
  type          = each.value.type
  input_kind    = "Param"
  module_id     = snapcd_module.snapcd_agent_app.id
}

resource "snapcd_module_input_from_output" "snapcd_agent_app" {
  for_each = { for obj in [
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
  ] : obj.name => obj }

  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_agent_app.id
}

resource "snapcd_module_input_from_output_set" "snapcd_agent_app" {
  for_each = { for obj in [
    {
      name             = "from_snapcd_server_infra"
      output_module_id = snapcd_module.snapcd_server_infra.id
    },
    {
      name             = "from_snapcd_server_infra_config"
      output_module_id = snapcd_module.snapcd_server_infra_config.id
    },
    {
      name             = "from_snapcd_agent_infra"
      output_module_id = snapcd_module.snapcd_agent_infra.id
    },
  ] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_agent_app.id
}

data "snapcd_stack_secret" "claude_oauth_token" {
  count    = var.claude_oauth_token_secret_name == "" ? 0 : 1
  name     = var.claude_oauth_token_secret_name
  stack_id = snapcd_stack.bootstrap.id
}

resource "snapcd_module_input_from_secret" "snapcd_agent_app_claude_oauth_token" {
  count      = var.claude_oauth_token_secret_name == "" ? 0 : 1
  name       = "claude_oauth_token"
  secret_id  = data.snapcd_stack_secret.claude_oauth_token[0].id
  input_kind = "Param"
  module_id  = snapcd_module.snapcd_agent_app.id
}
