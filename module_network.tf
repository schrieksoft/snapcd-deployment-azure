resource "snapcd_module" "network" {
  name                 = "network"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/network"
  runner_id            = data.snapcd_runner.bootstrap.id
}

resource "snapcd_module_input_from_literal" "network" {
  for_each = { for obj in [
    {
      name          = "vnet_name"
      literal_value = local.name
      type          = "String"
    },
  ] : obj.name => obj }

  name          = each.value.name
  type          = each.value.type
  literal_value = each.value.literal_value
  input_kind    = "Param"
  module_id     = snapcd_module.network.id
}

resource "snapcd_module_input_from_output_set" "network" {
  for_each = { for obj in [
    {
      name = "from_base"
    },

  ] : obj.name => obj }
  name             = each.value.name
  output_module_id = snapcd_module.base.id
  input_kind       = "Param"
  module_id        = snapcd_module.network.id
}
