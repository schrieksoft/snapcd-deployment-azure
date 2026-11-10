// Empty without key_vault_enabled. Add the public key as a deploy key where the Runner clones from.
output "snapcd_runner_ssh_public_key_openssh" {
  value = try(trimspace(azrandom_cryptographic_key.ssh[0].public_key_openssh), "")
}

output "snapcd_runner_ssh_key_secret_name" {
  value = try(azrandom_cryptographic_key.ssh[0].name, "")
}
