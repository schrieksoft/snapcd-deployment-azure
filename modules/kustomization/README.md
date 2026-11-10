# Overview

Builds and deploys a "kustomization_resource", while catering for deployment order as described [here](https://registry.terraform.io/providers/kbst/kustomization/latest/docs/resources/resource).


# Example usage:


```terraform
module mymanifests {
  source = "../../modules/kustomization"
  absolute_paths = ["${path.root}/manifests/mymanifests"]

  patches = [{
    patch = templatefile("${path.module}/manifests/patches/mypatch.yaml.tftpl",
    {
      use_workload_identity = "true"
    }
    )
  }]

}
```

Where the contents of "mypatch.yaml.tftpl" is for example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myservice
  namespace: myservice
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "${use_workload_identity}"
```

You can use this in order to modify manifests with values passed in via terraform.