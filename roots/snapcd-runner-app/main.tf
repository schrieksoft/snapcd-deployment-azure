// Connects as the Runner the Server pre-seeds (organization, runner and client ID are the chart's defaults).
resource "helm_release" "snapcd_runner" {
  name             = var.name
  namespace        = var.name
  create_namespace = true
  repository       = "oci://ghcr.io/schrieksoft/charts"
  chart            = "snapcd-runner"
  version          = var.chart_version
  wait             = true
  atomic           = true
  timeout          = 600

  values = [yamlencode({
    fullnameOverride = var.name

    workloadIdentity = {
      azure = {
        clientId = var.snapcd_runner_workload_identity_client_id
        tenantId = var.tenant_id
      }
    }

    config = {
      appsettings = {
        Server = {
          Url = var.server_url
        }
      }
    }

    // The SSH key is a file, which externalsettings.json cannot supply, so the Secrets Store CSI
    // driver mounts it from the Runner's vault with the Runner's workload identity.
    ssh = {
      keyVolume = {
        csi = {
          driver           = "secrets-store.csi.k8s.io"
          readOnly         = true
          volumeAttributes = { secretProviderClass = "${var.name}-ssh" }
        }
      }
      keyVolumeKey = var.snapcd_runner_ssh_key_secret_name
    }
    extraManifests = [{
      apiVersion = "secrets-store.csi.x-k8s.io/v1"
      kind       = "SecretProviderClass"
      metadata   = { name = "${var.name}-ssh", namespace = var.name }
      spec = {
        provider = "azure"
        parameters = {
          usePodIdentity = "false"
          clientID       = var.snapcd_runner_workload_identity_client_id
          keyvaultName   = var.snapcd_runner_akv_name
          tenantId       = var.tenant_id
          objects = yamlencode({
            array = [yamlencode({
              objectName = var.snapcd_runner_ssh_key_secret_name
              objectType = "secret"
            })]
          })
        }
      }
    }]
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
  })]
}
