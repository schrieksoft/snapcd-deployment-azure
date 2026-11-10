output "snapcd_server_akv_id" {
  value = module.akv.id
}

output "snapcd_server_akv_url" {
  value      = module.akv.vault_uri
  depends_on = [time_sleep.role_propagation]
}

output "snapcd_server_workload_identity_client_id" {
  value = module.workload_identity.client_id
}

output "snapcd_server_mssql_server_fqdn" {
  value      = azurerm_mssql_server.this.fully_qualified_domain_name
  depends_on = [time_sleep.role_propagation]
}

output "snapcd_server_mssql_database_name" {
  value = azurerm_mssql_database.this.name
}
