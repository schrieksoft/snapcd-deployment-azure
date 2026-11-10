provider "azrandom" {
  vault_url                              = var.snapcd_server_akv_url
  disable_workload_identity_credential   = false
  disable_environment_credential         = true
  disable_managed_identity_credential    = true
  disable_azure_developer_cli_credential = true
  disable_azure_cli_credential           = false
}

// Signs in as the identity running this job, which must be in the SQL server's Entra administrator group.
provider "mssql" {
  hostname   = var.snapcd_server_mssql_server_fqdn
  port       = 1433
  azure_auth = {}
}
