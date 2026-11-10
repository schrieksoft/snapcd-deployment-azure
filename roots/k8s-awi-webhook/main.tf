module "azure_workload_identity_webhook" {
  source         = "../../modules/kustomization"
  absolute_paths = ["${path.root}/manifests/base"]
  patches = [
    {
      patch = templatefile("${path.module}/patches/namespace.yaml.tftpl", {
        namespace_tolerations   = jsonencode(var.namespace_tolerations)
        namespace_node_selector = jsonencode(var.namespace_node_selector)
      })
    },
    {
      patch = templatefile("${path.module}/patches/configmap.yaml.tftpl", {
        tenant_id = var.tenant_id
      })
    },
  ]
}
