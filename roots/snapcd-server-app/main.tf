locals {
  // An sb:// address with no key makes MassTransit sign in to Service Bus with the workload identity.
  service_bus = var.bus_type == "AzureServiceBus" ? {
    BusType = "AzureServiceBus"
    TransportOptions = {
      AzureServiceBus = {
        ConnectionString = var.snapcd_server_servicebus_namespace_endpoint
      }
    }
    } : {
    BusType = "SqlServer"
    TransportOptions = {
      // SqlClient reads User ID as the client ID for Active Directory Default, and the transport names its database user by it.
      SqlServer = {
        ConnectionString = null
        Username         = var.snapcd_server_workload_identity_client_id
      }
    }
  }

  server_url = "http://${var.name}.${var.name}.svc.cluster.local:5000"
  tls_secret = "${var.name}-tls"

  // Signs in with the Server's workload identity, which snapcd_server_infra_config made a db_owner user.
  connection_string = "Server=tcp:${var.snapcd_server_mssql_server_fqdn},1433;Database=${var.snapcd_server_mssql_database_name};Authentication=Active Directory Default;Encrypt=True;Max Pool Size=500;Min Pool Size=0;Connection Timeout=300;Pooling=true"
}

resource "helm_release" "snapcd_server" {
  name             = var.name
  namespace        = var.name
  create_namespace = true
  repository       = "oci://ghcr.io/schrieksoft/charts"
  chart            = "snapcd-server"
  version          = var.chart_version
  wait             = true
  atomic           = true
  timeout          = 900

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
        ServiceBus = local.service_bus
        // The public key is not secret, so it stays here next to the vault-held private key.
        OpenIdConnect = {
          TokenSigning = {
            RsaPublicKey = var.snapcd_server_token_signing_public_key_pem
          }
        }
        // The Runner and the Agent authenticate with their projected ServiceAccount tokens. The Runner
        // keeps its client secret, for applying a configuration by hand as the "default" Service Principal.
        ProductionDataSeeder = {
          Preseeded = {
            Enabled = true
            User    = { Email = var.admin_email }
            Runner = {
              FederatedCredentials = [{
                Name    = "aks"
                Issuer  = var.cluster_oidc_issuer_url
                Subject = "system:serviceaccount:${var.runner_name}:${var.runner_name}"
              }]
            }
            Agent = {
              ServicePrincipalClientSecret = ""
              FederatedCredentials = [{
                Name    = "aks"
                Issuer  = var.cluster_oidc_issuer_url
                Subject = "system:serviceaccount:${var.agent_name}:${var.agent_name}"
              }]
            }
          }
        }
      }
    }

    // Replaces the chart's public sample keys and passwords with the ones in the Server's vault.
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
              }
            }
          }
        }]
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
  })]
}

