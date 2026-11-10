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
