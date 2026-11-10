module "istio" {
  source         = "../../modules/kustomization"
  absolute_paths =  [
    "${path.root}/manifests/istio-base",
    "${path.root}/manifests/istio-discovery",
    "${path.root}/manifests/istio-gateway",
    //"${path.root}/manifests/istio-gateway-private"
  ]
  patches        = [
    {
      patch = templatefile("${path.module}/patches/istio-base/namespace.yaml.tftpl", {
        namespace_tolerations   = jsonencode(var.istio_system_namespace_tolerations)
        namespace_node_selector = jsonencode(var.istio_system_namespace_node_selector)
      })
    },

    //discovery
    {
      patch = templatefile("${path.module}/patches/istio-discovery/deployment.yaml.tftpl", {
        cpu_request    = jsonencode(var.istio_discovery_cpu_request)
        memory_request = jsonencode(var.istio_discovery_memory_request)
      })
    },

    // public gateway
    {
      patch = templatefile("${path.module}/patches/istio-gateway/namespace.yaml.tftpl", {
        namespace_tolerations   = jsonencode(var.istio_gateway_namespace_tolerations)
        namespace_node_selector = jsonencode(var.istio_gateway_namespace_node_selector)
      })
    },

    {
      patch = templatefile("${path.module}/patches/istio-gateway/service.yaml.tftpl", {
        resource_group_name = var.resource_group_name
        public_ip           = var.public_gateway_ip
      })
    },

    # // private gateway
    #   {
    #     patch = templatefile("${path.module}/patches/istio-gateway-private/namespace.yaml.tftpl", {
    #       namespace_tolerations   = jsonencode(var.istio_gateway_namespace_tolerations)
    #       namespace_node_selector = jsonencode(var.istio_gateway_namespace_node_selector)
    #     })
    #   },
    #   {
    #     patch = templatefile("${path.module}/patches/istio-gateway-private/service.yaml.tftpl", {
    #       private_ip = var.private_gateway_reserved_ip
    #     })
    #   }
    ]
}