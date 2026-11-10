resource "snapcd_module" "cert_manager_cluster_issuer" {
  name                 = "cert_manager_cluster_issuer"
  namespace_id         = snapcd_namespace.bootstrap.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "roots/k8s-cert-manager-cluster-issuer-letsencrypt"
  runner_id            = data.snapcd_runner.bootstrap.id
}


resource "snapcd_module_input_from_output" "cert_manager_cluster_issuer" {
  for_each = { for obj in [
    {
      name             = "extra_kubeconfig"
      output_name      = "cluster_kube_admin_config_raw"
      output_module_id = snapcd_module.cluster.id
      input_kind       = "Param"
    },

  ] : obj.name => obj }
  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = each.value.input_kind
  module_id        = snapcd_module.cert_manager_cluster_issuer.id
}

resource "snapcd_module_extra_file" "cert_manager_cluster_issuer" {
  for_each = { for obj in [
    {
      file_name = "extra_module_providers.tf"
      contents  = <<EOT
provider "kustomization" {
  kubeconfig_raw = var.extra_kubeconfig
}
  EOT
    },
    {
      file_name = "extra_module_variables.tf"
      contents  = <<EOT
variable "extra_kubeconfig" {
    sensitive = true
}
  EOT
    },
  ] : obj.file_name => obj }

  file_name = each.value.file_name
  contents  = each.value.contents
  module_id = snapcd_module.cert_manager_cluster_issuer.id
  overwrite = false
}

resource "snapcd_depends_on_module" "cert_manager_cluster_issuer" {
  module_id            = snapcd_module.cert_manager_cluster_issuer.id
  depends_on_module_id = snapcd_module.cert_manager.id
}
