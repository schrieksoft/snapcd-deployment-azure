output "url" {
  value = "https://${var.public_hostname}"
}

output "snapcd_server_url_in_cluster" {
  value = local.server_url
}

output "admin_email" {
  value = var.admin_email
}

// The three secrets below are empty with key_vault_enabled: they are in the vault instead.
output "admin_password" {
  value     = try(random_password.admin[0].result, "")
  sensitive = true
}

output "snapcd_runner_client_secret" {
  value     = try(random_password.runner_client_secret[0].result, "")
  sensitive = true
}

output "snapcd_agent_client_secret" {
  value     = try(random_password.agent_client_secret[0].result, "")
  sensitive = true
}
