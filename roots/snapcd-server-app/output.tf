output "url" {
  value = "https://${var.public_hostname}"
}

output "snapcd_server_url_in_cluster" {
  value = local.server_url
}

output "admin_email" {
  value = var.admin_email
}

// The three secrets below are null with a Key Vault: they are in the vault instead.
output "admin_password" {
  value     = one(random_password.admin[*].result)
  sensitive = true
}

output "snapcd_runner_client_secret" {
  value     = one(random_password.runner_client_secret[*].result)
  sensitive = true
}

output "snapcd_agent_client_secret" {
  value     = one(random_password.agent_client_secret[*].result)
  sensitive = true
}
