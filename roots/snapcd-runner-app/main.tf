locals {
  use_akv = var.snapcd_server_akv_url != ""
}

// The Runner's SSH key file comes from a Kubernetes Secret, which externalsettings.json cannot fill.
data "azurerm_key_vault_secret" "ssh" {
  count        = local.use_akv ? 1 : 0
  name         = var.snapcd_runner_ssh_key_secret_name
  key_vault_id = var.snapcd_runner_akv_id
}

// Connects as the Runner the Server pre-seeds (organization, runner and client ID are the chart's defaults).
resource "helm_release" "snapcd_runner" {
  name             = "snapcd-runner"
  namespace        = var.namespace
  create_namespace = true
  repository       = "oci://ghcr.io/schrieksoft/charts"
  chart            = "snapcd-runner"
  version          = var.chart_version
  wait             = true
  timeout          = 600

  // Helm merges these in order: the common values, then either the Key Vault or the local secret.
  values = [yamlencode({
    fullnameOverride = "snapcd-runner"

    config = {
      appsettings = {
        Server = {
          Url = var.server_url
        }
      }
    }
  }), local.use_akv ? local.akv_values_yaml : local.local_values_yaml]
}

locals {
  local_values_yaml = yamlencode({
    config = {
      appsettings = {
        RunnerEnvVars = {
          SNAPCD_CLIENT_SECRET = var.snapcd_runner_client_secret
        }
      }
    }
    credentials = {
      clientSecret = var.snapcd_runner_client_secret
    }
    ssh = {
      privateKey = var.ssh_private_key
    }
  })

  akv_values_yaml = yamlencode({
    workloadIdentity = {
      azure = {
        clientId = var.snapcd_runner_workload_identity_client_id
        tenantId = var.tenant_id
      }
    }
    ssh = {
      privateKey = one(data.azurerm_key_vault_secret.ssh[*].value)
    }
    externalSettings = {
      content = {
        PeriodInSeconds = 300
        DueTimeSeconds  = 300
        ReloadEnabled   = true
        Providers = [{
          Loader        = "AzureKeyVault"
          Configuration = { VaultUrl = var.snapcd_server_akv_url }
          Data = {
            Runner        = { Credentials = { ClientSecret = var.snapcd_runner_client_secret_reference } }
            RunnerEnvVars = { SNAPCD_CLIENT_SECRET = var.snapcd_runner_client_secret_reference }
          }
        }]
      }
    }
  })
}
