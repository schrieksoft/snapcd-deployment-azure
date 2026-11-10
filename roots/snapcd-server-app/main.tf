locals {
  server_url = "http://${var.name}.${var.name}.svc.cluster.local:5000"
  tls_secret = "${var.name}-tls"
  use_akv    = var.key_vault_enabled
  local_keys = local.use_akv ? 0 : 1

  // Signs in with the Server's workload identity, which snapcd_server_infra_config made a db_owner user.
  connection_string = "Server=tcp:${var.snapcd_server_mssql_server_fqdn},1433;Database=${var.snapcd_server_mssql_database_name};Authentication=Active Directory Default;Encrypt=True;Max Pool Size=500;Min Pool Size=0;Connection Timeout=300;Pooling=true"
}

// The chart's defaults are public sample keys and passwords. Without key_vault_enabled they are
// replaced with the values generated below; with it, externalsettings.json reads them from the vault.

resource "tls_private_key" "token_signing" {
  count     = local.local_keys
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "random_bytes" "token_encryption" {
  count  = local.local_keys
  length = 32
}

resource "random_bytes" "state_store" {
  count  = local.local_keys
  length = 32
}

resource "random_bytes" "secret_store" {
  count  = local.local_keys
  length = 32
}

resource "random_password" "admin" {
  count            = local.local_keys
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "-_#!"
}

resource "random_password" "runner_client_secret" {
  count   = local.local_keys
  length  = 40
  special = false
}

resource "random_password" "agent_client_secret" {
  count   = local.local_keys
  length  = 40
  special = false
}

resource "helm_release" "snapcd_server" {
  name             = var.name
  namespace        = var.name
  create_namespace = true
  repository       = "oci://ghcr.io/schrieksoft/charts"
  chart            = "snapcd-server"
  version          = var.chart_version
  wait             = true
  timeout          = 900

  // Helm merges these in order: the common values, then either the Key Vault or the local keys.
  values = [yamlencode({
    fullnameOverride = var.name

    serviceAccount = {
      annotations = {
        "azure.workload.identity/client-id" = var.snapcd_server_workload_identity_client_id
        "azure.workload.identity/tenant-id" = var.tenant_id
      }
    }
    podLabels = {
      "azure.workload.identity/use" = "true"
    }

    database = {
      connectionString = local.connection_string
    }
    sqlserver = {
      enabled = false
    }

    config = {
      appsettings = {
        Server = {
          Host = "https://${var.public_hostname}"
        }
        ProductionDataSeeder = {
          Preseeded = {
            Enabled = true
            User    = { Email = var.admin_email }
          }
        }
      }
    }

    // TLS ends at the Istio gateway, which forwards plain HTTP to the Server.
    extraManifests = [
      {
        apiVersion = "cert-manager.io/v1"
        kind       = "Certificate"
        metadata   = { name = var.name, namespace = "istio-gateway" }
        spec = {
          secretName = local.tls_secret
          issuerRef  = { kind = "ClusterIssuer", name = var.cluster_issuer }
          dnsNames   = [var.public_hostname]
        }
      },
      {
        apiVersion = "networking.istio.io/v1beta1"
        kind       = "Gateway"
        metadata   = { name = var.name, namespace = "istio-gateway" }
        spec = {
          selector = { istio = "gateway" }
          servers = [{
            hosts = ["${var.name}/${var.public_hostname}"]
            port  = { name = "https", number = 443, protocol = "HTTPS" }
            tls   = { mode = "SIMPLE", credentialName = local.tls_secret }
          }]
        }
      },
      {
        apiVersion = "networking.istio.io/v1beta1"
        kind       = "VirtualService"
        metadata   = { name = var.name, namespace = var.name }
        spec = {
          hosts    = [var.public_hostname]
          gateways = ["istio-gateway/${var.name}"]
          http = [{
            match = [{ uri = { prefix = "/" } }]
            route = [{ destination = { host = var.name, port = { number = 5000 } } }]
          }]
        }
      },
    ]
  }), local.use_akv ? local.akv_values_yaml : local.local_values_yaml]
}

locals {
  local_values_yaml = yamlencode({ config = { appsettings = {
    OpenIdConnect = {
      TokenEncryption = {
        SymmetricKey = "-----BEGIN SYMMETRIC KEY-----\n${try(random_bytes.token_encryption[0].base64, "")}\n-----END SYMMETRIC KEY-----"
      }
      TokenSigning = {
        RsaPrivateKey = one(tls_private_key.token_signing[*].private_key_pem)
        RsaPublicKey  = one(tls_private_key.token_signing[*].public_key_pem)
      }
    }
    StateStore = {
      EncryptionKey = one(random_bytes.state_store[*].base64)
    }
    SecretStore = {
      SqlServer = {
        SymmetricKey = one(random_bytes.secret_store[*].base64)
      }
    }
    ProductionDataSeeder = {
      Preseeded = {
        Enabled = true
        User = {
          Email    = var.admin_email
          Password = one(random_password.admin[*].result)
        }
        Runner = {
          ServicePrincipalClientSecret = one(random_password.runner_client_secret[*].result)
        }
        Agent = {
          ServicePrincipalClientSecret = one(random_password.agent_client_secret[*].result)
        }
      }
    }
  } } })

  // The public key is not secret, so it stays in appsettings.json next to the vault-held private key.
  akv_values_yaml = yamlencode({
    config = {
      appsettings = {
        OpenIdConnect = {
          TokenSigning = {
            RsaPublicKey = var.snapcd_server_token_signing_public_key_pem
          }
        }
      }
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
            OpenIdConnect = {
              TokenEncryption = { SymmetricKey = var.snapcd_server_token_encryption_key_reference }
              TokenSigning    = { RsaPrivateKey = var.snapcd_server_token_signing_key_reference }
            }
            StateStore  = { EncryptionKey = var.snapcd_server_state_store_key_reference }
            SecretStore = { SqlServer = { SymmetricKey = var.snapcd_server_secret_store_key_reference } }
            ProductionDataSeeder = {
              Preseeded = {
                User   = { Password = var.snapcd_server_admin_password_reference }
                Runner = { ServicePrincipalClientSecret = var.snapcd_runner_client_secret_reference }
                Agent  = { ServicePrincipalClientSecret = var.snapcd_agent_client_secret_reference }
              }
            }
          }
        }]
      }
    }
  })
}
