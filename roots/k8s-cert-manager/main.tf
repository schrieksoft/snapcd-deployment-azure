module "cert_manager" {
  source         = "../../modules/kustomization"
  absolute_paths = ["${path.root}/manifests/base"]
  patches = [
    {
      patch = templatefile("${path.module}/patches/namespace.yaml.tftpl", {
        namespace_tolerations   = jsonencode(var.namespace_tolerations)
        namespace_node_selector = jsonencode(var.namespace_node_selector)
      })
    },
  ]
}
