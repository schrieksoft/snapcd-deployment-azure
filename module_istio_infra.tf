resource "snapcd_module" "istio_infra" {
  name                 = "istio_infra"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/istio-infra"
  runner_id            = data.snapcd_runner.bootstrap.id
}


resource "snapcd_module_input_from_literal" "istio_infra" {
  for_each = { for obj in [
    {
      name          = "private_gateway_reserved_ip"
      literal_value = "100.0.8.255"
      type          = "String"

    },
    {
      name          = "public_gateway_domain_name_label"
      literal_value = local.public_gateway_domain_name_label
      type          = "String"
    },
    {
      name          = "dns_zone_name"
      literal_value = var.dns_zone_name
      type          = "String"
    },
    {
      name          = "dns_zone_resource_group_name"
      literal_value = var.dns_zone_resource_group_name
      type          = "String"
    },
    {
      name          = "dns_record_name"
      literal_value = var.dns_record_name
      type          = "String"
    },
  ] : obj.name => obj }

  name          = each.value.name
  type          = each.value.type
  literal_value = each.value.literal_value
  input_kind    = "Param"
  module_id     = snapcd_module.istio_infra.id
}

resource "snapcd_module_input_from_output_set" "istio_infra" {
  for_each = { for obj in [
    {
      name             = "from_base"
      output_module_id = snapcd_module.base.id
    },
    {
      name             = "from_network"
      output_module_id = snapcd_module.network.id
    },
  ] : obj.name => obj }
  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = "Param"
  module_id        = snapcd_module.istio_infra.id
}