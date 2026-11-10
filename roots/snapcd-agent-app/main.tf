locals {
  use_akv = var.key_vault_enabled
}

// Connects as the Agent the Server pre-seeds (organization, agent and client ID are the chart's defaults).
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

  // Helm merges these in order: the common values, then either the Key Vault or the local secret.
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

    config = {
      appsettings = {
        Server = {
          Url = var.server_url
        }
      }
    }

    // The chart refuses a sidecar with no Claude credential; without one the Agent runs without it.
    sidecar = {
      enabled = var.claude_oauth_token != "" || var.claude_api_key != ""
      credentials = {
        oauthToken = var.claude_oauth_token
        apiKey     = var.claude_api_key
      }
    }
  }), local.use_akv ? local.akv_values_yaml : local.local_values_yaml]
}

locals {
  local_values_yaml = yamlencode({
    credentials = {
      clientSecret = var.snapcd_agent_client_secret
    }
  })

  akv_values_yaml = yamlencode({
    externalSettings = {
      content = {
        PeriodInSeconds = 300
        DueTimeSeconds  = 300
        ReloadEnabled   = true
        Providers = [{
          Loader        = "AzureKeyVault"
          Configuration = { VaultUrl = var.snapcd_server_akv_url }
          Data = {
            Agent = { ClientSecret = var.snapcd_agent_client_secret_reference }
          }
        }]
      }
    }
  })
}
