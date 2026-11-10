locals {
  use_akv = var.key_vault_enabled
}

// Without a Key Vault the SSH key is generated here and handed to the chart; with one, azrandom
// generates it in snapcd_runner_infra_config.
resource "tls_private_key" "ssh" {
  count     = local.use_akv ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Connects as the Runner the Server pre-seeds (organization, runner and client ID are the chart's defaults).
resource "helm_release" "snapcd_runner" {
  name             = var.name
  namespace        = var.name
  create_namespace = true
  repository       = "oci://ghcr.io/schrieksoft/charts"
  chart            = "snapcd-runner"
  version          = var.chart_version
  wait             = true
  timeout          = 600

  // Helm merges these in order: the common values, then either the Key Vault or the local secret.
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
      privateKey = one(tls_private_key.ssh[*].private_key_pem)
    }
  })

  akv_values_yaml = yamlencode({
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
  })
}
