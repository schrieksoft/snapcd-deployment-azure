resource "snapcd_module" "cluster" {
  name                 = "cluster"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/cluster"
  runner_id            = data.snapcd_runner.bootstrap.id
}




locals {
  system_node_pool = {
    enable_auto_scaling    = true
    enable_host_encryption = false
    enable_node_public_ip  = false
    min_count              = 1
    max_count              = 15
    max_pods               = 110
    os_disk_size_gb        = 32
    vm_size                = "Standard_B2s" //"Standard_B2s" // Using Standard_D2pls_v5 as Standard_B2s not availible in reagion at this time, Standard_D2pls_v5 has similar specs as Standard_B2s
  }

  general_node_pools = {
    "general" : {
      enable_auto_scaling    = true
      enable_host_encryption = false
      enable_node_public_ip  = false
      max_count              = 5
      max_pods               = 110
      min_count              = 0
      node_count             = 0
      os_disk_size_gb        = 32
      vm_size                = "standard_a2_v2"
      subnet_name            = "apps"
      node_taints            = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"] // must add this taint or terraform will try to remove it later
      priority               = "Spot"
      eviction_policy        = "Delete" // must add this or terraform will try to remove it later
      spot_max_price         = -1
      node_labels = {
        "priority" : "spot",
        "kubernetes.azure.com/scalesetpriority" : "spot" // must add this label or terraform will try to remove it later
      }
    }
    "d2s" : {
      enable_auto_scaling    = true
      enable_host_encryption = false
      enable_node_public_ip  = false
      max_count              = 3
      max_pods               = 110
      min_count              = 0
      node_count             = 0
      os_disk_size_gb        = 32
      vm_size                = "Standard_D2s_v3"
      subnet_name            = "apps"
      node_taints            = []
      priority               = "Regular"
      eviction_policy        = "" // This only used if priority is set to "Spot"
      node_labels = {
        "priority" : "regular",
      }
    }
  }
}
resource "snapcd_module_input_from_literal" "cluster" {
  for_each = { for obj in [
    {
      name          = "administrator_object_ids"
      literal_value = jsonencode([var.administrator_object_id])
      type          = "NotString"
      input_kind    = "Param"
    },

    {
      name          = "system_node_pool"
      literal_value = jsonencode(local.system_node_pool)
      type          = "NotString"
      input_kind    = "Param"
    },
    {
      name          = "general_node_pools"
      literal_value = jsonencode(local.general_node_pools)
      type          = "NotString"
      input_kind    = "Param"
    },
    {
      name          = "name"
      literal_value = local.name
      type          = "String"
      input_kind    = "Param"
    },
    {
      name          = "kubernetes_version"
      literal_value = "1.36.2"
      type          = "String"
      input_kind    = "Param"
    },
  ] : obj.name => obj }

  name          = each.value.name
  type          = each.value.type
  literal_value = each.value.literal_value
  input_kind    = each.value.input_kind
  module_id     = snapcd_module.cluster.id
}

resource "snapcd_module_input_from_output_set" "cluster" {
  for_each = { for obj in [
    {
      name             = "from_base"
      output_module_id = snapcd_module.base.id
      input_kind       = "Param"
    },
    {
      name             = "from_network"
      output_module_id = snapcd_module.network.id
      input_kind       = "Param"
    },

  ] : obj.name => obj }
  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = each.value.input_kind
  module_id        = snapcd_module.cluster.id
}
