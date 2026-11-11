locals {
  claude_secret   = { OAuthToken = [var.claude_oauth_token_secret_name], ApiKey = [var.anthropic_api_key_secret_name], None = [] }[var.claude_credential]
  backend_secrets = length(local.claude_secret) == 0 ? [] : concat(local.claude_secret, var.github_token_enabled ? [var.github_token_secret_name] : [])
  sidecar         = var.claude_credential != "None"
  credentials     = "/mnt/credentials"
}

// Connects as the Agent the Server pre-seeds (organization, agent and client ID are the chart's defaults),
// with its projected ServiceAccount token, which matches the Federated Credential the Server seeds.
resource "helm_release" "snapcd_agent" {
  name             = var.name
  namespace        = var.name
  create_namespace = true
  repository       = "oci://ghcr.io/schrieksoft/charts"
  chart            = "snapcd-agent"
  version          = var.chart_version
  wait             = true
  atomic           = true
  timeout          = 600

  values = [yamlencode({
    fullnameOverride = var.name

    serviceAccount = {
      annotations = {
        "azure.workload.identity/client-id" = var.snapcd_agent_workload_identity_client_id
        "azure.workload.identity/tenant-id" = var.tenant_id
      }
    }
    podLabels = {
      "azure.workload.identity/use" = "true"
    }

    credentials = {
      mode = "Federated"
    }

    config = {
      appsettings = {
        Server = {
          Url = var.server_url
        }
      }
    }

    // The sidecar reads its credentials from files the Secrets Store CSI driver mounts from the backend vault.
    sidecar = {
      enabled = local.sidecar
      credentials = {
        files = {
          oauthToken  = var.claude_credential == "OAuthToken" ? "${local.credentials}/${var.claude_oauth_token_secret_name}" : ""
          apiKey      = var.claude_credential == "ApiKey" ? "${local.credentials}/${var.anthropic_api_key_secret_name}" : ""
          githubToken = var.github_token_enabled ? "${local.credentials}/${var.github_token_secret_name}" : ""
        }
      }
      extraVolumes = [{
        name = "credentials"
        csi = {
          driver           = "secrets-store.csi.k8s.io"
          readOnly         = true
          volumeAttributes = { secretProviderClass = "${var.name}-credentials" }
        }
      }]
      extraVolumeMounts = [{
        name      = "credentials"
        mountPath = local.credentials
        readOnly  = true
      }]
    }

    extraManifests = local.sidecar ? [{
      apiVersion = "secrets-store.csi.x-k8s.io/v1"
      kind       = "SecretProviderClass"
      metadata   = { name = "${var.name}-credentials", namespace = var.name }
      spec = {
        provider = "azure"
        parameters = {
          usePodIdentity = "false"
          clientID       = var.snapcd_agent_workload_identity_client_id
          keyvaultName   = var.backend_akv_name
          tenantId       = var.tenant_id
          objects = yamlencode({
            array = [for n in local.backend_secrets : yamlencode({
              objectName = n
              objectType = "secret"
            })]
          })
        }
      }
    }] : []

  })]
}
