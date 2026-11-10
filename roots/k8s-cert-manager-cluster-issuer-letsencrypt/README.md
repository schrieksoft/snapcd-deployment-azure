# k8s-cert-manager-cluster-issuer-letsencrypt

Two cert-manager ClusterIssuers, `letsencrypt-staging` and `letsencrypt-prod`, that solve ACME HTTP-01 challenges through an Ingress of class `istio`. Istio serves that Ingress on the public gateway because `k8s-istio` sets `meshConfig.ingressService` and `meshConfig.ingressSelector` to it.
