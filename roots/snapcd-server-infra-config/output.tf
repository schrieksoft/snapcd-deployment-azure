// Empty without key_vault_enabled.
output "snapcd_server_token_signing_public_key_pem" {
  value = try(azrandom_cryptographic_key.token_signing[0].public_key_pem, "")
}

output "snapcd_server_token_signing_key_reference" {
  value = try("${azrandom_cryptographic_key.token_signing[0].name}/${azrandom_cryptographic_key.token_signing[0].version}", "")
}

output "snapcd_server_token_encryption_key_reference" {
  value = try("${azrandom_cryptographic_key.token_encryption[0].name}/${azrandom_cryptographic_key.token_encryption[0].version}", "")
}

output "snapcd_server_admin_password_reference" {
  value = try("${azrandom_string.admin_password[0].name}/${azrandom_string.admin_password[0].version}", "")
}

output "snapcd_server_state_store_key_reference" {
  value = try("${azurerm_key_vault_secret.state_store[0].name}/${azurerm_key_vault_secret.state_store[0].version}", "")
}

output "snapcd_server_secret_store_key_reference" {
  value = try("${azurerm_key_vault_secret.secret_store[0].name}/${azurerm_key_vault_secret.secret_store[0].version}", "")
}

output "snapcd_runner_client_secret_name" {
  value = try(azrandom_string.runner_client_secret[0].name, "")
}

output "snapcd_runner_client_secret_reference" {
  value = try("${azrandom_string.runner_client_secret[0].name}/${azrandom_string.runner_client_secret[0].version}", "")
}

output "snapcd_agent_client_secret_name" {
  value = try(azrandom_string.agent_client_secret[0].name, "")
}

output "snapcd_agent_client_secret_reference" {
  value = try("${azrandom_string.agent_client_secret[0].name}/${azrandom_string.agent_client_secret[0].version}", "")
}
