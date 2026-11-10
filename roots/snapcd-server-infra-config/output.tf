output "snapcd_server_token_signing_public_key_pem" {
  value = azrandom_cryptographic_key.token_signing.public_key_pem
}

output "snapcd_server_token_signing_key_reference" {
  value = "${azrandom_cryptographic_key.token_signing.name}/${azrandom_cryptographic_key.token_signing.version}"
}

output "snapcd_server_token_encryption_key_reference" {
  value = "${azrandom_cryptographic_key.token_encryption.name}/${azrandom_cryptographic_key.token_encryption.version}"
}

output "snapcd_server_admin_password_reference" {
  value = "${azrandom_string.admin_password.name}/${azrandom_string.admin_password.version}"
}

output "snapcd_server_state_store_key_reference" {
  value = "${azurerm_key_vault_secret.state_store.name}/${azurerm_key_vault_secret.state_store.version}"
}

output "snapcd_server_secret_store_key_reference" {
  value = "${azurerm_key_vault_secret.secret_store.name}/${azurerm_key_vault_secret.secret_store.version}"
}

output "snapcd_runner_client_secret_name" {
  value = azrandom_string.runner_client_secret.name
}

output "snapcd_runner_client_secret_reference" {
  value = "${azrandom_string.runner_client_secret.name}/${azrandom_string.runner_client_secret.version}"
}

output "snapcd_agent_client_secret_name" {
  value = azrandom_string.agent_client_secret.name
}

output "snapcd_agent_client_secret_reference" {
  value = "${azrandom_string.agent_client_secret.name}/${azrandom_string.agent_client_secret.version}"
}
