resource "snapcd_module" "snapcd_runner_infra" {
  name                 = "snapcd_runner_infra"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/snapcd-runner-infra"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_literal" "snapcd_runner_infra" {
  for_each = { for obj in [
    {
      name          = "name"
      literal_value = var.snapcd_runner_name
      type          = "String"
    },
  ] : obj.name => obj }

  name          = each.value.name
  literal_value = each.value.literal_value
  type          = each.value.type
  input_kind    = "Param"
  module_id     = snapcd_module.snapcd_runner_infra.id
}

resource "snapcd_module_input_from_output" "snapcd_runner_infra" {
  for_each = { for obj in [
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
  ] : obj.name => obj }

  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_runner_infra.id
}

resource "snapcd_module_input_from_output_set" "snapcd_runner_infra" {
  for_each = { for obj in [
    {
      name             = "from_base"
      output_module_id = snapcd_module.base.id
    },
  ] : obj.name => obj }

  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.snapcd_runner_infra.id
}
