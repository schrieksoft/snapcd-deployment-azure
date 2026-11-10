# workload-identity

A user-assigned managed identity with a federated identity credential for one Kubernetes service account, for use with Microsoft Entra Workload ID. A pod running as `system:serviceaccount:<namespace>:<service_account>` on the cluster whose OIDC issuer is `cluster_oidc_issuer_url` can obtain tokens for the identity; no other pod can.

The service account needs the annotation `azure.workload.identity/client-id` set to the `client_id` output, and the pod the label `azure.workload.identity/use: "true"`.
