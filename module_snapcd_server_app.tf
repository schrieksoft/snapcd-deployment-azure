resource "snapcd_module" "snapcd_server_app" {
  name                 = "snapcd_server_app"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-server-app"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_literal" "snapcd_server_app" {
  for_each = { for obj in [
    {
      name          = "name"
      literal_value = var.snapcd_server_name
      type          = "String"
    },
    {
      name          = "key_vault_enabled"
      literal_value = var.key_vault_enabled
      type          = "NotString"
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
  module_id     = snapcd_module.snapcd_server_app.id
}

resource "snapcd_module_input_from_output" "snapcd_server_app" {
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
      name             = "public_hostname"
      output_name      = "public_hostname"
      output_module_id = snapcd_module.istio_infra.id
    },
  ] : obj.name => obj }

  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_server_app.id
}

resource "snapcd_module_input_from_output_set" "snapcd_server_app" {
  for_each = { for obj in [
    {
      name             = "from_snapcd_server_infra"
      output_module_id = snapcd_module.snapcd_server_infra.id
    },
    {
      name             = "from_snapcd_server_infra_config"
      output_module_id = snapcd_module.snapcd_server_infra_config.id
    },
  ] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_server_app.id
}

// The Certificate, Gateway and VirtualService in the release need the Istio and cert-manager CRDs and the issuers.
resource "snapcd_depends_on_module" "snapcd_server_app" {
  for_each = {
    istio                       = snapcd_module.istio.id
    cert_manager_cluster_issuer = snapcd_module.cert_manager_cluster_issuer.id
  }
  module_id            = snapcd_module.snapcd_server_app.id
  depends_on_module_id = each.value
}
