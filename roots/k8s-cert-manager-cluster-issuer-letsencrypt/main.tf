module "cert_manager_cluster_issuer" {
  source         = "../../modules/kustomization"
  absolute_paths = ["${path.root}/manifests"]
}
