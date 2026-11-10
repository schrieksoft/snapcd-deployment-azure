resource "snapcd_module" "base" {
  name                 = "base"
  namespace_id         = snapcd_namespace.platform.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/base"
  runner_id            = data.snapcd_runner.platform.id
}


resource "snapcd_module_input_from_literal" "base" {
  for_each = { for obj in [
    {
      name          = "resource_group_name"
      literal_value = local.name
      type          = "String"
      input_kind    = "Param"
    }
  ] : obj.name => obj }
  name          = each.value.name
  literal_value = each.value.literal_value
  input_kind    = each.value.input_kind
  type          = each.value.type
  module_id     = snapcd_module.base.id
}
